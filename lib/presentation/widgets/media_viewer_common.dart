import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:ra_clinic/services/webdav_service.dart';

class FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final List<String> fileNames;
  final String basePath;
  final int initialIndex;
  final Map<String, String>? headers;
  final void Function(String)? onFileDeleted;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaUrls,
    required this.fileNames,
    required this.basePath,
    required this.initialIndex,
    this.headers,
    this.onFileDeleted,
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

  bool _isImage(String url) {
    final name = url.split('/').last;
    final mimeType = lookupMimeType(name);
    return mimeType?.startsWith('image/') ?? false;
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
      String url = service.getFileUrl("${widget.basePath}/$name");
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

      await service.deleteFile("${widget.basePath}/$name");
      // Try delete thumb
      try {
        await service.deleteFile("${widget.basePath}/.thumbnails/$name.jpg");
      } catch (_) {}

      // Update local state
      setState(() {
        if (widget.mediaUrls.length == 1) {
          // Last item deleted
          Navigator.pop(context);
          widget.onFileDeleted?.call(name);
          return;
        }

        widget.mediaUrls.removeAt(_currentIndex);
        widget.fileNames.removeAt(_currentIndex);

        if (_currentIndex >= widget.mediaUrls.length) {
          _currentIndex = widget.mediaUrls.length - 1;
        }
        _isLoading = false;
      });

      // Need to rebuild page controller usually when list changes drastically or use key
      // But for simplicity, we just rely on setState.
      // Note: PageController doesn't auto-adjust well, might look glitchy but works.

      widget.onFileDeleted?.call(name);
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
          _isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.share_outlined),
                  color: Colors.white,
                  onPressed: _shareCurrentFile,
                ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteCurrentFile,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        itemCount: widget.mediaUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          // Guard against out of bounds if deletion happened
          if (index >= widget.mediaUrls.length) return const SizedBox();

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
    if (_isError) {
      return const Center(child: Icon(Icons.error, color: Colors.white));
    }

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
                    Icons.play_arrow_outlined,
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
