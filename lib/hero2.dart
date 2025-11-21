import 'package:flutter/material.dart';

class Hero2 extends StatefulWidget {
  const Hero2({super.key});

  @override
  State<Hero2> createState() => _Hero2State();
}

class _Hero2State extends State<Hero2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: "hero2",
        child: Container(width: 100, height: 30, color: Colors.amber),
      ),
    );
  }
}
