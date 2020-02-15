import 'package:shelf/shelf.dart';
import '../extensions/string_extensions.dart';

class RequestParser {
  static Map<dynamic, dynamic> parse(Request request) {
    var query = request.requestedUri.query;
    var keyValPairs = query.split('&');

    var out = {};
    for (final pair in keyValPairs) {
      var kv = pair.split('=');

      var value =
             int.tryParse(kv[1])
          ?? double.tryParse(kv[1])
          ?? kv[1].tryParseBool()
          ?? kv[1];

      out.putIfAbsent(kv[0], () => value);
    }
    return out;
  }
}
