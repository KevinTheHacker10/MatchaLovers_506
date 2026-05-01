import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:matcha_lovers_506/core/constants.dart';
import 'package:matcha_lovers_506/data/models/user_model.dart';
import 'package:matcha_lovers_506/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Repository for authentication operations
class AuthRepository {
  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  AuthRepository(this._prefs);

  /// Initialize with sample users
  Future<void> initializeSampleData() async {
    final users = await getAllUsers();
    if (users.isEmpty) {
      final now = DateTime.now();
      final sampleUsers = [
        UserModel(
          id: _uuid.v4(),
          username: 'admin',
          password: 'admin123',
          role: UserRole.admin,
          fullName: 'Administrador Principal',
          createdAt: now,
          updatedAt: now,
        ),
        UserModel(
          id: _uuid.v4(),
          username: 'mesero',
          password: 'mesero123',
          role: UserRole.waiter,
          fullName: 'Mesero Demo',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      
      for (var user in sampleUsers) {
        await _saveUser(user);
      }
      debugPrint('Sample users initialized');
    }
  }

  /// Login user
  Future<UserEntity?> login(String username, String password) async {
    try {
      final users = await getAllUsers();
      final user = users.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );
      
      await _prefs.setString(AppConstants.storageKeyCurrentUser, user.id);
      return user;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _prefs.remove(AppConstants.storageKeyCurrentUser);
  }

  /// Get current logged-in user
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userId = _prefs.getString(AppConstants.storageKeyCurrentUser);
      if (userId == null) return null;
      
      final users = await getAllUsers();
      return users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );
    } catch (e) {
      debugPrint('Get current user error: $e');
      return null;
    }
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final usersJson = _prefs.getStringList(AppConstants.storageKeyUsers) ?? [];
      return usersJson
          .map((json) => UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get all users error: $e');
      return [];
    }
  }

  /// Save user
  Future<void> _saveUser(UserModel user) async {
    try {
      final users = await getAllUsers();
      users.add(user);
      
      final usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
      await _prefs.setStringList(AppConstants.storageKeyUsers, usersJson);
    } catch (e) {
      debugPrint('Save user error: $e');
    }
  }

  /// Create new user (admin only)
  Future<UserEntity?> createUser({
    required String username,
    required String password,
    required UserRole role,
    required String fullName,
  }) async {
    try {
      final now = DateTime.now();
      final user = UserModel(
        id: _uuid.v4(),
        username: username,
        password: password,
        role: role,
        fullName: fullName,
        createdAt: now,
        updatedAt: now,
      );
      
      await _saveUser(user);
      return user;
    } catch (e) {
      debugPrint('Create user error: $e');
      return null;
    }
  }

  Future<void> updateUser(UserEntity copyWith, {String? newPassword}) async {}

  Future<void> deleteUser(String id) async {}
}
