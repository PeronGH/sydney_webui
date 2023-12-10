import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';

class ImageUploadDialog extends StatelessWidget {
  const ImageUploadDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    final imageUrl = controller.sydneyService.imageUrl;

    final isUploading = false.obs;

    final textEditController = TextEditingController(text: imageUrl.value);
    textEditController.addListener(() {
      imageUrl.value = textEditController.text;
    });

    void uploadImage() async {
      isUploading.value = true;

      final file = await FilePicker.platform.pickFiles(type: FileType.image);
      if (file == null) {
        isUploading.value = false;
        return;
      }
      try {
        textEditController.text =
            await controller.sydneyService.uploadImage(file.files.first.bytes!);
      } catch (e) {
        Get.snackbar('Error occurred', e.toString());
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => ElevatedButton(
                      onPressed: isUploading.value
                          ? null
                          : () {
                              textEditController.clear();
                            },
                      child: const Text('Clear'),
                    )),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: uploadImage,
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
                      const Text('Upload Image')
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
