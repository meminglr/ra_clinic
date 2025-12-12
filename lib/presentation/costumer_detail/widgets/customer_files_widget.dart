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
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/services/webdav_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

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
      await service.ensureFolder(widget.customerId);
      final files = await service.listFiles(widget.customerId);

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

      // Ensure hidden thumbnail folder exists
      await service.ensureFolder(widget.customerId);
      await service.ensureFolder("${widget.customerId}/.thumbnails");

      // 1. Upload Original
      await service.uploadFile(widget.customerId, fileName, data);

      // 2. Generate & Upload Thumbnail
      await _generateAndUploadThumbnail(service, fileName, data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata ($fileName): $e")));
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
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
        final tempFile = File("${tempDir.path}/temp_upload_${fileName}");
        await tempFile.writeAsBytes(originalData);

        final plugin = FcNativeVideoThumbnail();
        final destFile = File("${tempDir.path}/thumb_upload_${fileName}.jpg");

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
        await service.uploadFile(
          "${widget.customerId}/.thumbnails",
          thumbName,
          thumbData,
        );
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
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Dosyalar yüklendi")));
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
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Medyalar yüklendi")));
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
          String path = "${widget.customerId}/$name";
          await service.deleteFile(path);
          // Also try to delete thumbnail if exists
          String thumbPath = "${widget.customerId}/.thumbnails/$name.jpg";
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
    String path = "${widget.customerId}/$fileName";
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
        .map((f) => service.getFileUrl("${widget.customerId}/${f.name}"))
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
          customerId: widget.customerId, // Added
          initialIndex: currentIndex,
          headers: service.getAuthHeaders(),
          onDelete: _loadFiles, // Added callback
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
      final tempDir = await getTemporaryDirectory();

      for (var name in _selectedFiles) {
        try {
          // 1. Get/Download file
          String url = service.getFileUrl("${widget.customerId}/$name");
          final fileInfo = await DefaultCacheManager().downloadFile(
            url,
            authHeaders: service.getAuthHeaders(),
          );

          // ... inside loop
          // 2. Copy to temp with original name (friendly for sharing)
          final safeName = name.replaceAll(RegExp(r'[^\w\.-]'), '_');
          final tempFile = File("${tempDir.path}/$safeName");

          if (await tempFile.exists()) {
            await tempFile.delete();
          }
          await fileInfo.file.copy(tempFile.path);

          final mimeType = lookupMimeType(name);
          filesToShare.add(XFile(tempFile.path, mimeType: mimeType));
        } catch (e) {
          debugPrint("Error preparing $name for share: $e");
        }
      }

      setState(() {
        _isLoading = false;
      }); // Hide loading before showing share sheet (native UI)

      if (filesToShare.isNotEmpty) {
        // 3. Share
        await Share.shareXFiles(
          filesToShare,
          text: "Dosyalar: ${widget.customerId}",
        );
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
                Text("${_selectedFiles.length} Seçildi"),
                Row(
                  children: [
                    IconButton(
                      onPressed: _shareSelectedFiles,
                      icon: const Icon(Icons.share, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: _deleteSelectedFiles,
                      icon: const Icon(Icons.delete, color: Colors.red),
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
                  itemBuilder: (context) => [
                    PullDownMenuItem(
                      onTap: _pickAndUploadFile,
                      title: 'Dosya Yükle',
                      icon: Icons.upload_file,
                    ),
                    PullDownMenuItem(
                      onTap: _takePhoto,
                      title: 'Fotoğraf Çek',
                      icon: Icons.camera_alt,
                    ),
                    PullDownMenuItem(
                      onTap: _pickAndUploadMultipleMedia,
                      title: 'Galeriden Seç',
                      icon: Icons.photo_library,
                    ),
                  ],
                  buttonBuilder: (context, showMenu) => FilledButton.icon(
                    onPressed: showMenu,
                    icon: const Icon(Icons.add),
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
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
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
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  // Add border if selected
                  shape: isSelected
                      ? RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
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
                                      "${widget.customerId}/.thumbnails/$name.jpg",
                                    ),
                                    httpHeaders: service.getAuthHeaders(),
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) {
                                      return CachedNetworkImage(
                                        imageUrl: service.getFileUrl(
                                          "${widget.customerId}/$name",
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
                                            "${widget.customerId}/.thumbnails/$name.jpg",
                                          ),
                                          httpHeaders: service.getAuthHeaders(),
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) {
                                            return VideoThumbnailWidget(
                                              url: service.getFileUrl(
                                                "${widget.customerId}/$name",
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
                                          Icons.videocam,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    color: Colors.grey[100],
                                    child: const Icon(
                                      Icons.insert_drive_file,
                                      size: 40,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                          ),
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Optional: Checkbox overlay
                      if (_isSelectionMode)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected ? Colors.blue : Colors.white,
                            shadows: const [
                              Shadow(blurRadius: 2, color: Colors.black),
                            ],
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

class FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final List<String> fileNames; // Added
  final String customerId; // Added
  final int initialIndex;
  final Map<String, String>? headers;
  final VoidCallback? onDelete; // Added

  const FullScreenMediaViewer({
    super.key,
    required this.mediaUrls,
    required this.fileNames,
    required this.customerId,
    required this.initialIndex,
    this.headers,
    this.onDelete,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _shareCurrentFile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final name = widget.fileNames[_currentIndex];
      final service = context.read<WebDavService>();
      final tempDir = await getTemporaryDirectory();

      // Download
      String url = service.getFileUrl("${widget.customerId}/$name");
      final fileInfo = await DefaultCacheManager().downloadFile(
        url,
        authHeaders: service.getAuthHeaders(),
      );

      // Prepare temp file
      final safeName = name.replaceAll(RegExp(r'[^\w\.-]'), '_');
      final tempFile = File("${tempDir.path}/$safeName");
      if (await tempFile.exists()) await tempFile.delete();
      await fileInfo.file.copy(tempFile.path);

      // Share
      final mimeType = lookupMimeType(name);
      await Share.shareXFiles([
        XFile(tempFile.path, mimeType: mimeType),
      ], text: "Dosya: $name");

      setState(() {
        _isLoading = false;
      });
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

  Future<void> _deleteCurrentFile() async {
    final name = widget.fileNames[_currentIndex];
    bool confirm =
        await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Sil"),
            content: Text("$name dosyasını silmek istiyor musunuz?"),
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

    try {
      setState(() {
        _isLoading = true;
      });
      final service = context.read<WebDavService>();

      await service.deleteFile("${widget.customerId}/$name");
      // Try delete thumb
      try {
        await service.deleteFile("${widget.customerId}/.thumbnails/$name.jpg");
      } catch (_) {}

      // Update local state
      setState(() {
        if (widget.mediaUrls.length == 1) {
          // Last item deleted
          Navigator.pop(context);
          widget.onDelete?.call();
          return;
        }

        widget.mediaUrls.removeAt(_currentIndex);
        widget.fileNames.removeAt(_currentIndex);

        if (_currentIndex >= widget.mediaUrls.length) {
          _currentIndex = widget.mediaUrls.length - 1;
        }
        _isLoading = false;
      });

      // Refresh page controller to reflect changes?
      // PageView behavior with dynamic list is tricky.
      // Re-creating controller or jumping might be needed, but setState usually redraws.
      // However, PageView doesn't automatically shift nicely if current page is removed.
      // Simple hack: Re-initialize controller slightly??
      // Actually, let's just force rebuild or jump.

      // Better UX: Trigger parent reload
      widget.onDelete?.call();
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

  bool _isImage(String url) {
    final name = url.split('/').last;
    final mimeType = lookupMimeType(name);
    return mimeType?.startsWith('image/') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          "${_currentIndex + 1} / ${widget.mediaUrls.length}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareCurrentFile,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCurrentFile,
            ),
          ],
        ],
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        // Switched to PageView for mixed media
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        itemCount: widget.mediaUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final url = widget.mediaUrls[index];
          if (_isImage(url)) {
            return PhotoView(
              imageProvider: CachedNetworkImageProvider(
                url,
                headers: widget.headers,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          } else {
            return AuthenticatedVideoPlayer(
              url: url,
              headers: widget.headers ?? {},
            );
          }
        },
      ),
    );
  }
}

class AuthenticatedVideoPlayer extends StatefulWidget {
  final String url;
  final Map<String, String> headers;
  const AuthenticatedVideoPlayer({
    super.key,
    required this.url,
    required this.headers,
  });

  @override
  State<AuthenticatedVideoPlayer> createState() =>
      _AuthenticatedVideoPlayerState();
}

class _AuthenticatedVideoPlayerState extends State<AuthenticatedVideoPlayer> {
  VideoPlayerController? _videoController;
  bool _isError = false;
  bool _isDragging = false;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      // 1. Check if file is already cached
      final fileInfo = await DefaultCacheManager().getFileFromCache(widget.url);

      if (fileInfo != null && await fileInfo.file.exists()) {
        // Play from cache (Offline/Fast)
        _videoController = VideoPlayerController.file(fileInfo.file);
      } else {
        // 2. Play from Network (Streaming/Fast)
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.url),
          httpHeaders: widget.headers,
        );

        // 3. Start Background Download (for next time)

        DefaultCacheManager()
            .downloadFile(widget.url, authHeaders: widget.headers)
            .then(
              (_) {},
              onError: (e) {
                debugPrint("Background cache download failed: $e");
              },
            );
      }

      await _videoController!.initialize();
      _videoController!.addListener(() {
        if (mounted && !_isDragging) setState(() {});
      });
      await _videoController!.setLooping(true);
      await _videoController!.play();

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted)
        setState(() {
          _isError = true;
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isError)
      return const Center(child: Icon(Icons.error, color: Colors.white));

    if (_videoController != null && _videoController!.value.isInitialized) {
      return GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            if (!_videoController!.value.isPlaying)
              Container(
                color: Colors.black26,
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        trackHeight: 2,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: _videoController!.value.position.inMilliseconds
                            .toDouble()
                            .clamp(
                              0.0,
                              _videoController!.value.duration.inMilliseconds
                                  .toDouble(),
                            ),
                        min: 0.0,
                        max: _videoController!.value.duration.inMilliseconds
                            .toDouble(),
                        activeColor: Colors.red,
                        inactiveColor: Colors.white24,
                        onChanged: (value) {
                          setState(() {
                            _isDragging = true;
                          });
                          _videoController!.seekTo(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                        onChangeEnd: (value) {
                          setState(() {
                            _isDragging = false;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_videoController!.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDuration(_videoController!.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class VideoThumbnailWidget extends StatefulWidget {
  final String url;
  final Map<String, String> headers;

  const VideoThumbnailWidget({
    super.key,
    required this.url,
    required this.headers,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  String? _thumbnailPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      // 1. Download/Cache file
      final fileInfo = await DefaultCacheManager().downloadFile(
        widget.url,
        authHeaders: widget.headers,
      );
      final file = fileInfo.file;

      // 2. Generate thumbnail from file
      final plugin = FcNativeVideoThumbnail();
      final tempDir = await getTemporaryDirectory();
      final destFile = File("${tempDir.path}/thumb_${widget.url.hashCode}.jpg");

      if (await destFile.exists()) {
        if (mounted) {
          setState(() {
            _thumbnailPath = destFile.path;
            _isLoading = false;
          });
        }
        return;
      }

      await plugin.getVideoThumbnail(
        srcFile: file.path,
        destFile: destFile.path,
        width: 200,
        height: 200,
        format: 'jpeg', // 'png' or 'jpeg'
        quality: 50,
      );

      if (mounted) {
        setState(() {
          _thumbnailPath = destFile.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_thumbnailPath != null)
          Image.file(File(_thumbnailPath!), fit: BoxFit.cover)
        else
          Container(
            color: Colors.black,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : const Icon(Icons.videocam_off, color: Colors.white),
          ),
        const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
        ),
      ],
    );
  }
}
