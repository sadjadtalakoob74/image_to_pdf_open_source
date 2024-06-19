import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../viewmodels/pdf_preview_viewmodel.dart';

class PDFPreviewScreen extends StatelessWidget {
  final PdfPreviewViewModel viewModel = Get.put(PdfPreviewViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PDFView(
              filePath: viewModel.pdfPath,
              onViewCreated: (PDFViewController viewController) async {
                viewModel.totalPages.value = viewModel.imageCount;
                viewModel.isLoading.value = false;
              },
              onPageChanged: (int? page, int? total) {
                viewModel.currentPage.value = ((page ?? 0) + 1);
              },
              onError: (e) {
                print('Error while opening PDF: $e');
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              return viewModel.isLoading.value
                  ? const CircularProgressIndicator()
                  : Text('Page ${viewModel.currentPage.value} of ${viewModel.totalPages.value}');
            }),
          ),
        ],
      ),
    );
  }
}
