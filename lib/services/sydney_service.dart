import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sydney_webui/utils/http.dart';

class SydneyService extends GetConnect {
  // Static fields
  static const _defaultBaseUrl = String.fromEnvironment("API_BASE_URL");
  static const _defaultAccessToken = String.fromEnvironment("API_ACCESS_TOKEN");
  static const _defaultCookies = String.fromEnvironment("API_COOKIES");

  // Instance fields
  final apiBaseUrl = ''.obs;
  final accessToken = ''.obs;
  final cookies = ''.obs;
  final noSearch = false.obs;
  final imageUrl = ''.obs;

  // Initializer
  SydneyService() {
    // Persist settings
    final box = GetStorage();

    // Load settings from storage
    apiBaseUrl.value = box.read('baseUrl') ?? _defaultBaseUrl;
    accessToken.value = box.read('accessToken') ?? _defaultAccessToken;
    cookies.value = box.read('cookies') ?? _defaultCookies;
    noSearch.value = box.read('noSearch') ?? false;

    // Save settings when they change
    ever(apiBaseUrl, (baseUrl) => box.write('baseUrl', baseUrl));
    ever(accessToken, (accessToken) => box.write('accessToken', accessToken));
    ever(cookies, (cookies) => box.write('cookies', cookies));
    ever(noSearch, (noSearch) => box.write('noSearch', noSearch));
  }

  // Getters
  Uri? get _createConversationUrl =>
      Uri.tryParse(apiBaseUrl.value)?.resolve("/conversation/new");

  Uri? get _askStreamUrl =>
      Uri.tryParse(apiBaseUrl.value)?.resolve("/chat/stream");

  Uri? get _uploadImageUrl =>
      Uri.tryParse(apiBaseUrl.value)?.resolve("/image/upload");

  Map<String, String> get _authHeaders =>
      {"Authorization": "Bearer $accessToken"};

  // Helper Methods
  Future<Map<String, dynamic>> _getConversation() async {
    final resp = await post(
        _createConversationUrl!.toString(), {"cookies": cookies.value},
        headers: _authHeaders);

    if (resp.statusCode != 200) {
      throw HttpRequestException(
          "Failed to create conversation: ${resp.status}");
    }

    return resp.body;
  }

  // Methods
  Stream<MessageEvent> askStream(
      {required String prompt, required String context}) async* {
    yield* postJsonAndParseSse(_askStreamUrl!,
            data: {
              "cookies": cookies.value,
              "prompt": prompt,
              "context": context,
              "conversation": await _getConversation(),
              "noSearch": noSearch.value,
              "imageUrl": imageUrl.value
            },
            headers: _authHeaders)
        .asyncMap(
            (event) => MessageEvent(event.type, jsonDecode(event.content)));
  }

  Future<String> uploadImage(Uint8List image) async {
    final form = FormData({
      "cookies": cookies.value,
      "file": MultipartFile(image, filename: "image.png")
    });

    final resp =
        await post(_uploadImageUrl!.toString(), form, headers: _authHeaders);

    if (resp.statusCode != 200) {
      throw HttpRequestException("Failed to upload image: ${resp.status}");
    }

    return resp.bodyString!;
  }
}
