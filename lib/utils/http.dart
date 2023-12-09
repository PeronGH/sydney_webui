import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> postJson(
    {required Uri url,
    required Map<String, dynamic> data,
    Map<String, String>? headers}) async {
  final httpClient = HttpClient();

  try {
    final request = await httpClient.postUrl(url);

    // Set the content-type to application/json
    request.headers.contentType = ContentType.json;

    // Add any additional headers if provided
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });

    // Write the JSON data to the request
    request.write(json.encode(data));

    // Close the request and wait for the response
    var response = await request.close();

    // Check the status code for the response
    if (response.statusCode == HttpStatus.ok) {
      // Read and decode the response body
      var responseBody = await response.transform(utf8.decoder).join();
      var decodedResponse = json.decode(responseBody) as Map<String, dynamic>;
      return decodedResponse;
    } else {
      throw Exception(
          'Failed to post JSON. Status code: ${response.statusCode}, Reason: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Exception occurred during POST request: $e');
  } finally {
    // Always close the HttpClient to free system resources
    httpClient.close();
  }
}
