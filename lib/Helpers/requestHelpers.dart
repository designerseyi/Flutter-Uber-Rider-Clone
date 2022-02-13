import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestHelpers {
  static Future<dynamic> getRequest(Uri url) async {
    http.Response response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);
        return decodeData;
      } else {
        return "failed";
      }
    } catch (err) {
      return "failed";
    }
  }
}
