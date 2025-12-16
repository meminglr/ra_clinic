import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final String? initialUrl;
  final Map<String, String>? authHeaders;
  final Function(File?) onPick;

  const ProfilePhotoPicker({
    super.key,
    this.initialUrl,
    this.authHeaders,
    required this.onPick,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      widget.onPick(_imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(
        widget.initialUrl!,
        headers: widget.authHeaders,
      );
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
