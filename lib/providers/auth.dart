import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:my_pensieve/enum/auth_mode.dart';
import 'package:my_pensieve/models/user.dart';
import 'package:my_pensieve/repositories/mongo_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  final _usersColl = 'users';
  final _userPref = 'userData';

  User _user = User();

  bool get isAuth {
    return _user.id != null;
  }

  User get user {
    return _user;
  }

  Future<void> authenticate(
      String email, String password, AuthMode authMode) async {
    var bytes = utf8.encode(password); // data being hashed
    var digest = sha256.convert(bytes);

    if (authMode == AuthMode.Signup) {
      await _signup(email, digest.toString());
    } else if (authMode == AuthMode.Login) {
      await _login(email, digest.toString());
    }

    if (_user.id != null && _user.id!.isNotEmpty) {
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode(_user.toMap());
      prefs.setString(_userPref, userData);
    } else {
      throw Exception('User not found');
    }
  }

  Future<void> _signup(String email, String password) async {
    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();

    try {
      List<Map<String, dynamic>> userData =
          await mongoRepository.find(_usersColl, {
        User.USERNAME: email,
      });

      if (userData.isEmpty) {
        String userId = await mongoRepository.insertOne(_usersColl, {
          User.USERNAME: email,
          'password': password,
          User.CREATED_DATE: DateTime.now().toUtc().toIso8601String(),
        });

        if (userId.isNotEmpty) {
          await _login(email, password);
        }
      } else {
        throw Exception('Cannot create with this username');
      }
    } catch (error) {
      rethrow;
    } finally {
      await mongoRepository.close();
    }
  }

  Future<void> _login(String email, String password) async {
    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();
    try {
      List<Map<String, dynamic>> userData =
          await mongoRepository.find(_usersColl, {
        'username': email,
        'password': password,
      });
      if (userData.isNotEmpty && userData.length == 1) {
        _user = User.fromMap(userData[0]);
      }
    } catch (error) {
      rethrow;
    } finally {
      await mongoRepository.close();
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userPref)) {
      return false;
    }
    final extractedUserData = jsonDecode(prefs.getString(_userPref)!);
    _user = User.fromMapPref(extractedUserData);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = User();

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userPref);
    prefs.clear();
  }
}
