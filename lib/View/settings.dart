import 'package:flutter/material.dart';
import 'package:lds/l10n/app_localizations.dart';
import '../main.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  bool _isArabic = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      _isArabic = locale == 'ar';
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });

    final Locale newLocale = _isArabic ? Locale('ar') : Locale('en');
    MyApp.setLocale(context, newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context, 'Settings'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,

        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height:20),
            Text(
              AppLocalizations.of(context, 'language_switch_message'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SwitchListTile(
              value: _isArabic,
              onChanged: (value) {
                _toggleLanguage();
              },
              title: Text(
                _isArabic
                    ? AppLocalizations.of(context, 'switch_to_english')
                    : AppLocalizations.of(context, 'switch_to_arabic'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              secondary: Icon(
                _isArabic ? Icons.language : Icons.translate,
                color: Colors.blueAccent,
                size: 28,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}
