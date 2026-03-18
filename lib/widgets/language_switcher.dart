import 'package:flutter/material.dart';

class LanguageSwitcher extends StatefulWidget {
  final Function(Locale)? onLocaleChange;

  const LanguageSwitcher({super.key, this.onLocaleChange});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  Locale _currentLocale = const Locale('en', 'US');

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'en',
      'country': 'US',
      'name': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': 'es',
      'country': 'ES',
      'name': 'Español',
      'flag': '🇪🇸',
    },
    {
      'code': 'fr',
      'country': 'FR',
      'name': 'Français',
      'flag': '🇫🇷',
    },
    {
      'code': 'de',
      'country': 'DE',
      'name': 'Deutsch',
      'flag': '🇩🇪',
    },
    {
      'code': 'zh',
      'country': 'CN',
      'name': '中文',
      'flag': '🇨🇳',
    },
    {
      'code': 'ja',
      'country': 'JP',
      'name': '日本語',
      'flag': '🇯🇵',
    },
    {
      'code': 'ar',
      'country': 'SA',
      'name': 'العربية',
      'flag': '🇸🇦',
    },
    {
      'code': 'hi',
      'country': 'IN',
      'name': 'हिन्दी',
      'flag': '🇮🇳',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCurrentLanguage()['flag'] ?? '🇺🇸',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              _getCurrentLanguage()['code'].toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
      onSelected: (Locale locale) {
        setState(() {
          _currentLocale = locale;
        });
        widget.onLocaleChange?.call(locale);
      },
      itemBuilder: (context) => _languages.map((language) {
        return PopupMenuItem<Locale>(
          value: Locale(language['code'], language['country']),
          child: Row(
            children: [
              Text(
                language['flag'],
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      language['code'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (_currentLocale.languageCode == language['code'])
                Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _getCurrentLanguage() {
    return _languages.firstWhere(
      (lang) => lang['code'] == _currentLocale.languageCode,
      orElse: () => _languages.first,
    );
  }
}