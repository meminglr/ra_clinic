import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunicationHelper {
  /// Genel SnackBar gösterme
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: isError ? Colors.red : Colors.blueGrey,
      ),
    );
  }

  /// Paylaşma

  static void shareCostumer(item) {
    SharePlus.instance.share(
      ShareParams(text: 'İsim: ${item.name}\nTelefon: ${item.phone}'),
    );
  }

  /// Normal telefon araması
  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      showSnackBar(
        context,
        'Telefon araması sırasında hata: $e',
        isError: true,
      );
    }
  }

  /// WhatsApp uygulamasını açar (mesaj boş)
  static Future<void> openWhatsApp(
    BuildContext context,
    String phoneNumber,
  ) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        showSnackBar(context, 'WhatsApp açılamıyor', isError: true);
      }
    } catch (e) {
      showSnackBar(context, 'WhatsApp açılırken hata: $e', isError: true);
    }
  }

  /// SMS uygulamasını açar (mesaj boş)
  static Future<void> openSmsApp(
    BuildContext context,
    String phoneNumber,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    // temiz numara (boşluk/parantez/+) kaldır
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Denenecek URI'ler (farklı cihazlarda farklı davranabiliyor)
    final uris = <Uri>[
      Uri(scheme: 'sms', path: cleaned), // sms:0555...
      Uri.parse('smsto:$cleaned'), // smsto:0555...
      Uri.parse('sms:$cleaned'), // alternatif
    ];

    for (final uri in uris) {
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return;
        }
      } catch (e) {
        // bir URI hata verirse döngü devam etsin, en son catch gösterilecek
      }
    }

    // Hepsi başarısızsa kullanıcıya göster
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'SMS uygulaması açılamıyor. Cihazınızda varsayılan bir SMS uygulaması olmayabilir veya emülatör kullanıyor olabilirsiniz.',
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  static Future<void> makeWhatsAppCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    // phoneNumber: 90555XXXXXXX formatında olacak
    final Uri whatsappCallUri = Uri.parse(
      'whatsapp://call?number=$phoneNumber',
    );

    try {
      if (await canLaunchUrl(whatsappCallUri)) {
        await launchUrl(whatsappCallUri, mode: LaunchMode.externalApplication);
      } else {
        // Eğer cihaz desteklemiyorsa WhatsApp sohbeti açarak fallback yapalım
        final Uri whatsappChatUri = Uri.parse('https://wa.me/$phoneNumber');
        if (await canLaunchUrl(whatsappChatUri)) {
          await launchUrl(
            whatsappChatUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          showSnackBar(
            context,
            'WhatsApp araması desteklenmiyor',
            isError: true,
          );
        }
      }
    } catch (e) {
      showSnackBar(context, 'WhatsApp arama sırasında hata: $e', isError: true);
    }
  }
}
