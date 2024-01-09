import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';
import 'package:sydney_webui/widgets/image_upload_dialog.dart';

class PromptInput extends StatelessWidget {
  const PromptInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 256.0,
      ),
      child: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter):
              controller.submit,
          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
              controller.submit,
        },
        child: TextField(
          controller: controller.promptController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(color: colorScheme.onSurface),
          cursorOpacityAnimates: true,
          decoration: InputDecoration(
            hintText: 'Enter a prompt here',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                    onPressed: () => Get.dialog(const ImageUploadDialog()),
                    icon: Obx(() => Icon(
                        controller.sydneyService.imageUrl.isEmpty
                            ? Icons.add_photo_alternate_outlined
                            : Icons.image)))),
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(() => controller.isGenerating.value
                  ? IconButton(
                      onPressed: controller.sydneyService.cancelStream,
                      icon: const Icon(Icons.stop_circle))
                  : IconButton(
                      onPressed:
                          controller.canSubmit ? controller.submit : null,
                      icon: const Icon(Icons.send))),
            ),
          ),
          cursorColor: colorScheme.primary,
        ),
      ),
    );
  }
}
