import 'package:flutter/services.dart';

/// Türk telefon numarası formatını uygular:
/// "0 (AAA) BBB CC DD" (11 hane) veya "(AAA) BBB CC DD" (10 hane)
class AdaptiveTurkishPhoneFormatter extends TextInputFormatter {
  // Kalan rakamları 3-2-2 şeklinde gruplar (ör: 123 45 67)
  String _groupRest(String rest) {
    if (rest.isEmpty) return '';
    final buf = StringBuffer();
    int idx = 0;

    // İlk 3 hane (BBB)
    final firstTake = rest.length >= 3 ? 3 : rest.length;
    buf.write(rest.substring(idx, idx + firstTake));
    idx += firstTake;

    // Kalan ikişer gruplar (CC DD)
    while (rest.length - idx > 0) {
      buf.write(' ');
      final take = (rest.length - idx) >= 2 ? 2 : (rest.length - idx);
      buf.write(rest.substring(idx, idx + take));
      idx += take;
    }
    return buf.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakamları al
    final oldDigits = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Maksimum hane sınırlandırması
    final isLongForm = oldDigits.length == 11 || newDigits.startsWith('0');
    final maxLength = isLongForm ? 11 : 10;

    if (newDigits.length > maxLength) {
      newDigits = newDigits.substring(0, maxLength);
    }

    if (newDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 1. Yeni formatlanmış metni oluştur
    String formatted;
    final startsWithZero = newDigits.startsWith('0');

    if (startsWithZero) {
      // 0 ile başlıyorsa: 0 (AAA) BBB CC DD
      final rest = newDigits.substring(1);

      if (rest.isEmpty) {
        formatted = '0';
      } else if (rest.length < 3) {
        formatted = '0 ($rest';
      } else {
        final area = rest.substring(0, 3);
        final after = rest.length > 3 ? rest.substring(3) : '';
        final grouped = _groupRest(after);

        formatted = '0 ($area)';
        if (grouped.isNotEmpty) formatted += ' $grouped';
      }
    } else {
      // 0 ile başlamıyorsa: (AAA) BBB CC DD
      if (newDigits.length < 3) {
        formatted = '($newDigits';
      } else {
        final area = newDigits.substring(0, 3);
        final after = newDigits.length > 3 ? newDigits.substring(3) : '';
        final grouped = _groupRest(after);

        formatted = '($area)';
        if (grouped.isNotEmpty) formatted += ' $grouped';
      }
    }

    // 2. ⭐ Gelişmiş İmleç Konumu Hesaplama (Silme sorununun çözümü)

    // Eğer metin kısaldıysa (yani silme işlemi yapılıyorsa)
    if (newValue.text.length < oldValue.text.length) {
      // Silinen pozisyona yakın bir konuma at
      int newOffset = newValue.selection.end;

      // Eğer silme işlemi formatlanmış bir karakteri sildiyse (örneğin ')' karakterini)
      // ve formatlanmış metin ile eski metin uzunluğu farkı varsa imleci bir adım geri al.
      if (formatted.length < oldValue.text.length) {
        newOffset = newOffset.clamp(0, formatted.length);
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    }

    // Eğer metin uzadıysa (yani ekleme yapılıyorsa)
    // Yeni imleç pozisyonu, format karakterlerinin sayısını yansıtmalı.

    // Önceki rakam sayısındaki imleç konumu
    final newSelectionIndex = newValue.selection.end;

    // Yeni imleç konumunu bulmak için formatted string'i tara
    int newCursorOffset = 0;
    int digitCount = 0;

    for (int i = 0; i < formatted.length; i++) {
      if (formatted[i].contains(RegExp(r'[0-9]'))) {
        digitCount++;
      }

      // Kullanıcının girdiği son rakamın formatted string'deki pozisyonunu bul
      if (digitCount == newSelectionIndex) {
        newCursorOffset = i + 1; // Rakamdan sonraki pozisyon
        break;
      }

      // Maksimuma ulaşıldıysa (örneğin tam metnin sonu)
      newCursorOffset = formatted.length;
    }

    final selection = TextSelection.collapsed(offset: newCursorOffset);

    return TextEditingValue(text: formatted, selection: selection);
  }
}
