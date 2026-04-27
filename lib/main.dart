import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/screens/login/rf_gun_secim_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await initializeDateFormatting('tr_TR', null);


  runApp(
    const ProviderScope(
      child: FaureciaApp(),
    ),
  );
}

class FaureciaApp extends StatelessWidget {
  const FaureciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faurecia Barkod Takip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RfGunSecimScreen(),
    );
  }
}
