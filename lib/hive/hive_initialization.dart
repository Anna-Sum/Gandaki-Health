import 'package:hive_flutter/hive_flutter.dart';

class MyHiveService {
  Box<String>? _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<void> _openBox() async {
    if (_userBox == null || !_userBox!.isOpen) {
      _userBox = await Hive.openBox<String>('userBox');
    }
  }

  Future<void> putData(
      {required String boxName,
      required String key,
      required String value}) async {
    await _openBox();
    await _userBox!.put(key, value);
  }

  Future<String?> getData(
      {required String boxName, required String key}) async {
    await _openBox();
    return _userBox!.get(key);
  }

  Future<void> deleteData(
      {required String boxName, required String key}) async {
    await _openBox();
    await _userBox!.delete(key);
  }

  Future<void> clearBox({required String boxName}) async {
    await _openBox();
    await _userBox!.clear();
  }

  Future<void> closeBox({required String boxName}) async {
    await _openBox();
    await _userBox!.close();
  }
}
