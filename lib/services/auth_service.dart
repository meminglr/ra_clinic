import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Şu anki kullanıcıyı getir (Oturum açık mı?)
  User? get currentUser => _auth.currentUser;

  // Oturum Durumunu Dinle (Stream)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- GİRİŞ YAP (Sign In) ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Hata mesajlarını Türkçeleştirebilirsin
      throw _hataCevir(e.code);
    }
  }

  // --- KAYIT OL (Sign Up) ---
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _hataCevir(e.code);
    }
  }

  // --- ÇIKIŞ YAP (Sign Out) ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Hata Kodlarını Anlaşılır Hale Getirme
  String _hataCevir(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Böyle bir kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz e-posta formatı.';
      case 'weak-password':
        return 'Şifre çok zayıf (en az 6 karakter olmalı).';
      default:
        return 'Bir hata oluştu: $code';
    }
  }
}