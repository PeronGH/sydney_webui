import 'dart:async';
import 'package:sydney_webui/utils/http/common.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:convert';

Stream<MessageEvent> postJsonAndParseSse(Uri url,
    {required Map<String, dynamic> data, Map<String, String>? headers}) async* {
  final lineStream =
      _postJsonAndGetLineStream(url, data: data, headers: headers);

  yield* parseLineStreamToSse(lineStream);
}

Stream<String> _postJsonAndGetLineStream(Uri url,
    {required Map<String, dynamic> data, Map<String, String>? headers}) {
  final xhr = HttpRequest();
  xhr.open('POST', url.toString());
  xhr.setRequestHeader('Content-Type', 'application/json');
  headers?.forEach((key, value) {
    xhr.setRequestHeader(key, value);
  });
  xhr.send(jsonEncode(data));

  final controller = StreamController<String>();

  var streamed = 0;
  void onNewChunk() {
    if (controller.isClosed) return;
    final res = xhr.responseText ?? '';
    if (res.length > streamed) {
      controller.add(res.substring(streamed));
      streamed = res.length;
    }
  }

  xhr.onReadyStateChange.listen((event) {
    if (controller.isClosed) return;
    if (xhr.readyState == HttpRequest.HEADERS_RECEIVED) {
      if (xhr.status != 200) {
        controller.addError(
          HttpRequestException(
            'Request failed with: ${xhr.status} ${xhr.statusText}',
          ),
        );
        controller.close();
      }
    } else if (xhr.readyState == HttpRequest.DONE) {
      onNewChunk();
      controller.close();
    }
  });

  xhr.onProgress.listen((_) => onNewChunk());

  return controller.stream.transform(const LineSplitter());
}
