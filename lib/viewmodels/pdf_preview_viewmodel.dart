import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PdfPreviewViewModel extends GetxController {
  late String pdfPath;
  late int imageCount;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    pdfPath = Get.arguments['pdfPath'];
    imageCount = Get.arguments['imageCount'];
    totalPages.value = imageCount;
    isLoading.value = false;
  }
}
