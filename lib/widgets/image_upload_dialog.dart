import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:sydney_webui/controller.dart';

class ImageUploadDialog extends StatelessWidget {
  const ImageUploadDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    final imageUrl = controller.sydneyService.imageUrl;

    final isUploading = false.obs;

    final textEditController = TextEditingController(text: imageUrl.value);
    textEditController.addListener(() {
      if (imageUrl.value == textEditController.text) return;
      imageUrl.value = textEditController.text;
    });

    void pickAndUploadImage() async {
      isUploading.value = true;

      try {
        final result =
            await FilePicker.platform.pickFiles(type: FileType.image);

        if (result == null) {
          isUploading.value = false;
          Get.snackbar('Error occurred', 'No image selected');
          return;
        }

        textEditController.text = await controller.sydneyService
            .uploadImage(result.files.first.bytes!);
      } catch (e) {
        Get.snackbar('Error occurred', 'Failed to upload image: $e');
      } finally {
        isUploading.value = false;
      }
    }

    void pasteAndUploadImage() async {
      isUploading.value = true;

      try {
        final image = await Pasteboard.image;

        if (image == null) {
          isUploading.value = false;
          Get.snackbar('Error occurred', 'No image found in clipboard');
          return;
        }

        textEditController.text =
            await controller.sydneyService.uploadImage(image);
      } catch (e) {
        Get.snackbar('Error occurred', 'Failed to upload image: $e');
      } finally {
        isUploading.value = false;
      }
    }

    return AlertDialog(
      title: const Text('Image Upload'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextFormField(
              controller: textEditController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => ElevatedButton(
                        onPressed:
                            isUploading.value ? null : textEditController.clear,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear),
                            SizedBox(width: 8),
                            Text('Clear')
                          ],
                        ),
                      )),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: pickAndUploadImage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => isUploading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator())
                              : const Icon(Icons.upload_file),
                        ),
                        const SizedBox(width: 8),
                        const Text('Pick Image')
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: pasteAndUploadImage,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => isUploading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator())
                              : const Icon(Icons.paste),
                        ),
                        const SizedBox(width: 8),
                        const Text('Paste Image')
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
