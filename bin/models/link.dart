import 'package:mysql1/mysql1.dart';

class Link {
  int id;
  String nonce;
  String url;

  Link(this.nonce, this.url);
  Link.full(this.id, this.nonce, this.url);

  Future<Results> Save(MySqlConnection db) async {
    return db.query('INSERT INTO links VALUES (null, ?, ?)', [nonce, url]);
  }

  static Future<Link> GetByNonce(MySqlConnection db, String nonce) async {
    var result = await db.query('SELECT * FROM links WHERE nonce = ?', [nonce]);
    return Link.full(result.first[0], result.first[1], result.first[2]);
  }
}
