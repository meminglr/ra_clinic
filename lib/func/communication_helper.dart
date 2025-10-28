import 'package:flutter/material.dart';
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

  /// Normal telefon araması
  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        showSnackBar(context, 'Telefon araması açılamıyor', isError: true);
      }
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
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        showSnackBar(context, 'SMS uygulaması açılamıyor', isError: true);
      }
    } catch (e) {
      showSnackBar(context, 'SMS açılırken hata: $e', isError: true);
    }
  }
}
