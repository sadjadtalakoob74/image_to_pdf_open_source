import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'views/home_screen.dart';
import 'views/pdf_preview_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: (final context, final child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => HomeScreen()),
            GetPage(name: '/pdfPreview', page: () => PDFPreviewScreen()),
          ],
        );
      },
    );
  }
}
