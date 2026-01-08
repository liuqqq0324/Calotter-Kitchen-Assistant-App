// lib/services/inventory_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:personal_sous_chef/services/auth_service.dart';

class InventoryApiService {
  /// Get headers with authorization
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get user inventory list
  /// 使用 householdId 获取库存列表
  static Future<List<Map<String, dynamic>>> getInventory({
    String? householdId,
  }) async {
    try {
      // ✅ 使用 householdId 而不是 userId
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      // ✅ 修改API路径：/api/inventory/ingredients?householdId={householdId}
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/ingredients?householdId=$householdIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        // 后端返回格式: {code: 200, message: "...", data: [...]}
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get inventory: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Add inventory item
  /// ⚠️ 注意：后端需要 standardIngredientId，但前端只传了 name
  /// 暂时简化处理：需要先有标准食材库数据，或者后端需要支持通过 name 查找
  static Future<Map<String, dynamic>> addInventory({
    required String name,
    required double quantity,
    required String unit,
    String? expiryDate,
    String? householdId,
    int? standardIngredientId, // ✅ 添加标准食材ID参数（可选）
  }) async {
    try {
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      // ⚠️ 如果 standardIngredientId 为空，暂时抛出错误
      // 后续可以添加通过 name 查找标准食材的功能
      if (standardIngredientId == null) {
        throw Exception(
          'Standard ingredient ID is required. '
          'Please select from standard ingredient library or backend needs to support name lookup.',
        );
      }

      // ✅ 修改API路径：/api/inventory/ingredients
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/ingredients',
      );

      // ✅ 适配后端 IngredientRequest 格式
      final body = {
        'householdId': int.parse(householdIdParam),
        'standardIngredientId': standardIngredientId,
        'quantity': quantity,
        'unit': unit,
        if (expiryDate != null)
          'expirationDate': expiryDate, // ✅ 字段名改为 expirationDate
        // location 可选，暂时不传
      };

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to add inventory: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update inventory item
  /// ⚠️ 注意：后端需要完整的 IngredientRequest，包括 householdId 和 standardIngredientId
  static Future<void> updateInventory({
    required String inventoryId,
    double? quantity,
    String? unit,
    String? expiryDate,
    String? householdId,
    int? standardIngredientId, // ✅ 如果需要更改食材类型
  }) async {
    try {
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      // ✅ 修改API路径：/api/inventory/ingredients/{id}
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/ingredients/$inventoryId',
      );

      // ✅ 适配后端 IngredientRequest 格式（所有字段都需要）
      final body = <String, dynamic>{
        'householdId': int.parse(householdIdParam),
        if (standardIngredientId != null)
          'standardIngredientId': standardIngredientId,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        if (expiryDate != null)
          'expirationDate': expiryDate, // ✅ 字段名改为 expirationDate
      };

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['code'] != 200) {
        throw Exception(
          'Failed to update inventory: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete inventory item
  /// ✅ 后端使用路径参数，不需要 body
  static Future<void> deleteInventory({required String inventoryId}) async {
    try {
      // ✅ 修改API路径：/api/inventory/ingredients/{id}
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/ingredients/$inventoryId',
      );

      final response = await http.delete(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['code'] != 200) {
        throw Exception(
          'Failed to delete inventory: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get all utensils (cookware) for a household
  /// 获取家庭的所有厨具
  /// GET /api/inventory/utensils?householdId={householdId}
  static Future<List<Map<String, dynamic>>> getUtensils({
    String? householdId,
  }) async {
    try {
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/utensils?householdId=$householdIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get utensils: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get all spices (seasonings) for a household
  /// 获取家庭的所有调料
  /// GET /api/inventory/spices?householdId={householdId}
  static Future<List<Map<String, dynamic>>> getSpices({
    String? householdId,
  }) async {
    try {
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/spices?householdId=$householdIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get spices: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Toggle cookware availability
  /// ✅ 修复：使用PATCH方法和路径参数
  /// PATCH /api/inventory/utensils/{id}/toggle
  static Future<Map<String, dynamic>> toggleCookware({
    required String cookwareId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/utensils/$cookwareId/toggle',
      );

      final response = await http.patch(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to toggle cookware: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Toggle seasoning availability
  /// ✅ 修复：使用PATCH方法和路径参数
  /// PATCH /api/inventory/spices/{id}/toggle
  static Future<Map<String, dynamic>> toggleSeasoning({
    required String seasoningId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/spices/$seasoningId/toggle',
      );

      final response = await http.patch(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to toggle seasoning: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== 标准食材库查询 ====================

  /// Search standard ingredients by name
  /// 通过名称查找标准食材
  /// - fuzzy=false: 精确匹配，返回单个结果
  /// - fuzzy=true: 模糊匹配，返回列表
  static Future<dynamic> searchStandardIngredients({
    required String name,
    bool fuzzy = false,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/standard-ingredients/search?name=${Uri.encodeComponent(name)}&fuzzy=$fuzzy',
      );

      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return data['data']; // 可能是单个对象或列表
      } else {
        throw Exception(
          'Failed to search standard ingredients: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Find standard ingredient by name (exact match)
  /// 通过名称精确查找标准食材，返回 ID
  static Future<int?> findStandardIngredientIdByName(String name) async {
    try {
      final result = await searchStandardIngredients(name: name, fuzzy: false);
      if (result is Map<String, dynamic> && result['id'] != null) {
        return result['id'] as int;
      }
      return null;
    } catch (e) {
      // 如果找不到，返回 null
      return null;
    }
  }

  /// Get all standard ingredients
  /// 获取所有标准食材列表
  static Future<List<Map<String, dynamic>>> getAllStandardIngredients() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/standard-ingredients',
      );

      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get standard ingredients: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get all standard utensils (cookware)
  /// 获取所有标准厨具列表
  static Future<List<Map<String, dynamic>>> getAllStandardUtensils() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/standard-utensils',
      );

      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get standard utensils: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get all standard spices (seasonings)
  /// 获取所有标准调料列表
  static Future<List<Map<String, dynamic>>> getAllStandardSpices() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/standard-spices',
      );

      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get standard spices: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// ✅ 获取标准食材的允许单位列表
  /// Get allowed units for a standard ingredient
  /// GET /api/inventory/standard-ingredients/{id}/allowed-units
  static Future<List<String>> getAllowedUnits(int standardIngredientId) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/standard-ingredients/$standardIngredientId/allowed-units',
      );

      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<String>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get allowed units: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a new utensil (cookware) in household
  /// 在家庭中创建新厨具
  /// POST /api/inventory/utensils
  static Future<Map<String, dynamic>> createUtensil({
    required int standardUtensilId,
    required bool isAvailable,
    String? remark,
    String? householdId,
  }) async {
    try {
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/utensils',
      );

      final body = {
        'householdId': int.parse(householdIdParam),
        'standardUtensilId': standardUtensilId,
        'isAvailable': isAvailable,
        if (remark != null) 'remark': remark,
      };

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to create utensil: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a new spice (seasoning) in household
  /// 在家庭中创建新调料
  /// POST /api/inventory/spices
  static Future<Map<String, dynamic>> createSpice({
    required int standardSpiceId,
    required bool isAvailable,
    String? remark,
    String? householdId,
  }) async {
    try {
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/spices',
      );

      final body = {
        'householdId': int.parse(householdIdParam),
        'standardSpiceId': standardSpiceId,
        'isAvailable': isAvailable,
        if (remark != null) 'remark': remark,
      };

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to create spice: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== 剩菜管理 ====================

  /// Get all leftovers for a household
  /// 获取家庭的所有剩菜
  /// GET /api/inventory/leftovers?householdId={householdId}
  static Future<List<Map<String, dynamic>>> getLeftovers({
    String? householdId,
  }) async {
    try {
      final householdIdParam =
          householdId ?? await AuthService.getHouseholdId();
      if (householdIdParam == null) {
        throw Exception('Household not found. Please register or login first.');
      }

      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/leftovers?householdId=$householdIdParam',
      );
      final response = await http.get(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get leftovers: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a leftover
  /// 删除剩菜
  /// DELETE /api/inventory/leftovers/{id}
  static Future<void> deleteLeftover({required String leftoverId}) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.inventoryBaseUrl}/api/inventory/leftovers/$leftoverId',
      );

      final response = await http.delete(url, headers: await _getHeaders());

      // ✅ 适配后端返回的 Result<T> 格式
      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['code'] != 200) {
        throw Exception(
          'Failed to delete leftover: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
