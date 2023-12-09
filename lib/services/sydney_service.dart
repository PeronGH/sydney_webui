import 'package:sydney_webui/utils/http.dart';

class SydneyService {
  // Static fields
  static const _defaultBaseUrl = String.fromEnvironment("API_BASE_URL");
  static const _defaultAccessToken = String.fromEnvironment("API_ACCESS_TOKEN");
  static const _defaultCookies = String.fromEnvironment("API_COOKIES");

  // Instance fields
  var _baseUrl = () {
    try {
      return Uri.parse(_defaultBaseUrl);
    } catch (_) {
      return null;
    }
  }();
  var _accessToken = _defaultAccessToken;
  var _cookies = _defaultCookies;

  Map<String, dynamic> _conversation = {};

  // Getters
  Uri? get _createConversationUrl => _baseUrl?.resolve("/conversation/new");
  Uri? get _askStreamUrl => _baseUrl?.resolve("/api/ask/stream");
  Map<String, String> get _authHeaders =>
      {"Authorization": "Bearer $_accessToken"};

  // Helper Methods
  Future<void> _resetConversation() async {
    _conversation = await postJson(
        url: _createConversationUrl!,
        data: {"cookies": _cookies},
        headers: _authHeaders);
  }

  // Methods
  SydneyService setBaseUrl(Uri baseUrl) {
    _baseUrl = baseUrl;
    return this;
  }

  SydneyService setAccessToken(String accessToken) {
    _accessToken = accessToken;
    return this;
  }

  SydneyService setCookies(String cookies) {
    _cookies = cookies;
    return this;
  }

  Stream<MessageEvent> askStream(
      {required String prompt, required String context}) async* {
    if (_conversation.isEmpty) {
      await _resetConversation();
    }

    // TODO: send request and parse SSE
  }
}

class MessageEvent {
  final String type;
  final String content;

  const MessageEvent(this.type, this.content);
}
