
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> writeSecureData(String key, dynamic value) async {
    await storage.write(key:key, value:value);
  }
  Future<dynamic> readSecureData(String key) async {
    return await storage.read(key:key) ?? 'No such data';
  }


  deleteSecureData(String key) async {
    await storage.delete(key: key);
  }

}
