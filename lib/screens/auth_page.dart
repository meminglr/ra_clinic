import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FirebaseAuthProvider>(context);
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Giriş / Kayıt')),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (isLogin) {
                        try {
                          // 1. Firebase Girişi
                          await provider.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            context,
                          );
                          if (provider.currentUser != null) {
                            // 2. KRİTİK NOKTA: SyncProvider'a "Patron Geldi" de!
                            // Bu komut, misafirken eklenen tüm verileri alıp bu hesaba yükler.
                            context.read<SyncProvider>().init(
                              provider.currentUser!.uid,
                            );
                          }
                        } catch (e) {
                          // Hata yönetimi
                        }
                      } else {
                        provider.register(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          context,
                        );
                      }
                    }
                    Navigator.pop(context);
                  },
                  label: isLoading
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
