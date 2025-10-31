import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ContactsHelper {
  /// Basit vCard (VCF) oluşturucu — vCard 3.0 benzeri
 static Future<void> shareSimpleVCard(
    BuildContext context, {
    required String name,
    required String phone,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    try {
      // Numara temizleme (boşluk, +, tire vs. temizlenir)
      final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

      // vCard içeriği – Minimum valid format
      final vcard =
          '''
BEGIN:VCARD
VERSION:3.0
FN:$name
TEL;TYPE=CELL:$cleanedPhone
END:VCARD
''';

      // Dosyayı geçici dizine kaydet
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${name.replaceAll(" ", "_")}.vcf');

      await file.writeAsString(vcard, flush: true);

      // Paylaşım ekranını aç
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '$name kişisini paylaş');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Paylaşım hatası: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
