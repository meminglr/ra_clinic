import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/auth_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/services/webdav_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

import 'package:ra_clinic/presentation/widgets/media_viewer_common.dart';
import '../../../constants/app_constants.dart';

class CustomerFilesWidget extends StatefulWidget {
  final String customerId;
  const CustomerFilesWidget({super.key, required this.customerId});

  @override
  State<CustomerFilesWidget> createState() => _CustomerFilesWidgetState();
}

class _CustomerFilesWidgetState extends State<CustomerFilesWidget> {
  List<dynamic> _files = [];
  bool _isLoading = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  // Helper to get base path
  String get _basePath {
    final uid = context.read<FirebaseAuthProvider>().currentUser?.uid ?? "";
    return "$uid/customers/${widget.customerId}";
  }

  // Selection State
  bool _isSelectionMode = false;
  final Set<String> _selectedFiles = {};

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      if (_files.isEmpty) _isLoading = true;
    });

    try {
      final service = context.read<WebDavService>();
      final path = _basePath;
      await service.ensurePath(path);
      final files = await service.listFiles(path);

      if (mounted) {
        setState(() {
          _files = files.where((f) => !(f.isDir ?? false)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Yükleme hatası: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadRawData(String fileName, Uint8List data) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = context.read<WebDavService>();
      final path = _basePath;

      // Ensure hidden thumbnail folder exists
      await service.ensurePath(path);
      await service.ensureFolder("$path/.thumbnails");

      // 1. Upload Original
      await service.uploadFile(path, fileName, data);

      // 2. Generate & Upload Thumbnail
      await _generateAndUploadThumbnail(service, fileName, data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata ($fileName): $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateAndUploadThumbnail(
    WebDavService service,
    String fileName,
    Uint8List originalData,
  ) async {
    try {
      final mimeType = lookupMimeType(fileName);
      Uint8List? thumbData;

      if (mimeType != null && mimeType.startsWith('image/')) {
        // Resize Image
        final cmd = img.Command()
          ..decodeImage(originalData)
          ..copyResize(width: 200)
          ..encodeJpg(quality: 60);
        thumbData = await cmd.getBytesThread();
      } else if (mimeType != null && mimeType.startsWith('video/')) {
        // Generate Video Thumb (requires saving to file first)
        final tempDir = await getTemporaryDirectory();
        final tempFile = File("${tempDir.path}/temp_upload_$fileName");
        await tempFile.writeAsBytes(originalData);

        final plugin = FcNativeVideoThumbnail();
        final destFile = File("${tempDir.path}/thumb_upload_$fileName.jpg");

        await plugin.getVideoThumbnail(
          srcFile: tempFile.path,
          destFile: destFile.path,
          width: 200,
          height: 200,
          format: 'jpeg',
          quality: 60,
        );

        if (await destFile.exists()) {
          thumbData = await destFile.readAsBytes();
        }
      }

      if (thumbData != null) {
        // Upload to .thumbnails folder as .jpg
        final thumbName = "$fileName.jpg";
        final path = _basePath;
        await service.uploadFile("$path/.thumbnails", thumbName, thumbData);
      }
    } catch (e) {
      debugPrint("Thumbnail generation failed for $fileName: $e");
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
        });

        for (var file in result.files) {
          Uint8List data;
          if (file.bytes != null) {
            data = file.bytes!;
          } else if (file.path != null) {
            data = await File(file.path!).readAsBytes();
          } else {
            continue;
          }
          await _uploadRawData(file.name, data);
        }

        await _loadFiles();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Dosyalar yüklendi")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Dosya seçimi hatası: $e")));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadMultipleMedia() async {
    try {
      // Pick multiple images and videos
      final List<XFile> medias = await _picker.pickMultipleMedia();

      if (medias.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        for (var media in medias) {
          final data = await media.readAsBytes();
          final fileName = media.name;
          await _uploadRawData(fileName, data);
        }

        await _loadFiles();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Medyalar yüklendi")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Medya seçimi hatası: $e")));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _isLoading = true;
        });
        final data = await image.readAsBytes();
        await _uploadRawData(image.name, data);
        await _loadFiles();
      }
    } catch (e) {
      // handle error
    }
  }

  void _toggleSelection(String fileName) {
    setState(() {
      if (_selectedFiles.contains(fileName)) {
        _selectedFiles.remove(fileName);
        if (_selectedFiles.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedFiles.add(fileName);
      }
    });
  }

  void _enterSelectionMode(String fileName) {
    setState(() {
      _isSelectionMode = true;
      _selectedFiles.add(fileName);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedFiles.clear();
    });
  }

  Future<void> _deleteSelectedFiles() async {
    try {
      if (_selectedFiles.isEmpty) return;

      bool confirm =
          await showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text("Sil"),
              content: Text(
                "${_selectedFiles.length} dosyayı silmek istiyor musunuz?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text("Hayır"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text("Evet"),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      setState(() {
        _isLoading = true;
      });

      final service = context.read<WebDavService>();

      for (var name in _selectedFiles) {
        try {
          String path = "$_basePath/$name";
          await service.deleteFile(path);
          // Also try to delete thumbnail if exists
          String thumbPath = "$_basePath/.thumbnails/$name.jpg";
          await service.deleteFile(thumbPath);
        } catch (e) {
          debugPrint("Error deleting $name: $e");
        }
      }

      _exitSelectionMode();
      await _loadFiles();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Silme hatası: $e")));
      }
    }
  }

  void _openFile(String fileName) {
    final service = context.read<WebDavService>();
    String path = "$_basePath/$fileName";
    String url = service.getFileUrl(path);
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _viewMedia(String currentFileName) {
    // Filter supported media (images + videos)
    final allMedia = _files.where((f) {
      final name = f.name ?? "";
      return _isImage(name) || _isVideo(name);
    }).toList();

    final service = context.read<WebDavService>();
    final mediaUrls = allMedia
        .map((f) => service.getFileUrl("$_basePath/${f.name}"))
        .toList();
    final currentIndex = allMedia.indexWhere((f) => f.name == currentFileName);

    if (currentIndex == -1) return;

    final fileNames = allMedia.map((f) => f.name ?? "").toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenMediaViewer(
          mediaUrls: List<String>.from(mediaUrls),
          fileNames: List<String>.from(fileNames), // Added
          basePath: _basePath, // Changed
          initialIndex: currentIndex,
          headers: service.getAuthHeaders(),
          onFileDeleted: (_) => _loadFiles(), // Added callback
        ),
      ),
    );
  }

  bool _isImage(String name) {
    final mimeType = lookupMimeType(name);
    return mimeType?.startsWith('image/') ?? false;
  }

  bool _isVideo(String name) {
    final mimeType = lookupMimeType(name);
    return mimeType?.startsWith('video/') ?? false;
  }

  Future<void> _shareSelectedFiles() async {
    try {
      if (_selectedFiles.isEmpty) return;

      setState(() {
        _isLoading = true;
      });

      final service = context.read<WebDavService>();
      List<XFile> filesToShare = [];
      final baseTempDir = await getTemporaryDirectory();
      final shareDir = Directory(
        '${baseTempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}',
      );
      await shareDir.create(recursive: true);

      for (var name in _selectedFiles) {
        try {
          // 1. Get/Download file
          String url = service.getFileUrl("$_basePath/$name");
          final fileInfo = await DefaultCacheManager().downloadFile(
            url,
            authHeaders: service.getAuthHeaders(),
          );

          // 2. Copy to unique temp dir with original name
          final safeName = name.replaceAll(RegExp(r'[^\w\.-]'), '_');
          final tempFile = File("${shareDir.path}/$safeName");

          await fileInfo.file.copy(tempFile.path);

          final mimeType = lookupMimeType(name);
          filesToShare.add(XFile(tempFile.path, mimeType: mimeType));
        } catch (e) {
          debugPrint("Error preparing $name for share: $e");
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (filesToShare.isNotEmpty) {
        // 3. Share - Removing text to avoid mixing content types issues
        await Share.shareXFiles(filesToShare);
      }

      _exitSelectionMode();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Paylaşım hatası: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_isSelectionMode) ...[
                Text("${_selectedFiles.length} Öğe Seçildi"),
                Row(
                  children: [
                    IconButton(
                      onPressed: _shareSelectedFiles,
                      icon: const Icon(Icons.share_outlined),
                    ),
                    IconButton(
                      onPressed: _deleteSelectedFiles,
                      icon: const Icon(Icons.delete_outlined),
                    ),
                    IconButton(
                      onPressed: _exitSelectionMode,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  "Dosyalar (${_files.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                PullDownButton(
                  routeTheme: PullDownMenuRouteTheme(
                    backgroundColor: AppConstants.dropDownButtonsColor(context),
                  ),
                  itemBuilder: (context) => [
                    PullDownMenuItem(
                      onTap: _pickAndUploadFile,
                      title: 'Dosya Yükle',
                      icon: Icons.upload_file,
                    ),
                    PullDownMenuItem(
                      onTap: _takePhoto,
                      title: 'Fotoğraf Çek',
                      icon: Icons.camera_alt_outlined,
                    ),
                    PullDownMenuItem(
                      onTap: _pickAndUploadMultipleMedia,
                      title: 'Galeriden Seç',
                      icon: Icons.photo_library,
                    ),
                  ],
                  buttonBuilder: (context, showMenu) => FilledButton.icon(
                    onPressed: showMenu,
                    icon: const Icon(Icons.add_outlined),
                    label: const Text("Ekle"),
                  ),
                ),
              ],
            ],
          ),
        ),

        if (_errorMessage != null) Text(_errorMessage!),

        if (_files.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
            ),
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
              final String name = file.name ?? "Bilinmeyen";
              final bool isImage = _isImage(name);
              final bool isVideo = _isVideo(name);
              final bool isSelected = _selectedFiles.contains(name);
              final service = context.read<WebDavService>();

              return GestureDetector(
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(name);
                  } else {
                    (isImage || isVideo) ? _viewMedia(name) : _openFile(name);
                  }
                },
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _enterSelectionMode(name);
                  } else {
                    _toggleSelection(name);
                  }
                },
                child: Card.filled(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            // reuse existing content logic
                            child: isImage
                                ? CachedNetworkImage(
                                    imageUrl: service.getFileUrl(
                                      "$_basePath/.thumbnails/$name.jpg",
                                    ),
                                    httpHeaders: service.getAuthHeaders(),
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      return CachedNetworkImage(
                                        imageUrl: service.getFileUrl(
                                          "$_basePath/$name",
                                        ),
                                        httpHeaders: service.getAuthHeaders(),
                                        fit: BoxFit.cover,
                                        errorWidget: (c, u, e) =>
                                            const Icon(Icons.error),
                                      );
                                    },
                                  )
                                : isVideo
                                ? Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CachedNetworkImage(
                                          imageUrl: service.getFileUrl(
                                            "$_basePath/.thumbnails/$name.jpg",
                                          ),
                                          httpHeaders: service.getAuthHeaders(),
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) {
                                            return VideoThumbnailWidget(
                                              url: service.getFileUrl(
                                                "$_basePath/$name",
                                              ),
                                              headers: service.getAuthHeaders(),
                                            );
                                          },
                                        ),
                                      ),
                                      const Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Icon(
                                          Icons.videocam_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    color: AppConstants.dropDownButtonsColor(
                                      context,
                                    ),
                                    child: const Icon(
                                      Icons.insert_drive_file_outlined,
                                      size: 40,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                          ),
                        ],
                      ),

                      // Optional: Checkbox overlay
                      Positioned(
                        top: 4,
                        right: 4,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: _isSelectionMode
                              ? Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                  shadows: const [
                                    Shadow(blurRadius: 2, color: Colors.black),
                                  ],
                                )
                              : SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
