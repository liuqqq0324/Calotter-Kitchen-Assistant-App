// lib/services/inventory_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/services/auth_service.dart';

class InventoryApiService {
  /// Get user inventory list
  static Future<List<Map<String, dynamic>>> getInventory({
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/ims/inventory?userId=$userIdParam',
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to get inventory: ${response.statusCode} ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Unexpected response format');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Add inventory item
  static Future<Map<String, dynamic>> addInventory({
    required String name,
    required double quantity,
    required String unit,
    String? expiryDate,
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/ims/inventory?userId=$userIdParam',
      );
      final body = {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        if (expiryDate != null) 'expiry_date': expiryDate,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to add inventory: ${response.statusCode} ${response.body}',
        );
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update inventory item
  static Future<void> updateInventory({
    required String inventoryId,
    double? quantity,
    String? unit,
    String? expiryDate,
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/ims/inventory?userId=$userIdParam',
      );
      final body = <String, dynamic>{'inventory_id': inventoryId};
      if (quantity != null) body['quantity'] = quantity;
      if (unit != null) body['unit'] = unit;
      if (expiryDate != null) body['expiry_date'] = expiryDate;

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update inventory: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete inventory item
  static Future<void> deleteInventory({
    required String inventoryId,
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/ims/inventory?userId=$userIdParam',
      );
      final body = {'inventory_id': inventoryId};

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete inventory: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Toggle cookware availability
  static Future<Map<String, dynamic>> toggleCookware({
    required String cookwareId,
    String? name,
    String? userId,
  }) async {
    try {
      final userIdParam = userId ?? await AuthService.getUserId();
      if (userIdParam == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/ims/cookware/toggle?userId=$userIdParam',
      );
      final body = <String, dynamic>{'cookware_id': cookwareId};
      if (name != null) body['name'] = name;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to toggle cookware: ${response.statusCode} ${response.body}',
        );
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Toggle seasoning availability
  static Future<Map<String, dynamic>> toggleSeasoning({
    required String seasoningId,
    String? name,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/ims/seasoning/toggle',
      );
      final body = <String, dynamic>{'seasoning_id': seasoningId};
      if (name != null) body['name'] = name;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to toggle seasoning: ${response.statusCode} ${response.body}',
        );
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
