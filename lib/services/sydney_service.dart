import 'package:sydney_webui/utils/http.dart';

class SydneyService {
  // Static fields
  static const _defaultBaseUrl = String.fromEnvironment("API_BASE_URL");
  static const _defaultAccessToken = String.fromEnvironment("API_ACCESS_TOKEN");
  static const _defaultCookies = String.fromEnvironment("API_COOKIES");

  // Instance fields
  var baseUrl = Uri.tryParse(_defaultBaseUrl);
  var accessToken = _defaultAccessToken;
  var cookies = _defaultCookies;

  Map<String, dynamic> _conversation = {};

  // Getters
  Uri? get _createConversationUrl => baseUrl?.resolve("/conversation/new");
  Uri? get _askStreamUrl => baseUrl?.resolve("/chat/stream");
  Map<String, String> get _authHeaders =>
      {"Authorization": "Bearer $accessToken"};

  // Helper Methods
  Future<void> _resetConversation() async {
    _conversation = await postAndDecodeJson(_createConversationUrl!,
        data: {"cookies": cookies}, headers: _authHeaders);
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
          "conversation": _conversation
        },
        headers: _authHeaders);
  }
}
