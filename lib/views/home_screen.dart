import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel = Get.put(HomeViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.r),
            child: ElevatedButton(
              onPressed: viewModel.pickImage,
              child: Row(
                children: [
                  const Text('Pick Images'),
                  SizedBox(
                    width: 4.r,
                  ),
                  Icon(UniconsLine.camera)
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
              () => Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GridView.builder(
                      itemCount: viewModel.images.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            Container(
                              width: 100.r,
                              height: 100.r,
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.r,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  File(viewModel.images[index].path),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor.withOpacity(.8),
                                  ),
                                  child: Icon(
                                    UniconsLine.multiply,
                                    color: Colors.white,
                                    size: 12.r,
                                  ),
                                ),
                                onTap: () => viewModel.removeImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1.r,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: viewModel.images.isEmpty ? null : viewModel.processPDFGeneration,
                        child: const Text('Generate PDF'),
                      ),
                      ElevatedButton(
                        onPressed: viewModel.pdfFile.value == null ? null : viewModel.previewPDF,
                        child: const Text('Preview PDF'),
                      ),
                      ElevatedButton(
                        onPressed: viewModel.pdfFile.value == null ? null : viewModel.sharePDF,
                        child: const Icon(UniconsLine.share),
                      ),
                    ],
                  ),
                ],
              ),
              if (viewModel.showLoading.value)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 8.r,
                      ),
                      Text('Loading...')
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
