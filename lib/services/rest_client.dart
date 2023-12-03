import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../widgets/app/app.dart';

enum HttpMethod { get, post, delete, put, patch, options }

String _getMethodName(HttpMethod method) =>
    method.toString().split('.')[1].toUpperCase();

String? _getUserAgent() {
  if (packageInfo == null) return null;
  return '${packageInfo!.packageName}/${packageInfo!.version} '
      '(Dart/${Platform.version.split(' ').first})';
}

/// Base class for communication with REST APIs using
/// http package
abstract class RestClient {
  final Uri baseUrl;
  final Client client;

  String? userAgent;

  RestClient(
    this.baseUrl, {
    Client? client,
    this.userAgent,
  }) : client = client ?? SentryHttpClient() {
    ArgumentError.checkNotNull(baseUrl);
  }

  /// Sends a request with JSON
  /// body and receives a streamed response
  Future<StreamedResponse> streamRequest(
    HttpMethod method,
    String path, {
    Map<String, String?>? query,
    Map<String, String> headers = const {},
    Map<String, dynamic>? jsonBody,
    List<Map<String, dynamic>?>? jsonBodyList,
    List<String>? allowedNullFields,
    bool authenticate = false,
    bool optionalAuth = false,
  }) async {
    final request = Request(
      _getMethodName(method),
      baseUrl.resolveUri(Uri(path: path, queryParameters: query)),
    );

    userAgent ??= _getUserAgent();

    // Include relevant headers
    request.headers.addAll({
      if (userAgent != null) HttpHeaders.userAgentHeader: userAgent!,
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      ...headers,
    });

    // Clear-up null fields in body
    jsonBody?.removeWhere((key, val) =>
        val == null && !(allowedNullFields?.contains(key) ?? false));
    jsonBodyList?.removeWhere((map) => map == null);
    jsonBodyList?.forEach((map) => map!.removeWhere((key, val) =>
        val == null && !(allowedNullFields?.contains(key) ?? false)));

    if (jsonBody != null) {
      request.body = jsonEncode(jsonBody);
    }
    if (jsonBodyList != null) {
      request.body = jsonEncode(jsonBodyList);
    }

    return await client.send(request);
  }

  /// Sends an unstreamed request with JSON body and throws
  /// an expection when non-successful status code is returned
  ///
  /// Uses [streamRequest] internally.
  Future<Response> request(
    HttpMethod method,
    String path, {
    Map<String, String?>? query,
    Map<String, String> headers = const {},
    Map<String, dynamic>? jsonBody,
    List<Map<String, dynamic>?>? jsonBodyList,
    List<String>? allowedNullFields,
    bool authenticated = false,
    bool optionalAuth = false,
  }) async =>
      await Response.fromStream(
        await streamRequest(
          method,
          path,
          query: query,
          headers: headers,
          jsonBody: jsonBody,
          jsonBodyList: jsonBodyList,
          authenticate: authenticated,
          optionalAuth: optionalAuth,
        ),
      );

  T convertToObject<T>(
      Response response, T Function(dynamic) fromJsonFunction) {
    final object = convertToOptionalObject(response, fromJsonFunction);
    final url = response.request?.url;
    if (object == null) {
      throw Exception('Expected non-nullable response to $url'
          ', fetched null instead.');
    }
    return object;
  }

  List<T> convertToList<T>(
      Response response, T Function(dynamic) fromJsonFunction) {
    final object = convertToOptionalList(response, fromJsonFunction);
    final url = response.request?.url;
    if (object == null) {
      throw Exception('Expected non-nullable list response to $url'
          ', fetched null (not empty list) instead.');
    }
    return object;
  }

  T? convertToOptionalObject<T>(
      Response response, T Function(dynamic) fromJsonFunction) {
    if (response.statusCode == HttpStatus.noContent) return null;

    return fromJsonFunction(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  List<T>? convertToOptionalList<T>(
      Response response, T Function(dynamic) fromJsonFunction) {
    if (response.statusCode == HttpStatus.noContent) return [];

    return jsonDecode(utf8.decode(response.bodyBytes))
        .map<T>((dynamic i) => fromJsonFunction(i as Map<String, dynamic>))
        .toList() as List<T>?;
  }
}
