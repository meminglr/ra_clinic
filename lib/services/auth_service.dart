import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase Auth instance'ını alıyoruz (yetkili kişi)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. KAYIT OLMA FONKSİYONU
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Hata olursa (örneğin: bu mail zaten kayıtlı, şifre çok zayıf)
      print("Kayıt Hatası: ${e.message}");
      return null;
    }
  }

  // 2. GİRİŞ YAPMA FONKSİYONU
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Hata olursa (örneğin: şifre yanlış, kullanıcı bulunamadı)
      print("Giriş Hatası: ${e.message}");
      return null;
    }
  }

  // 3. ÇIKIŞ YAPMA FONKSİYONU
  Future<void> signOut() async {
    await _auth.signOut();
  }
}