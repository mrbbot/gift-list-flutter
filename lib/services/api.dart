import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:gift_list/services/auth_service.dart';
import 'package:http/http.dart' as http;

const _API_URL = "https://mrbbot.co.uk:7687";

final AuthService _authService = AuthService.instance;

Future<Map<String, String>> _getHeaders() async {
  return {
    HttpHeaders.AUTHORIZATION: await _authService.idToken(),
    HttpHeaders.CONTENT_TYPE: "application/json"
  };
}

class ApiResponse {
  final dynamic body;
  final int statusCode;

  ApiResponse({this.body, this.statusCode});
}

Future<ApiResponse> get(String route) async {
  print("GET $route");
  DateTime start = new DateTime.now();
  final http.Response response =
      await http.get("$_API_URL$route", headers: await _getHeaders());
  Duration duration = new DateTime.now().difference(start);
  print("GOT $route in ${duration.inMilliseconds}ms!");
  return new ApiResponse(
    body: json.decode(response.body),
    statusCode: response.statusCode,
  );
}

Future<ApiResponse> post(String route, Map<String, dynamic> data) async {
  print("POST $route");
  DateTime start = new DateTime.now();
  final http.Response response = await http.post("$_API_URL$route",
      headers: await _getHeaders(), body: json.encode(data));
  Duration duration = new DateTime.now().difference(start);
  print("POSTED $route in ${duration.inMilliseconds}ms!");
  return new ApiResponse(
    body: json.decode(response.body),
    statusCode: response.statusCode,
  );
}

Future<ApiResponse> delete(String route) async {
  print("DELETE $route");
  DateTime start = new DateTime.now();
  final http.Response response =
      await http.delete("$_API_URL$route", headers: await _getHeaders());
  Duration duration = new DateTime.now().difference(start);
  print("DELETED $route in ${duration.inMilliseconds}ms!");
  return new ApiResponse(
    body: json.decode(response.body),
    statusCode: response.statusCode,
  );
}
