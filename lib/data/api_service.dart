import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/api_constants.dart';

// ─────────────────────────────────────────────────────────────
//  Typisierte API-Fehlerklassen
//  toString() gibt immer die lesbare Meldung zurück (nicht den Klassenname)
// ─────────────────────────────────────────────────────────────
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message; // ← Verhindert "Instance of 'NetworkException'"
}

class NetworkException extends ApiException {
  const NetworkException() : super('Keine Internetverbindung.');
}

class TimeoutException extends ApiException {
  const TimeoutException()
      : super('Server antwortet nicht. Bitte später versuchen.');
}

class ServerException extends ApiException {
  const ServerException(int code) : super('Serverfehler ($code).');
}

class ParseException extends ApiException {
  const ParseException() : super('Antwort konnte nicht verarbeitet werden.');
}

// ─────────────────────────────────────────────────────────────
//  ApiService – zentrale HTTP-Kommunikation
// ─────────────────────────────────────────────────────────────
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// GET-Request → gibt geparste JSON-Daten zurück.
  /// Wirft [ApiException]-Unterklassen bei Fehlern.
  Future<dynamic> get(String url) async {
    try {
      final uri      = Uri.parse(url);
      final response = await _client
          .get(uri, headers: {
            'Accept':     'application/json',
            'User-Agent': 'OPAPP/1.0',
          })
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw ServerException(response.statusCode);
      }
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on async.TimeoutException {
      throw const TimeoutException();
    } on FormatException {
      throw const ParseException();
    }
  }

  void dispose() => _client.close();
}
