import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/business_owner_profile.dart';
import 'package:ra_clinic/providers/user_profile_provider.dart';
import 'package:ra_clinic/screens/components/profile_photo_picker.dart';
import 'package:ra_clinic/services/webdav_service.dart';

class CompleteProfilePage extends StatefulWidget {
  final bool
  isEditMode; // Ayarlardan geliyorsa true, kayıt sonrası ise false (zorunlu)

  const CompleteProfilePage({super.key, this.isEditMode = false});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedPhoto;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modu ise veya provider'da veri varsa doldur
    final provider = context.read<UserProfileProvider>();
    final profile = provider.profile;

    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _businessNameController.text = profile.businessName;
      _phoneController.text = profile.phoneNumber;
      _currentPhotoUrl = profile.photoUrl;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProfileProvider>();
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Profil Düzenle' : 'Profili Tamamla'),
        automaticallyImplyLeading:
            widget.isEditMode, // Zorunlu modda geri gidilemez
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16,
            children: [
              ProfilePhotoPicker(
                initialUrl: _currentPhotoUrl,
                authHeaders: context.read<WebDavService>().getAuthHeaders(),
                onPick: (file) {
                  _selectedPhoto = file;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Ad *'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ad zorunludur' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Soyad'),
              ),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: 'İşletme Adı'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;

                          final newProfile = BusinessOwnerProfile(
                            uid: uid,
                            firstName: _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim(),
                            businessName: _businessNameController.text.trim(),
                            phoneNumber: _phoneController.text.trim(),
                            photoUrl:
                                _currentPhotoUrl ??
                                '', // Eski URL korunur, provider içinde override edilir
                          );

                          try {
                            await provider.saveUserProfile(
                              newProfile,
                              _selectedPhoto,
                            );

                            if (!mounted) return;

                            if (widget.isEditMode) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil güncellendi'),
                                ),
                              );
                            } else {
                              // Zorunlu moddan çıkış -> Home
                              // Ancak Home zaten bu sayfayı açtıysa, pop yapınca Home'a döner mi?
                              // Home'da kontrol varsa sürekli buraya atabilir.
                              // Bu yüzden Auth flow'unu iyi yönetmeliyiz.
                              // Şimdilik pop ile deneyelim, çünkü pushReplacement ile gelmiş olabiliriz.
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
