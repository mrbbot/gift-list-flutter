import 'package:test/test.dart';
import 'package:http/http.dart' as http;

const API_URL = "https://mrbbot.co.uk:7687";

void main() {
  test("http", () async {
    http.Response response = await http.get("$API_URL/friends");
    print(response.body);
  });
}