import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sydney_webui/utils/http.dart';

class SydneyService {
  // Static fields
  static const _defaultBaseUrl = String.fromEnvironment("API_BASE_URL");
  static const _defaultAccessToken = String.fromEnvironment("API_ACCESS_TOKEN");
  static const _defaultCookies = String.fromEnvironment("API_COOKIES");

  // Instance fields
  final baseUrl = ''.obs;
  final accessToken = ''.obs;
  final cookies = ''.obs;
  final noSearch = false.obs;

  Map<String, dynamic> _conversation = {};

  // Initializer
  SydneyService() {
    // Persist settings
    final box = GetStorage();

    // Load settings from storage
    baseUrl.value = box.read('baseUrl') ?? _defaultBaseUrl;
    accessToken.value = box.read('accessToken') ?? _defaultAccessToken;
    cookies.value = box.read('cookies') ?? _defaultCookies;
    noSearch.value = box.read('noSearch') ?? false;

    // Save settings when they change
    ever(baseUrl, (baseUrl) => box.write('baseUrl', baseUrl));
    ever(accessToken, (accessToken) => box.write('accessToken', accessToken));
    ever(cookies, (cookies) => box.write('cookies', cookies));
    ever(noSearch, (noSearch) => box.write('noSearch', noSearch));
  }

  // Getters
  Uri? get _createConversationUrl =>
      Uri.tryParse(baseUrl.value)?.resolve("/conversation/new");

  Uri? get _askStreamUrl =>
      Uri.tryParse(baseUrl.value)?.resolve("/chat/stream");

  Map<String, String> get _authHeaders =>
      {"Authorization": "Bearer $accessToken"};

  // Helper Methods
  Future<void> _resetConversation() async {
    _conversation = await postAndDecodeJson(_createConversationUrl!,
        data: {"cookies": cookies.value}, headers: _authHeaders);
  }

  // Methods
  Stream<MessageEvent> askStream(
      {required String prompt, required String context}) async* {
    if (_conversation.isEmpty) {
      await _resetConversation();
    }

    yield* postJsonAndParseSse(_askStreamUrl!,
            data: {
              "prompt": prompt,
              "context": context,
              "conversation": _conversation,
              "noSearch": noSearch.value
            },
            headers: _authHeaders)
        .asyncMap(
            (event) => MessageEvent(event.type, jsonDecode(event.content)));
  }
}
