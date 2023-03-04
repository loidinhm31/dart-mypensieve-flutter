import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/enum/auth_mode.dart';
import 'package:my_pensieve/repository/mongo_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _userId;

  bool get isAuth {
    return _userId != null;
  }

  String? get userId {
    return _userId;
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

    if (_userId!.isNotEmpty) {
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'userId': _userId,
        },
      );
      prefs.setString('userData', userData);
    }
  }

  Future<void> _signup(String email, String password) async {
    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();

    try {
      List<Map<String, dynamic>> userData =
          await mongoRepository.find('users', {
        'username': email,
      });

      if (userData.isEmpty) {
        String userId = await mongoRepository.insertOne('users', {
          'username': email,
          'password': password,
        });

        if (userId.isNotEmpty) {
          _userId = userId;
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
          await mongoRepository.find('users', {
        'username': email,
        'password': password,
      });
      if (userData.isNotEmpty && userData.length == 1) {
        _userId = (userData[0]['_id'] as ObjectId).$oid;
      }
    } catch (error) {
      rethrow;
    } finally {
      await mongoRepository.close();
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;

    _userId = extractedUserData['userId'] as String?;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _userId = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }
}
