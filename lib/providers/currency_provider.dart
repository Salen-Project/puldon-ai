import 'package:flutter/foundation.dart';

enum Currency { usd, uzs }

class CurrencyProvider with ChangeNotifier {
  Currency _selectedCurrency = Currency.usd;
  static const double _exchangeRate = 12000.0; // 1 USD = 12,000 UZS

  Currency get selectedCurrency => _selectedCurrency;
  
  String get currencySymbol {
    switch (_selectedCurrency) {
      case Currency.usd:
        return '\$';
      case Currency.uzs:
        return 'so\'m';
    }
  }

  String get currencyCode {
    switch (_selectedCurrency) {
      case Currency.usd:
        return 'USD';
      case Currency.uzs:
        return 'UZS';
    }
  }

  String get currencyName {
    switch (_selectedCurrency) {
      case Currency.usd:
        return 'US Dollar';
      case Currency.uzs:
        return 'Uzbek Sum';
    }
  }

  void setCurrency(Currency currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  double convertAmount(double amountInUSD) {
    switch (_selectedCurrency) {
      case Currency.usd:
        return amountInUSD;
      case Currency.uzs:
        return amountInUSD * _exchangeRate;
    }
  }

  String formatAmount(double amountInUSD, {int decimalDigits = 0}) {
    final converted = convertAmount(amountInUSD);
    
    switch (_selectedCurrency) {
      case Currency.usd:
        return '\$${converted.toStringAsFixed(decimalDigits)}';
      case Currency.uzs:
        // Format with spaces for thousands separator
        final formatted = converted.toStringAsFixed(decimalDigits);
        final parts = formatted.split('.');
        final intPart = parts[0];
        final buffer = StringBuffer();
        
        for (int i = 0; i < intPart.length; i++) {
          if (i > 0 && (intPart.length - i) % 3 == 0) {
            buffer.write(' ');
          }
          buffer.write(intPart[i]);
        }
        
        if (parts.length > 1 && int.parse(parts[1]) > 0) {
          buffer.write('.${parts[1]}');
        }
        
        return '${buffer.toString()} so\'m';
    }
  }

  double getExchangeRate() => _exchangeRate;
}




