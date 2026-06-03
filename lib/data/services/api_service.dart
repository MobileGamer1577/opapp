import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Typisierte API-Fehlerklassen
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

class NetworkException extends ApiException {
  const NetworkException() : super('Keine Internetverbindung.');
}

class TimeoutException extends ApiException {
  const TimeoutException() : super('Server antwortet nicht. Bitte später versuchen.');
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

  /// Führt einen GET-Request durch und gibt das JSON zurück.
  /// Wirft eine [ApiException] bei Fehlern.
  Future<dynamic> get(String url) async {
    try {
      final uri      = Uri.parse(url);
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
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
    } on FormatException {
      throw const ParseException();
    }
    // TimeoutException wird nach oben weitergegeben
  }

  void dispose() => _client.close();
}
