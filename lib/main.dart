import 'package:doc_sync_1/Screens/home_screen.dart';
import 'package:doc_sync_1/theme_data/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'Screens/splash_screen.dart';

void main() {
  runApp(const DocSyncApp());
}

class DocSyncApp extends StatelessWidget {
  const DocSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: HomeScreen(),
    );
  }
}
