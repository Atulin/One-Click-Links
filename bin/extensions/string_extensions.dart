import '../lib/db_connection_data.dart';

extension StringExtensions on String {
  bool tryParseBool() {
    if (toLowerCase() == 'true')  return true;
    if (toLowerCase() == 'false') return false;
    return null;
  }

  DbConnectionData tryParseDbConnectionData() {
    var reg = r'mysql:\/\/(\w+)\:(\w+)\@(.+)\:(\d+)\/(\w+)';
    var regExp = RegExp(reg);
    var m = regExp.firstMatch(this);
    return DbConnectionData(
        m.group(1),
        m.group(2),
        m.group(3),
        int.tryParse(m.group(4)),
        m.group(5)
    );
  }
}
