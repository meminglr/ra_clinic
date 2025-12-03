import 'package:flutter/material.dart';

import '../services/auth_service.dart';

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
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        setState(() {
                          _isLoading = true;
                        });
                        await _authService.signIn(
                          _emailController.text,
                          _passwordController.text,
                        );
                        setState(() {
                          _isLoading = false;
                        });
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
                        await _authService.signUp(
                          _emailController.text,
                          _passwordController.text,
                        );
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                    Navigator.pop(context);
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
