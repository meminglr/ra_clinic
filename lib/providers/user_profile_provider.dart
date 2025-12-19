import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ra_clinic/model/business_owner_profile.dart';
import 'package:ra_clinic/services/webdav_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WebDavService _webDavService;

  BusinessOwnerProfile? _profile;
  BusinessOwnerProfile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isProfileComplete = true; // Varsayılan true, kontrol edince güncellenir
  bool get isProfileComplete => _isProfileComplete;

  UserProfileProvider(this._webDavService);

  // Profil Verisini Çek
  Future<void> fetchUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        // Doc varsa, içinde gerekli alanlar var mı diye bakmak lazım ama
        // şimdilik doc varsa profil var varsayıyoruz.
        // Ancak model dönüşümü yaparak alanları alalım.
        _profile = BusinessOwnerProfile.fromMap(doc.data()!, uid);

        // Eğer isim boşsa profil tamamlanmamış sayabiliriz
        if (_profile!.firstName.isEmpty) {
          _isProfileComplete = false;
        } else {
          _isProfileComplete = true;
        }
      } else {
        _isProfileComplete = false;
        _profile = null;
      }
    } catch (e) {
      print("Profil çekme hatası: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Profili Kaydet / Güncelle
  Future<void> saveUserProfile(
    BusinessOwnerProfile profile,
    File? photoFile,
  ) async {
    _isLoading = true;
    notifyListeners();

    String currentPhotoUrl = profile.photoUrl;

    try {
      // 1. Fotoğraf varsa WebDAV'a yükle
      if (photoFile != null) {
        // Folder: {uid}
        await _webDavService.ensurePath(profile.uid);

        String fileName = "profile_photo.jpg";
        String fullPath = "${profile.uid}/$fileName";

        // Byte'ları al
        final bytes = await photoFile.readAsBytes();
        await _webDavService.uploadFile(profile.uid, fileName, bytes);

        // URL oluştur
        currentPhotoUrl = _webDavService.getFileUrl(fullPath);
      }

      // 2. Modeli güncelle (yeni URL ile)
      final updatedProfile = profile.copyWith(photoUrl: currentPhotoUrl);

      // 3. Firestore'a yaz
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(
            updatedProfile.toMap(),
            SetOptions(
              merge: true,
            ), // Var olan diğer alanları (customer koleksiyonu vs) silmesin
          );

      _profile = updatedProfile;
      _isProfileComplete = true;
    } catch (e) {
      print("Profil kaydetme hatası: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _isProfileComplete = false;
    notifyListeners();
  }
}
