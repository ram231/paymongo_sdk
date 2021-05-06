import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/utils/options.dart';

class PayMongoClient {
  final http.BaseClient _http;
  final String secret;
  PayMongoClient(
    this.secret, {
    http.BaseClient client,
  }) : _http = client ?? PayMongoHttp(secret);
  void close() {
    _http.close();
  }

  static String _payMongoUrl = 'api.paymongo.com';
  static set payMongoUrl(String url) => _payMongoUrl = url;
  T _request<T>(http.Response response, String path) {
    final json = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw HttpException(json['errors'], uri: response.request.url);
    }
    return json['data'];
  }

  Future<T> post<T>(PayMongoOptions options) async {
    final body = jsonEncode({"data": options.data});
    final response = await _http.post(
        Uri.https(_payMongoUrl, "v1${options.path}", options.params),
        body: body);
    return _request(response, options.path);
  }

  Future<T> get<T>(PayMongoOptions options) async {
    final uri = Uri.https(_payMongoUrl, "v1${options.path}", options.params);
    final response = await http.get(uri);
    return _request(response, options.path);
  }
}

class PayMongoHttp extends http.BaseClient {
  PayMongoHttp(this.apiKey);
  final String apiKey;
  final _client = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final bytes = utf8.encode(apiKey);
    final base64Str = base64.encode(bytes);
    final headers = {
      'Authorization': 'Basic $base64Str',
      'Content-Type': 'application/json'
    };

    request.headers.addAll(headers);
    return _client.send(request);
  }
}
