import 'package:mysql1/mysql1.dart';
import 'package:random_string/random_string.dart';

class Link {
  int id;
  String nonce;
  String url;

  Link(this.url);
  Link.full(this.id, this.nonce, this.url);


  @override
  String toString() {
    return '[${id}] ${nonce} -> ${url}';
  }

  Future<Results> Save(MySqlConnection db) async {
    var nonce = randomAlphaNumeric(10);
    while (true) {
      var res = await GetByNonce(db, nonce);
      if (res == null) {
        break;
      } else {
        nonce = randomAlphaNumeric(10);
      }
    }
    return db.query('INSERT INTO links VALUES (null, ?, ?)', [nonce, url]);
  }

  Future<Results> Delete(MySqlConnection db) async {
    return db.query('DELETE FROM links WHERE id = ?', [id]);
  }

  static Future<Link> GetByNonce(MySqlConnection db, String nonce) async {
    var result = await db.query('SELECT * FROM links WHERE nonce = ?', [nonce]);
    if (result.isEmpty) return null;
    return Link.full(result.first[0], result.first[1], result.first[2]);
  }

  static Future<Link> Get(MySqlConnection db, int id) async {
    var result = await db.query('SELECT * FROM links WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    return Link.full(result.first[0], result.first[1], result.first[2]);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nonce': nonce,
    'url': Uri.decodeFull(url)
  };
}
