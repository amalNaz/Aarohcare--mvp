import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class LocalAuthRepository {
  LocalAuthRepository._();

  static final LocalAuthRepository instance = LocalAuthRepository._();

  static const _usersKey = 'registered_users';
  static const _currentUserKey = 'current_user';
  static const _isAdminSessionKey = 'is_admin_session';
  static const _adminSessionKey = 'admin_session';

  final ValueNotifier<List<UserProfile>> usersNotifier =
      ValueNotifier<List<UserProfile>>(<UserProfile>[]);

  Future<List<UserProfile>> _getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_usersKey) ?? <String>[];
      final users = <UserProfile>[];
      for (final entry in saved) {
        try {
          final decoded = jsonDecode(entry) as Map<String, dynamic>?;
          if (decoded != null) {
            users.add(UserProfile.fromJson(decoded));
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error deserializing user: $e');
          }
          continue;
        }
      }
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
      return <UserProfile>[];
    }
  }

  Future<void> _saveUsers(List<UserProfile> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_usersKey, encoded);
    usersNotifier.value = List<UserProfile>.unmodifiable(users);
  }

  Future<List<UserProfile>> getUsers() async {
    final users = await _getUsers();
    usersNotifier.value = List<UserProfile>.unmodifiable(users);
    return users;
  }

  Future<bool> registerUser(UserProfile user) async {
    final users = await _getUsers();
    final alreadyExists = users.any(
      (entry) => entry.phoneNumber == user.phoneNumber,
    );
    if (alreadyExists) return false;

    users.add(user);
    await _saveUsers(users);
    return true;
  }

  Future<bool> updateUser(UserProfile updatedUser) async {
    final users = await _getUsers();
    final index = users.indexWhere(
      (entry) => entry.phoneNumber == updatedUser.phoneNumber,
    );
    if (index == -1) return false;

    users[index] = updatedUser;
    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    final currentRaw = prefs.getString(_currentUserKey);
    if (currentRaw != null && currentRaw.isNotEmpty) {
      final currentUser = UserProfile.fromJson(
        jsonDecode(currentRaw) as Map<String, dynamic>,
      );
      if (currentUser.phoneNumber == updatedUser.phoneNumber) {
        await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
      }
    }

    return true;
  }

  Future<UserProfile?> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final users = await _getUsers();
      if (users.isEmpty) return null;

      final normalizedIdentifier = identifier.trim();
      final user = users.firstWhere(
        (entry) =>
            (entry.userName.toLowerCase() ==
                    normalizedIdentifier.toLowerCase() ||
                entry.phoneNumber == normalizedIdentifier) &&
            entry.password == password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      // Debug: user not found or password mismatch
      return null;
    }
  }

  Future<UserProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserKey);
    if (raw == null || raw.isEmpty) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> getIsAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminSessionKey) ?? false;
  }

  Future<void> setAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAdminSessionKey, true);
    await prefs.setString(_adminSessionKey, 'admin');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_isAdminSessionKey);
    await prefs.remove(_adminSessionKey);
  }
}
