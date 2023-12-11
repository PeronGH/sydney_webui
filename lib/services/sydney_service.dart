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
  final noSearch = true.obs;
  final imageUrl = ''.obs;

  void Function()? _cancelStream;

  // Initializer
  SydneyService() {
    // Persist settings
    final box = GetStorage();

    // Load settings from storage
    apiBaseUrl.value = box.read('baseUrl') ?? _defaultBaseUrl;
    accessToken.value = box.read('accessToken') ?? _defaultAccessToken;
    cookies.value = box.read('cookies') ?? _defaultCookies;
    noSearch.value = box.read('noSearch') ?? true;

    // Save settings when they change
    ever(apiBaseUrl, (baseUrl) => box.write('baseUrl', baseUrl));
    ever(accessToken, (accessToken) => box.write('accessToken', accessToken));
    ever(cookies, (cookies) => box.write('cookies', cookies));
    ever(noSearch, (noSearch) => box.write('noSearch', noSearch));
  }

  // Getters
  Uri? get _askStreamUrl =>
      Uri.tryParse(apiBaseUrl.value)?.resolve("/chat/stream");

  Uri? get _uploadImageUrl =>
      Uri.tryParse(apiBaseUrl.value)?.resolve("/image/upload");

  Uri? get _createImageUrl =>
      Uri.tryParse(apiBaseUrl.value)?.resolve("/image/create");

  Map<String, String> get _authHeaders =>
      {"Authorization": "Bearer $accessToken"};

  // Methods
  Stream<MessageEvent> askStream(
      {required String prompt, required String context}) async* {
    final cancellable = postJsonAndParseSse(_askStreamUrl!,
        data: {
          "cookies": cookies.value,
          "prompt": prompt,
          "context": context,
          "noSearch": noSearch.value,
          "imageUrl": imageUrl.value
        },
        headers: _authHeaders);

    _cancelStream = cancellable.cancel;

    yield* cancellable.stream.asyncMap(
        (event) => MessageEvent(event.type, jsonDecode(event.content)));
  }

  Future<String> uploadImage(Uint8List image) async {
    final form = FormData({
      "cookies": cookies.value,
      "file": MultipartFile(image, filename: "image.png")
    });

    final resp =
        await post(_uploadImageUrl!.toString(), form, headers: _authHeaders);

    return resp.bodyString!;
  }

  Future<List<String>> getGenerativeImageUrls(
      Map<String, dynamic> generativeImage) async {
    final resp = await postJson(_createImageUrl!,
        data: {"image": generativeImage}, headers: _authHeaders);

    return (resp["image_urls"] as List<dynamic>)
        .cast<String>()
        .map((url) => url.split("?").first)
        .toList();
  }

  void cancelStream() {
    _cancelStream?.call();
  }
}
