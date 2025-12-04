import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _authService.currentUser;

  // Yükleniyor durumunu değiştir
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Giriş Fonksiyonu
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    try {
      await _authService.signIn(email, password);
      // Başarılı olursa authStateChanges tetiklenecek ve main.dart yönlendirmeyi yapacak.
      // O yüzden burada navigator.push yapmana gerek yok.
    } catch (e) {
      // Hata mesajını ekranda göster (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Kayıt Fonksiyonu
  Future<void> register(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    try {
      await _authService.signUp(email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hesap oluşturuldu!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }
}
