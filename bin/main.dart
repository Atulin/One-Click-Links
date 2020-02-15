import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:async' show runZoned;
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' show load, clean, env;

import 'lib/request_parser.dart';
import 'extensions/string_extensions.dart';
import 'models/link.dart';

Future<void> main() async {
  load();
  var portEnv = env['PORT'];
  var port = portEnv == null ? 3000 : int.parse(portEnv);

  var dbConnEnv = env['JAWSDB_MARIA_URL'] ?? '';
  var dbConn = dbConnEnv.tryParseDbConnectionData();
  clean();

  // Setup database
  var dbSettings = ConnectionSettings(
      host: dbConn.host,
      port: dbConn.port,
      user: dbConn.username,
      password: dbConn.password,
      db: dbConn.database
  );
  var db = await MySqlConnection.connect(dbSettings);

  // Route
  var app = Router();

  app.post('/add', (Request request) async {
    var data = RequestParser.parse(request);
    var link = Link(data['nonce'], data['url']);
    var res = await link.Save(db);
    return Response.ok('Added');
  });

  app.get('/get', (Request request) async {
    var data = RequestParser.parse(request);
    var link = Link.GetByNonce(db, data['nonce']);
    return Response.ok((await link).url);
  });

  runZoned(() {
    io.serve(app.handler, '0.0.0.0', port);
    print('Serving on port $port');
  }, onError: (e, stackTrace) => print('Oh noes! $e $stackTrace'));
}
