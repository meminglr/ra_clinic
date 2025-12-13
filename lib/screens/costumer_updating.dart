// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ra_clinic/services/webdav_service.dart';
import 'package:uuid/uuid.dart';

import 'package:ra_clinic/func/turkish_phone_formatter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:ra_clinic/func/utils.dart';

import '../constants/app_constants.dart';

class CostumerUpdating extends StatefulWidget {
  final CustomerModel? costumer;
  const CostumerUpdating({super.key, this.costumer});

  @override
  State<CostumerUpdating> createState() => _CostumerUpdatingState();
}

class _CostumerUpdatingState extends State<CostumerUpdating> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telNoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<SeansModel> _seansList = [];
  final Map<SeansModel, TextEditingController> _seansControllers = {};

  DateTime costumerStartDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  String kayitTarihi = "";
  String seansTarihi = "";

  String? costumerId;
  String? _profileImageUrl;
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.costumer == null) {
      for (var seans in _seansList) {
        _seansControllers[seans] = TextEditingController(text: seans.seansNote);
      }
      costumerId = const Uuid().v4();
    }

    if (widget.costumer != null) {
      _nameController.text = widget.costumer!.name;
      _telNoController.text = widget.costumer!.phone ?? "";
      _noteController.text = widget.costumer!.notes ?? "";
      _seansList = widget.costumer!.seansList;
      costumerStartDate = widget.costumer!.startDate;
      costumerId = widget.costumer!.customerId;
      for (var seans in widget.costumer!.seansList) {
        _seansControllers[seans] = TextEditingController(text: seans.seansNote);
      }
      _profileImageUrl = widget.costumer!.profileImageUrl;
    }
    kayitTarihiGuncelle();
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _isUploadingPhoto = true;
        });

        final data = await image.readAsBytes();
        // Dosya uzantısını al
        final extension = image.name.split('.').last;
        // Benzersiz isim oluştur: profile_<timestamp>.<ext>
        final fileName =
            "profile_${DateTime.now().millisecondsSinceEpoch}.$extension";

        final service = context.read<WebDavService>();
        await service.uploadFile(costumerId!, fileName, data);

        setState(() {
          _profileImageUrl = fileName;
          _isUploadingPhoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil fotoğrafı yüklendi")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  void removeSeans(int seansIndex) {
    if (_seansList.isNotEmpty) {
      _seansList[seansIndex].isDeleted = !_seansList[seansIndex].isDeleted;
    }
    // context.read<CostumerProvider>().removeSeans(index, seansList);
    setState(() {});
  }

  void seansEkle() {
    String newSeansId = const Uuid().v4();
    final newSeans = SeansModel(
      seansId: newSeansId,
      startDate: DateTime.now(),
      seansCount: _seansList.length + 1,
    );
    _seansControllers[newSeans] = TextEditingController();
    _seansList.add(newSeans);
    if (widget.costumer != null) {
      context.read<CustomerProvider>().updateCustomerAfterSeansChange(
        widget.costumer!,
      );
    }

    setState(() {});
  }

  void kayitTarihiGuncelle() {
    kayitTarihi = Utils.toDate(costumerStartDate);
    setState(() {});
  }

  void saveAndReturn(String id) {
    if (_nameController.text.isNotEmpty || _formKey.currentState!.validate()) {
      final CustomerModel newCostumer = CustomerModel(
        customerId: id,
        name: _nameController.text,
        phone: _telNoController.text,
        startDate: costumerStartDate,
        notes: _noteController.text,

        seansList: _seansList,
        profileImageUrl: _profileImageUrl,
      );
      Navigator.pop(context, newCostumer);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gerekli alanları doldurunuz")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _telNoController.dispose();
    _noteController.dispose();
    for (var controller in _seansControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.costumer == null ? "Müşteri Ekle" : "Müşteri Düzenle",
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveAndReturn(costumerId!);
          //  Navigator.pop(context);
        },
        label: const Text("Kaydet"),
        icon: const Icon(Icons.save_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 15,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickAndUploadProfilePhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _profileImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      context.read<WebDavService>().getFileUrl(
                                        "${costumerId!}/$_profileImageUrl",
                                      ),
                                      headers: context
                                          .read<WebDavService>()
                                          .getAuthHeaders(),
                                    )
                                  : null,
                              child: _profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            if (_isUploadingPhoto)
                              const Positioned.fill(
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen müşteri ismini giriniz';
                        }
                        return null;
                      },
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: "Müşteri ismini giriniz",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    TextFormField(
                      controller: _telNoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        AdaptiveTurkishPhoneFormatter(),
                        // Ek güvenlik için: + veya diğer karakterlere izin vermek isterseniz buraya ekleyebilirsiniz.
                        // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintText: "Telefon No",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    TextFormField(
                      controller: _noteController,
                      minLines: 1,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Not",
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card.filled(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                                CupertinoCalendarPickerButton(
                                  buttonDecoration: PickerButtonDecoration(
                                    textStyle: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  minimumDateTime: DateTime(2020, 1, 1),
                                  maximumDateTime: DateTime(2030, 12, 31),
                                  initialDateTime: costumerStartDate,
                                  barrierColor: Colors.transparent,

                                  containerDecoration:
                                      PickerContainerDecoration(
                                        backgroundColor:
                                            AppConstants.dropDownButtonsColor(
                                              context,
                                            ),
                                        backgroundType:
                                            PickerBackgroundType.plainColor,
                                      ),
                                  mode: CupertinoCalendarMode.date,
                                  timeLabel: 'Saat',
                                  onDateTimeChanged: (date) {
                                    costumerStartDate = date;
                                    kayitTarihiGuncelle();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        Card.filled(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                                CupertinoTimePickerButton(
                                  buttonDecoration: PickerButtonDecoration(
                                    textStyle: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  barrierColor: Colors.transparent,

                                  containerDecoration:
                                      PickerContainerDecoration(
                                        backgroundColor:
                                            AppConstants.dropDownButtonsColor(
                                              context,
                                            ),
                                        backgroundType:
                                            PickerBackgroundType.plainColor,
                                      ),
                                  onTimeChanged: (value) {
                                    costumerStartDate = DateTime(
                                      costumerStartDate.year,
                                      costumerStartDate.month,
                                      costumerStartDate.day,
                                      value.hour,
                                      value.minute,
                                    );
                                    kayitTarihiGuncelle();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _seansList.length,
              itemBuilder: (context, index) {
                SeansModel seans = _seansList[index];
                return Column(
                  children: [
                    seans.isDeleted
                        ? FilledButton.tonal(
                            onPressed: () {
                              removeSeans(index);
                            },
                            child: Text("${seans.seansCount}. Seansı Ekle"),
                          )
                        : Card.filled(
                            child: Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onInverseSurface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,

                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${seans.seansCount}. Seans·",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              Utils.toDate(seans.startDate),
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () => removeSeans(index),
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _seansControllers[seans],
                                  minLines: 1,
                                  maxLines: null,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onChanged: (value) {
                                    seans.seansNote = value;
                                  },
                                  decoration: InputDecoration(
                                    filled: false,
                                    hintText: "Seans Notu Ekle",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 100,
                  left: 100,
                  right: 100,
                ),
                child: FilledButton(
                  onPressed: () {
                    seansEkle();
                  },
                  child: Text("Seans Ekle"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
