import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  // Giriş Yapma Fonksiyonu
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text.trim(),
      );
      // Başarılı olursa AuthGate otomatik olarak HomePage'e yönlendirecek
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giriş başarılı!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);

        Navigator.pop(context);
      }
    }
  }

  // Kayıt Olma Fonksiyonu
  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Page')),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: Theme.of(
                      context,
                    ).textTheme.displayLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(hintText: 'Şifre'),
                  obscureText: true,
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (isLogin) {
                        _signIn();
                      } else {
                        _signUp();
                      }
                    }
                  },
                  label: _isLoading
                      ? CircularProgressIndicator(
                          constraints: BoxConstraints(
                            minHeight: 20,
                            minWidth: 20,
                          ),
                          color: Theme.of(context).colorScheme.surface,
                        )
                      : isLogin
                      ? const Text('Giriş Yap')
                      : const Text('Kayıt Ol'),
                ),
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin
                            ? "Hesabınız yok mu? Kayıt Olun"
                            : "Zaten bir hesabınız var mı? Giriş Yapın",
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Şifrenizi mi unuttunuz?"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
