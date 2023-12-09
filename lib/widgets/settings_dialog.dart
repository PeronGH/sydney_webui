import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    var apiBaseUrl = controller.sydneyService.baseUrl.value;
    var apiAccessToken = controller.sydneyService.accessToken.value;
    var apiCookies = controller.sydneyService.cookies.value;

    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextFormField(
              initialValue: apiBaseUrl,
              decoration: const InputDecoration(
                labelText: 'API Base URL',
              ),
              onChanged: (value) => apiBaseUrl = value,
            ),
            const SizedBox(height: 8.0), // Adds spacing between fields
            TextFormField(
              initialValue: apiAccessToken,
              decoration: const InputDecoration(
                labelText: 'API Access Token',
              ),
              onChanged: (value) => apiAccessToken = value,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              initialValue: apiCookies,
              decoration: const InputDecoration(
                labelText: 'API Cookies',
              ),
              onChanged: (value) => apiCookies = value,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            controller.sydneyService.baseUrl.value = apiBaseUrl;
            controller.sydneyService.accessToken.value = apiAccessToken;
            controller.sydneyService.cookies.value = apiCookies;
            Get.back();
          },
        ),
      ],
    );
  }
}
