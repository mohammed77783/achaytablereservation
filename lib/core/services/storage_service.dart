import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../errors/exceptions.dart';

/// Storage service for managing local data persistence
/// Uses FlutterSecureStorage for secure key-value storage with encryption
/// Provides methods for storing, retrieving, removing, and clearing data
/// All data is stored as JSON strings for complex types
class StorageService extends GetxService {
  late final FlutterSecureStorage _storage;
  bool _isInitialized = false;

  /// Initialize the storage service
  /// Must be called before using any other methods
  /// Throws [CacheException] if initialization fails
  Future<StorageService> init() async {
    try {
      const androidOptions = AndroidOptions(encryptedSharedPreferences: true);
      _storage = const FlutterSecureStorage(aOptions: androidOptions);
      _isInitialized = true;
      return this;
    } catch (e) {
      throw CacheException('Failed to initialize storage: ${e.toString()}');
    }
  }

  /// Check if storage is initialized
  bool get isInitialized => _isInitialized;

  /// Write data to storage
  /// [key] - The storage key
  /// [value] - The value to store (will be JSON encoded for complex types)
  /// Throws [CacheException] if write operation fails
  Future<void> write(String key, dynamic value) async {
    _ensureInitialized();
    try {
      String stringValue;
      if (value is String) {
        stringValue = value;
      } else if (value is int || value is double || value is bool) {
        stringValue = value.toString();
      } 
      else {
        // For complex types (Map, List, custom objects), encode as JSON
        stringValue = jsonEncode(value);
      }
      await _storage.write(key: key, value: stringValue);
    } 
    catch (e) {
      throw CacheException(
        'Failed to write data to storage for key "$key": ${e.toString()}',
      );
    }
  }

  /// Read data from storage
  /// [key] - The storage key
  /// Returns the stored value or null if not found
  /// Throws [CacheException] if read operation fails
  Future<T?> read<T>(String key) async {
    _ensureInitialized();
    try {
      final stringValue = await _storage.read(key: key);
      if (stringValue == null) {
        return null;
      }

      // Handle different types
      if (T == String) {
        return stringValue as T;
      } else if (T == int) {
        return int.parse(stringValue) as T;
      } else if (T == double) {
        return double.parse(stringValue) as T;
      } else if (T == bool) {
        return (stringValue.toLowerCase() == 'true') as T;
      } else {
        // For complex types, decode from JSON
        return jsonDecode(stringValue) as T;
      }
    } catch (e) {
      throw CacheException(
        'Failed to read data from storage for key "$key": ${e.toString()}',
      );
    }
  }

  /// Remove data from storage
  /// [key] - The storage key to remove
  /// Throws [CacheException] if remove operation fails
  Future<void> remove(String key) async {
    _ensureInitialized();
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw CacheException(
        'Failed to remove data from storage for key "$key": ${e.toString()}',
      );
    }
  }

  /// Clear all data from storage
  /// Throws [CacheException] if clear operation fails
  Future<void> clear() async {
    _ensureInitialized();
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException('Failed to clear storage: ${e.toString()}');
    }
  }

  /// Check if a key exists in storage
  /// [key] - The storage key to check
  /// Returns true if the key exists, false otherwise
  Future<bool> hasData(String key) async {
    _ensureInitialized();
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      throw CacheException(
        'Failed to check if key exists in storage for key "$key": ${e.toString()}',
      );
    }
  }

  /// Get all keys in storage
  /// Returns a map of all storage keys and values
  Future<Map<String, String>> getAll() async {
    _ensureInitialized();
    try {
      return await _storage.readAll();
    } catch (e) {
      throw CacheException('Failed to get all storage data: ${e.toString()}');
    }
  }

  /// Get all keys in storage
  /// Returns a list of all storage keys
  Future<List<String>> getKeys() async {
    _ensureInitialized();
    try {
      final all = await _storage.readAll();
      return all.keys.toList();
    } catch (e) {
      throw CacheException('Failed to get storage keys: ${e.toString()}');
    }
  }

  /// Ensure storage is initialized before operations
  /// Throws [CacheException] if not initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw CacheException(
        'Storage service not initialized. Call init() first.',
      );
    }
  }
}
