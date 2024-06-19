import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/image_model.dart';

class HomeViewModel extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var images = <ImageModel>[].obs;
  var pdfFile = Rxn<File>();
  var showLoading = false.obs;

  Future<void> pickImage() async {
    if (Platform.isAndroid) {
      int sdkInt = await _getAndroidSdkInt();
      if (sdkInt >= 33) {
        await _requestMediaPermission();
      } else {
        await _requestStoragePermission();
      }
    } else {
      await _requestStoragePermission();
    }
  }

  Future<int> _getAndroidSdkInt() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  Future<void> _requestMediaPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      _pickImageProcess();
    } else {
      _showPermissionDeniedMessage();
    }
  }

  Future<void> _pickImageProcess() async {
    if (pdfFile.value != null) {
      bool clearPDF = await Get.dialog(
        AlertDialog(
          title: const Text('Clear Previous PDF? 🤔'),
          content: const Text('Are you sure you want to clear the existing PDF file and pick new images?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (clearPDF == null || !clearPDF) {
        return;
      }

      pdfFile.value = null;
    }

    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      images.value = selectedImages.map((xFile) => ImageModel(xFile.path)).toList();
    }
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      _pickImageProcess();
    } else {
      _showPermissionDeniedMessage();
    }
  }

  Future<void> processPDFGeneration() async {
    showLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    final pdf = pw.Document();
    for (var imageModel in images) {
      File imageFile = File(imageModel.path);
      final image = pw.MemoryImage(imageFile.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    final downloadsPath = await _getDownloadPath();
    if (downloadsPath != null) {
      final appNameFolder = Directory('$downloadsPath/ImageToPDF');
      if (!await appNameFolder.exists()) {
        await appNameFolder.create(recursive: true);
      }

      final dateFolderName = DateFormat('yyyy.MM.dd').format(DateTime.now());
      final dateFolder = Directory('${appNameFolder.path}/$dateFolderName');
      if (!await dateFolder.exists()) {
        await dateFolder.create(recursive: true);
      }

      final fileName = 'PDF_${_getFormattedDateTime()}.pdf';
      final file = File('${dateFolder.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      pdfFile.value = file;
      showLoading.value = false;
      Get.snackbar('Success', 'PDF saved to Download/ImageToPDF folder');
    } else {
      showLoading.value = false;
      Get.snackbar('Error', 'Failed to retrieve download directory.');
    }
  }

  String _getFormattedDateTime() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  Future<String?> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  void _showPermissionDeniedMessage() {
    showLoading.value = false;
    Get.snackbar('Error', 'Storage permission is required to save PDF.');
  }

  void sharePDF() {
    if (pdfFile.value != null) {
      Share.shareFiles([pdfFile.value!.path], text: 'Here is your generated PDF.');
    } else {
      Get.snackbar('Error', 'No PDF file available to share.');
    }
  }

  void previewPDF() {
    if (pdfFile.value != null) {
      Get.toNamed('/pdfPreview', arguments: {
        'pdfPath': pdfFile.value!.path,
        'imageCount': images.length,
      });
    } else {
      Get.snackbar('Error', 'No PDF file available to preview.');
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
    pdfFile.value = null;
  }
}
