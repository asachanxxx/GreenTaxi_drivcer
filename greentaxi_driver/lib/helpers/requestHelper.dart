import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestHelper {
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        String data = response.body;
        var decodedata = jsonDecode(data);
        return decodedata;
      } else {
        return "failed";
      }
    } catch (e) {
      return "failed";
    }
  }
}
