import 'dart:convert';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/utils/http.dart';

class SydneyService extends GetConnect {
  // Static fields
  static const _defaultBaseUrl = String.fromEnvironment("API_BASE_URL");
  static const _defaultAccessToken = String.fromEnvironment("API_ACCESS_TOKEN");
  static const _defaultCookies = String.fromEnvironment("API_COOKIES");
  static const _defaultNoSearch = true;
  static const _defaultUseGpt4Turbo = false;

  // Instance fields
  final apiBaseUrl = _defaultBaseUrl.obs;
  final accessToken = _defaultAccessToken.obs;
  final cookies = _defaultCookies.obs;
  final noSearch = _defaultNoSearch.obs;
  final useGpt4Turbo = _defaultUseGpt4Turbo.obs;
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
    noSearch.value = box.read('noSearch') ?? _defaultNoSearch;
    useGpt4Turbo.value = box.read('useGpt4Turbo') ?? _defaultUseGpt4Turbo;

    // Save settings when they change
    ever(apiBaseUrl, (baseUrl) => box.write('baseUrl', baseUrl));
    ever(accessToken, (accessToken) => box.write('accessToken', accessToken));
    ever(cookies, (cookies) => box.write('cookies', cookies));
    ever(noSearch, (noSearch) => box.write('noSearch', noSearch));
    ever(useGpt4Turbo,
        (useGpt4Turbo) => box.write('useGpt4Turbo', useGpt4Turbo));
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

  String get systemMessage => useGpt4Turbo.value
      ? Message.defaultGpt4TurboSystemMessage
      : Message.defaultSystemMessage;

  // Methods
  Stream<MessageEvent> askStream(
      {required String prompt, required String context}) async* {
    final cancellable = postJsonAndParseSse(_askStreamUrl!,
        data: {
          "cookies": cookies.value,
          "prompt": prompt,
          "context": context,
          "noSearch": noSearch.value,
          "imageUrl": imageUrl.value,
          "gpt4turbo": useGpt4Turbo.value
        },
        headers: _authHeaders);

    _cancelStream = cancellable.cancel;

    yield* cancellable.stream.asyncMap(
        (event) => MessageEvent(event.type, jsonDecode(event.content)));
  }

  Future<String> uploadImage(Uint8List bytes) async {
    final processImage = img.Command()
      ..decodeImage(bytes)
      ..encodeJpg(quality: 90);

    final imageResult = await processImage.executeThread();

    final image = imageResult.outputBytes;

    final form = FormData({
      "cookies": cookies.value,
      "file": MultipartFile(image, filename: "image.jpg")
    });

    final resp =
        await post(_uploadImageUrl!.toString(), form, headers: _authHeaders);

    if (resp.statusCode != 200) {
      throw Exception("Failed to upload image: ${resp.statusCode}");
    }

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
