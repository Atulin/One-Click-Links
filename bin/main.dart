import 'dart:async' show runZoned;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' show load, clean, env;
import 'package:shelf_static/shelf_static.dart';
import 'package:random_string/random_string.dart';

import 'lib/request_parser.dart';
import 'extensions/string_extensions.dart';
import 'models/link.dart';

Future<void> main() async {
  load();
  var domain = env['DOMAIN'];

  var portEnv = env['PORT'];
  var port = portEnv == null ? 3000 : int.parse(portEnv);

  var dbConnEnv = env['JAWSDB_MARIA_URL'] ?? '';
  var dbConn = dbConnEnv.tryParseDbConnectionData();
  clean();

  var pathToBuild = p.join(p.dirname(Platform.script.toFilePath()), '..', 'web');
  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');

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
    var link = Link(data['url']);
    var res = await link.Save(db);
    var resLink = await Link.Get(db, res.insertId);
    return Response.ok(jsonEncode(resLink));
  });

  app.get('/l/<nonce>', (Request request, String nonce) async {
    var link = await Link.GetByNonce(db, nonce);
    var redirect = Uri.decodeFull(link.url);
    var res = await link.Delete(db);
    return Response.found(redirect);
  });

  // Cascade the handler
  var handler = Cascade()
                .add(staticHandler)
                .add(app.handler)
                .handler;

  runZoned(() {
    io.serve(handler, '0.0.0.0', port);
    print('Serving on port $port');
  }, onError: (e, stackTrace) => print('Oh noes! $e $stackTrace'));
}
