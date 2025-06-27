import 'dart:convert';
import 'dart:io';


class JsonUtils {
  static String base64AndGzip(Map<String, dynamic> map) {
    final offerJson = jsonEncode(map);
    final offerGzip = gzip.encode(utf8.encode(offerJson));
    return base64.encode(offerGzip);
  }

  static Map<String, dynamic> unBase64AndGzip(String str) {
    final gzipped = base64.decode(str);
    final jsonBytes = gzip.decode(gzipped);
    final jsonString = utf8.decode(jsonBytes);
    return json.decode(jsonString);
  }
}