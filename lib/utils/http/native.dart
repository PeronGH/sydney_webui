// This file is written due to a mistake
// It is neither used in the project
// nor will be maintained

import 'dart:convert';
import 'dart:io';
import 'package:sydney_webui/utils/http/common.dart';

extension HttpClientJsonExtension on HttpClient {
  Future<HttpClientResponse> postJson(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final request = await postUrl(url);

    // Set default headers and add any additional headers
    request.headers.set('Content-Type', 'application/json');
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Convert the JSON body to a string and write it to the request
    if (body != null) {
      request.write(jsonEncode(body));
    }

    // Send the request and return the response
    return await request.close();
  }
}

Stream<MessageEvent> postJsonAndParseSse(Uri url,
    {required Map<String, dynamic> data, Map<String, String>? headers}) async* {
  final httpClient = HttpClient();

  try {
    final response =
        await httpClient.postJson(url, headers: headers, body: data);

    // Check the status code for the response
    if (response.statusCode == HttpStatus.ok) {
      final lineStream =
          response.transform(utf8.decoder).transform(const LineSplitter());
      yield* parseLineStreamToSse(lineStream);
    } else {
      throw HttpRequestException(
          'Failed to post JSON. Status code: ${response.statusCode}, Reason: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw HttpRequestException('Exception occurred during POST request: $e');
  } finally {
    // Always close the HttpClient to free system resources
    httpClient.close();
  }
}
