// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;
// Package imports:
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../data/token_storage.dart';

class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;
  final Duration defaultTimeout;
  final int maxRetries;
  final void Function()? onUnauthorized;

  ApiClient({
    http.Client? client,
    TokenStorage? tokenStorage,
    this.defaultTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.onUnauthorized,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> _executeWithRetryAndTimeout(
    Future<http.Response> Function() requestFn,
  ) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        final response = await requestFn().timeout(defaultTimeout);
        if (response.statusCode == 401) {
          await _tokenStorage.clearAll();
          if (onUnauthorized != null) {
            onUnauthorized!();
          }
        }
        
        // Retry on 5xx errors
        if (response.statusCode >= 500 && attempts < maxRetries) {
          final backoff = Duration(milliseconds: 200 * (1 << attempts));
          await Future.delayed(backoff);
          continue;
        }
        return response;
      } catch (e) {
        // Retry on network/SocketException or timeout
        if (attempts < maxRetries && (e is SocketException || e is TimeoutException || e is http.ClientException)) {
          final backoff = Duration(milliseconds: 200 * (1 << attempts));
          await Future.delayed(backoff);
          continue;
        }
        rethrow;
      }
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) return null;
      return json.decode(responseBody);
    } else {
      Map<String, dynamic> errorMap = {};
      try {
        errorMap = json.decode(responseBody) as Map<String, dynamic>;
      } catch (_) {}

      final errorMessage =
          errorMap['error'] ?? errorMap['message'] ?? 'Network request failed';
      throw ApiException(message: errorMessage, statusCode: statusCode);
    }
  }

  Future<dynamic> get(String url, {bool includeAuth = true}) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await _executeWithRetryAndTimeout(() => _client.get(Uri.parse(url), headers: headers));
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: 503,
      );
    } on TimeoutException {
      throw const ApiException(
        message: 'Request timed out',
        statusCode: 408,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  Future<dynamic> post(
    String url, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);

      // Sanitize body to prevent "NaN" strings or empty numeric fields from causing 500 errors.
      dynamic sanitizedBody = body;
      if (body is Map) {
        sanitizedBody = Map.from(body).map((key, value) {
          // Fix actual NaN double values
          if (value is double && value.isNaN) return MapEntry(key, 0);

          // Fix "NaN" strings or empty strings for common numeric fields
          if (value is String) {
            final val = value.trim().toLowerCase();
            if (val == 'nan' || val.isEmpty) {
              final numericKeys = [
                'age',
                'height',
                'weight',
                'current_weight',
                'goal_weight',
                'duration',
                'bmi',
                'heart_rate',
                'heartrate',
                'pulse',
                'blood_pressure',
                'sets',
                'reps',
                'calories',
              ];
              if (numericKeys.contains(key.toLowerCase())) {
                if (val == 'nan' || val.isEmpty) return MapEntry(key, "0");
                // Strip units/text: "10 MIN" -> "10"
                final numericOnly = val.replaceAll(RegExp(r'[^0-9.]'), '');
                return MapEntry(key, numericOnly.isEmpty ? "0" : numericOnly);
              }
            }

            return MapEntry(key, value);
          }
          return MapEntry(key, value);
        });
      }

      final response = await _executeWithRetryAndTimeout(() => _client.post(
        Uri.parse(url),
        headers: headers,
        body: sanitizedBody != null ? json.encode(sanitizedBody) : null,
      ));
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: 503,
      );
    } on TimeoutException {
      throw const ApiException(
        message: 'Request timed out',
        statusCode: 408,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  Future<dynamic> put(
    String url, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await _executeWithRetryAndTimeout(() => _client.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ));
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: 503,
      );
    } on TimeoutException {
      throw const ApiException(
        message: 'Request timed out',
        statusCode: 408,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  Future<dynamic> uploadFile(
    String url,
    dynamic file, {
    bool includeAuth = true,
    String field = 'image',
  }) async {
    try {
      final response = await _executeWithRetryAndTimeout(() async {
        final headers = await _getHeaders(includeAuth: includeAuth);
        headers.remove('Content-Type');
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(headers);

        // Support multiple input types: dart:io File, XFile (image_picker), bytes/Uint8List, or path string
        if (kIsWeb) {
          // On web we expect either an XFile or raw bytes
          if (file is XFile) {
            final bytes = await file.readAsBytes();
            final multipart = http.MultipartFile.fromBytes(
              field,
              bytes,
              filename: file.name,
            );
            request.files.add(multipart);
          } else if (file is Uint8List || file is List<int>) {
            final multipart = http.MultipartFile.fromBytes(
              field,
              file as List<int>,
              filename: '${DateTime.now().millisecondsSinceEpoch}.png',
            );
            request.files.add(multipart);
          } else if (file is String) {
            // Blob URLs can't be uploaded from the client; the caller must provide an XFile or bytes
            throw const ApiException(
              message:
                  'Cannot upload from a path on web; provide an XFile or bytes',
              statusCode: 400,
            );
          } else {
            throw const ApiException(
              message: 'Unsupported file type for web upload',
              statusCode: 400,
            );
          }
        } else {
          // Native platforms: accept File, XFile, or path string
          if (file is File) {
            request.files.add(
              await http.MultipartFile.fromPath(field, file.path),
            );
          } else if (file is XFile) {
            request.files.add(
              await http.MultipartFile.fromPath(field, file.path),
            );
          } else if (file is String) {
            request.files.add(await http.MultipartFile.fromPath(field, file));
          } else if (file is Uint8List || file is List<int>) {
            final multipart = http.MultipartFile.fromBytes(
              field,
              file as List<int>,
              filename: '${DateTime.now().millisecondsSinceEpoch}.png',
            );
            request.files.add(multipart);
          } else {
            throw const ApiException(
              message: 'Unsupported file type for upload',
              statusCode: 400,
            );
          }
        }

        final streamedResponse = await request.send();
        return http.Response.fromStream(streamedResponse);
      });
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: 503,
      );
    } on TimeoutException {
      throw const ApiException(
        message: 'Request timed out',
        statusCode: 408,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  Future<dynamic> delete(String url, {bool includeAuth = true}) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await _executeWithRetryAndTimeout(() => _client.delete(Uri.parse(url), headers: headers));
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        message: 'No internet connection',
        statusCode: 503,
      );
    } on TimeoutException {
      throw const ApiException(
        message: 'Request timed out',
        statusCode: 408,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
