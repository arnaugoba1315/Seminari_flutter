import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';

class AuthService {
  bool isLoggedIn = false; // Variable para almacenar el estado de autenticación
  User? currentUser; // Variable para almacenar el usuario actual
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users';
    } else {
      return 'http://localhost:9000/api/users';
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final body = json.encode({'email': email, 'password': password});

    try {
      print("enviant solicitud post a: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("Resposta rebuda amb codi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        isLoggedIn = true;
        
        // Obtener los datos completos del usuario
        final userId = responseData['id'];
        await getCurrentUser(userId);
        
        return responseData;
      } else {
        return {'error': 'email o contrasenya incorrectes'};
      }
    } catch (e) {
      print("Error al fer la solicitud: $e");
      return {'error': 'Error de connexió'};
    }
  }

  Future<bool> getCurrentUser(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/$userId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        currentUser = User.fromJson(userData);
        print("Usuario obtenido: ${currentUser?.name}, ID: ${currentUser?.id}");
        return true;
      } else {
        print("Error al obtener usuario: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error al obtenir l'usuari: $e");
      return false;
    }
  }

  Future<bool> updateUser(String userId, String name, int age, String email) async {
    try {
      final url = Uri.parse('$_baseUrl/$userId');
      
      final body = json.encode({
        'name': name,
        'age': age,
        'email': email,
        'password': currentUser?.password ?? '',
      });
      
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        // Actualizar el usuario actual después de la actualización
        await getCurrentUser(userId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error al actualitzar l'usuari: $e");
      return false;
    }
  }

  Future<bool> changePassword(String userId, String newPassword) async {
    try {
      final url = Uri.parse('$_baseUrl/$userId');
      
      final body = json.encode({
        'name': currentUser?.name ?? '',
        'age': currentUser?.age ?? 0,
        'email': currentUser?.email ?? '',
        'password': newPassword,
      });
      
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        // Actualizar el usuario actual después de cambiar la contraseña
        await getCurrentUser(userId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error al canviar la contrasenya: $e");
      return false;
    }
  }

  void logout() {
    isLoggedIn = false; // Cambia el estado de autenticación a no autenticado
    currentUser = null; // Limpia el usuario actual
    print("Sessió tancada");
  }
}