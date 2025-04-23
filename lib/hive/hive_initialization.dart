import 'package:logging/logging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_model.dart';

final Logger _logger = Logger('MyHiveService');

class MyHiveService {
  Box<AuthModel>? _userBox;

  // Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AuthModelAdapter()); // Register the AuthModelAdapter
  }

  // Open the box asynchronously and cache it
  Future<void> _openBox() async {
    if (_userBox == null || !_userBox!.isOpen) {
      _userBox = await Hive.openBox<AuthModel>('user_credential');
    }
  }

  // Store data in the Hive box
  Future<void> putData({required String key, required AuthModel value}) async {
    try {
      await _openBox();
      await _userBox!.put(key, value);
    } catch (e) {
      _logger.severe("Error storing data in Hive: $e");
    }
  }

  // Retrieve data from the Hive box
  Future<AuthModel?> getData({required String key}) async {
    try {
      await _openBox();
      return _userBox!.get(key);
    } catch (e) {
      _logger.severe("Error retrieving data from Hive: $e");
      return null;
    }
  }

  // Delete specific data from the Hive box
  Future<void> deleteData({required String key}) async {
    try {
      await _openBox();
      await _userBox!.delete(key);
    } catch (e) {
      _logger.severe("Error deleting data from Hive: $e");
    }
  }

  // Clear all data from the Hive box
  Future<void> clearBox() async {
    try {
      await _openBox();
      await _userBox!.clear();
    } catch (e) {
      _logger.severe("Error clearing box: $e");
    }
  }

  // Close the Hive box
  Future<void> closeBox() async {
    try {
      await _openBox();
      await _userBox!.close();
    } catch (e) {
      _logger.severe("Error closing box: $e");
    }
  }

  // Checking if the box is open
  bool isBoxOpen() {
    return _userBox != null && _userBox!.isOpen;
  }
}
