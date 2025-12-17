import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:image_picker/image_picker.dart';
import 'package:ra_clinic/services/webdav_service.dart';
import 'package:ra_clinic/providers/auth_provider.dart';
import 'dart:io';

import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:ra_clinic/constants/app_constants.dart';
import 'package:uuid/uuid.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/presentation/widgets/media_viewer_common.dart';

class AddSeansSheet extends StatefulWidget {
  final CustomerModel customer;
  final SeansModel? editingSeans;

  const AddSeansSheet({super.key, required this.customer, this.editingSeans});

  @override
  State<AddSeansSheet> createState() => _AddSeansSheetState();
}

class _AddSeansSheetState extends State<AddSeansSheet> {
  late DateTime _selectedDate;
  late TextEditingController _noteController;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];
  List<String> _existingImageUrls = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.editingSeans?.startDate ?? DateTime.now();
    _noteController = TextEditingController(
      text: widget.editingSeans?.seansNote ?? '',
    );
    if (widget.editingSeans != null) {
      _existingImageUrls = List.from(widget.editingSeans!.imageUrls);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickMultiImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(images);
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedFiles.add(video);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _saveSeans() async {
    // 1. Prepare data
    List<String> finalImageNames = List.from(_existingImageUrls);
    Map<String, XFile> newImagesMap = {};

    for (var file in _selectedFiles) {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
      finalImageNames.add(fileName);
      newImagesMap[fileName] = file;
    }

    // 2. Capture necessary services/ids before async gaps or pop
    final webDavService = context.read<WebDavService>();
    final customerProvider = context.read<CustomerProvider>();
    final seansId = widget.editingSeans?.seansId ?? const Uuid().v4();
    final uid = context.read<FirebaseAuthProvider>().currentUser?.uid;
    final customerId = widget.customer.customerId;

    // 3. Update Model & Provider Immediately
    try {
      List<SeansModel> updatedList = List.from(widget.customer.seansList);

      if (widget.editingSeans != null) {
        // Edit mode
        final index = updatedList.indexWhere(
          (s) => s.seansId == widget.editingSeans!.seansId,
        );
        if (index != -1) {
          updatedList[index] = widget.editingSeans!.copyWith(
            startDate: _selectedDate,
            seansNote: _noteController.text,
            imageUrls: finalImageNames,
          );
        }
      } else {
        // Add mode
        final newSeans = SeansModel(
          seansId: seansId,
          startDate: _selectedDate,
          seansCount: widget.customer.seansList.length + 1,
          seansNote: _noteController.text,
          imageUrls: finalImageNames,
        );
        updatedList.add(newSeans);
      }

      CustomerModel updatedCustomer = widget.customer.copyWith(
        seansList: updatedList,
      );

      customerProvider.updateCustomerAfterSeansChange(updatedCustomer);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editingSeans != null
                  ? "Seans güncellendi."
                  : "Seans eklendi.",
            ),
          ),
        );
      }

      // 4. Start Background Upload
      _uploadInBackground(
        webDavService: webDavService,
        customerProvider: customerProvider,
        newImagesMap: newImagesMap,
        uid: uid,
        customerId: customerId,
        seansId: seansId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata oluştu: $e")));
      }
    }
  }

  Future<void> _uploadInBackground({
    required WebDavService webDavService,
    required CustomerProvider customerProvider,
    required Map<String, XFile> newImagesMap,
    required String? uid,
    required String customerId,
    required String seansId,
  }) async {
    if (uid == null) return;

    for (var entry in newImagesMap.entries) {
      final fileName = entry.key;
      // Mark as uploading in global state logic
      customerProvider.markFileAsUploading(fileName);

      try {
        final xFile = entry.value;
        final path = "$uid/customers/$customerId/sessions/$seansId";

        await webDavService.uploadFile(
          path,
          fileName,
          await xFile.readAsBytes(),
        );
      } catch (e) {
        debugPrint("Upload failed for ${entry.key}: $e");
      } finally {
        // Mark as uploaded (or failed, stop showing loader)
        customerProvider.markFileAsUploaded(fileName);
      }
    }
  }

  void _viewMedia(String currentFileName) {
    if (_existingImageUrls.isEmpty) return;

    final webDavService = context.read<WebDavService>();
    final uid = context.read<FirebaseAuthProvider>().currentUser?.uid;
    final basePath =
        "$uid/customers/${widget.customer.customerId}/sessions/${widget.editingSeans?.seansId}";

    final mediaUrls = _existingImageUrls.map((name) {
      return webDavService.getFileUrl("$basePath/$name");
    }).toList();

    final index = _existingImageUrls.indexOf(currentFileName);

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => FullScreenMediaViewer(
          mediaUrls: mediaUrls,
          fileNames: List.from(_existingImageUrls),
          basePath: basePath,
          initialIndex: index == -1 ? 0 : index,
          headers: webDavService.getAuthHeaders(),
          onFileDeleted: (name) {
            setState(() {
              _existingImageUrls.remove(name);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Klavye açıldığında yukarı kayması için bottom inse
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.editingSeans != null
                    ? "Seansı Düzenle"
                    : "Yeni Seans Ekle",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              FilledButton(
                onPressed: _saveSeans,
                child: Text(widget.editingSeans != null ? "Kaydet" : "Ekle"),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: "Seans Notu",
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 1,
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    CupertinoCalendarPickerButton(
                      buttonDecoration: PickerButtonDecoration(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      minimumDateTime: DateTime(2000, 1, 1),
                      maximumDateTime: DateTime(2050, 12, 31),
                      initialDateTime: _selectedDate,
                      barrierColor: Colors.transparent,
                      containerDecoration: PickerContainerDecoration(
                        backgroundColor: AppConstants.dropDownButtonsColor(
                          context,
                        ),
                        backgroundType: PickerBackgroundType.plainColor,
                      ),
                      mode: CupertinoCalendarMode.date,
                      timeLabel: 'Saat',
                      onDateTimeChanged: (date) {
                        setState(() {
                          _selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            _selectedDate.hour,
                            _selectedDate.minute,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    CupertinoTimePickerButton(
                      buttonDecoration: PickerButtonDecoration(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                      barrierColor: Colors.transparent,
                      containerDecoration: PickerContainerDecoration(
                        backgroundColor: AppConstants.dropDownButtonsColor(
                          context,
                        ),
                        backgroundType: PickerBackgroundType.plainColor,
                      ),
                      onTimeChanged: (time) {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Not Alanı
          const SizedBox(height: 20),
          const SizedBox(height: 20),

          // Fotoğraf Seçimi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fotoğraflar",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              PullDownButton(
                routeTheme: PullDownMenuRouteTheme(
                  backgroundColor: AppConstants.dropDownButtonsColor(context),
                ),
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'Fotoğraf Ekle',
                    icon: Icons.photo_library_outlined,
                    onTap: _pickMultiImage,
                  ),
                  PullDownMenuItem(
                    title: 'Video Ekle',
                    icon: Icons.video_library_outlined,
                    onTap: _pickVideo,
                  ),
                ],
                buttonBuilder: (context, showMenu) => IconButton.filledTonal(
                  onPressed: showMenu,
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          if (_selectedFiles.isNotEmpty || _existingImageUrls.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Existing Remote Images
                  ..._existingImageUrls.asMap().entries.map((entry) {
                    final index = entry.key;
                    final fileName = entry.value;
                    final webDavService = context.read<WebDavService>();
                    final path =
                        "${context.read<FirebaseAuthProvider>().currentUser?.uid}/customers/${widget.customer.customerId}/sessions/${widget.editingSeans?.seansId}/$fileName";
                    final url = webDavService.getFileUrl(path);
                    final headers = webDavService.getAuthHeaders();

                    final isVideo =
                        fileName.toLowerCase().endsWith('.mp4') ||
                        fileName.toLowerCase().endsWith('.mov');

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _viewMedia(fileName),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: isVideo
                                    ? VideoThumbnailWidget(
                                        url: url,
                                        headers: headers,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: url,
                                        httpHeaders: headers,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.error),
                                            ),
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => _removeExistingImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // New Local Files
                  ..._selectedFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final xFile = entry.value;
                    final isVideo =
                        xFile.path.toLowerCase().endsWith('.mp4') ||
                        xFile.path.toLowerCase().endsWith('.mov');

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: isVideo
                                ? Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.black12,
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      size: 40,
                                    ),
                                  )
                                : Image.file(
                                    File(xFile.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
