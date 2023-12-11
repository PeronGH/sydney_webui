class MessageEvent {
  final String type;
  final String content;

  const MessageEvent(this.type, this.content);
}

Stream<MessageEvent> parseLineStreamToSse(Stream<String> lineStream) async* {
  var currentType = '';
  var currentData = '';

  // Read the response as a stream of Server-Sent Events
  await for (final line in lineStream) {
    if (line.startsWith('event:')) {
      currentType = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      currentData = line.substring(5).trim();
    } else if (line.isEmpty) {
      // Emit the event when an empty line is encountered
      if (currentType.isEmpty && currentData.isEmpty) continue;
      yield MessageEvent(currentType, currentData);
      currentType = ''; // Reset type to default for the next event
      currentData = '';
    }
  }
}

class HttpRequestException implements Exception {
  final String message;
  HttpRequestException(this.message);

  @override
  String toString() => message;
}

class CancellableStream<T> {
  final Stream<T> stream;
  final void Function() cancel;

  const CancellableStream(this.stream, this.cancel);
}
