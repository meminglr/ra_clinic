import 'package:flutter/material.dart';
import 'package:ra_clinic/hero2.dart';

class Hero1 extends StatefulWidget {
  const Hero1({super.key});

  @override
  State<Hero1> createState() => _Hero1State();
}

class _Hero1State extends State<Hero1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false, // Arka planın görünmesini sağlar
                transitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (BuildContext context, _, __) {
                  // Diyalog içeriğini döndürür
                  return const Hero2();
                },
                // Hero animasyonunun çalışması için RouteBuilder yeterlidir,
                // ek bir transitionBuilder'a gerek yoktur.
              ),
            );
          },
          child: Hero(
            tag: "hero1",
            child: Container(width: 30, height: 30, color: Colors.amber),
          ),
        ),
      ),
    );
  }
}
