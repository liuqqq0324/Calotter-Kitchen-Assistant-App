// lib/services/standard_library_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_sous_chef/services/inventory_api_service.dart';
import 'package:personal_sous_chef/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:personal_sous_chef/services/auth_service.dart';

/// 标准库服务（支持缓存）
class StandardLibraryService {
  static const String _ingredientsCacheKey = 'standard_ingredients_cache';
  static const String _allergensCacheKey = 'standard_allergens_cache';
  static const String _utensilsCacheKey = 'standard_utensils_cache';
  static const String _spicesCacheKey = 'standard_spices_cache';
  static const String _ingredientsCacheTimeKey = 'standard_ingredients_cache_time';
  static const String _allergensCacheTimeKey = 'standard_allergens_cache_time';
  static const String _utensilsCacheTimeKey = 'standard_utensils_cache_time';
  static const String _spicesCacheTimeKey = 'standard_spices_cache_time';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// 登录时预加载（后台异步，不阻塞登录流程）
  static Future<void> preloadOnLogin() async {
    // 不等待完成，后台静默加载所有标准库
    _loadAndCacheIngredients();
    _loadAndCacheAllergens();
    _loadAndCacheUtensils();
    _loadAndCacheSpices();
  }

  /// 获取标准食材库（优先使用缓存）
  static Future<List<Map<String, dynamic>>> getStandardIngredients() async {
    // 1. 先检查缓存
    final cached = await _getCachedIngredients();
    if (cached != null && !_isCacheExpired(cached['timestamp'] as int?)) {
      return List<Map<String, dynamic>>.from(cached['data'] as List);
    }

    // 2. 缓存过期或不存在，请求最新数据
    return await _loadAndCacheIngredients();
  }

  /// 获取标准过敏源库（优先使用缓存）
  static Future<List<Map<String, dynamic>>> getStandardAllergens() async {
    // 1. 先检查缓存
    final cached = await _getCachedAllergens();
    if (cached != null && !_isCacheExpired(cached['timestamp'] as int?)) {
      return List<Map<String, dynamic>>.from(cached['data'] as List);
    }

    // 2. 缓存过期或不存在，请求最新数据
    return await _loadAndCacheAllergens();
  }

  /// 获取标准厨具库（优先使用缓存）
  static Future<List<Map<String, dynamic>>> getStandardUtensils() async {
    // 1. 先检查缓存
    final cached = await _getCachedUtensils();
    if (cached != null && !_isCacheExpired(cached['timestamp'] as int?)) {
      return List<Map<String, dynamic>>.from(cached['data'] as List);
    }

    // 2. 缓存过期或不存在，请求最新数据
    return await _loadAndCacheUtensils();
  }

  /// 获取标准调料库（优先使用缓存）
  static Future<List<Map<String, dynamic>>> getStandardSpices() async {
    // 1. 先检查缓存
    final cached = await _getCachedSpices();
    if (cached != null && !_isCacheExpired(cached['timestamp'] as int?)) {
      return List<Map<String, dynamic>>.from(cached['data'] as List);
    }

    // 2. 缓存过期或不存在，请求最新数据
    return await _loadAndCacheSpices();
  }

  /// 检查缓存是否过期
  static bool _isCacheExpired(int? timestamp) {
    if (timestamp == null) return true;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) > _cacheExpiry;
  }

  /// 获取缓存的食材库
  static Future<Map<String, dynamic>?> _getCachedIngredients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_ingredientsCacheKey);
      final cacheTime = prefs.getInt(_ingredientsCacheTimeKey);
      
      if (cacheData != null && cacheTime != null) {
        return {
          'data': jsonDecode(cacheData),
          'timestamp': cacheTime,
        };
      }
    } catch (e) {
      print('[StandardLibraryService] Error reading ingredients cache: $e');
    }
    return null;
  }

  /// 获取缓存的过敏源库
  static Future<Map<String, dynamic>?> _getCachedAllergens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_allergensCacheKey);
      final cacheTime = prefs.getInt(_allergensCacheTimeKey);
      
      if (cacheData != null && cacheTime != null) {
        return {
          'data': jsonDecode(cacheData),
          'timestamp': cacheTime,
        };
      }
    } catch (e) {
      print('[StandardLibraryService] Error reading allergens cache: $e');
    }
    return null;
  }

  /// 加载并缓存标准食材库
  static Future<List<Map<String, dynamic>>> _loadAndCacheIngredients() async {
    try {
      final ingredients = await InventoryApiService.getAllStandardIngredients();
      
      // 保存到缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ingredientsCacheKey, jsonEncode(ingredients));
      await prefs.setInt(_ingredientsCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      return ingredients;
    } catch (e) {
      print('[StandardLibraryService] Error loading ingredients: $e');
      // 如果加载失败，尝试返回缓存（即使过期）
      final cached = await _getCachedIngredients();
      if (cached != null) {
        return List<Map<String, dynamic>>.from(cached['data'] as List);
      }
      rethrow;
    }
  }

  /// 加载并缓存标准过敏源库
  static Future<List<Map<String, dynamic>>> _loadAndCacheAllergens() async {
    try {
      final allergens = await _fetchStandardAllergens();
      
      // 保存到缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_allergensCacheKey, jsonEncode(allergens));
      await prefs.setInt(_allergensCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      return allergens;
    } catch (e) {
      print('[StandardLibraryService] Error loading allergens: $e');
      // 如果加载失败，尝试返回缓存（即使过期）
      final cached = await _getCachedAllergens();
      if (cached != null) {
        return List<Map<String, dynamic>>.from(cached['data'] as List);
      }
      rethrow;
    }
  }

  /// 从API获取标准过敏源库
  static Future<List<Map<String, dynamic>>> _fetchStandardAllergens() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/standard-allergens');
      final token = await AuthService.getToken();
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final responseData = data['data'];
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      } else {
        throw Exception(
          'Failed to get standard allergens: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// 获取缓存的厨具库
  static Future<Map<String, dynamic>?> _getCachedUtensils() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_utensilsCacheKey);
      final cacheTime = prefs.getInt(_utensilsCacheTimeKey);
      
      if (cacheData != null && cacheTime != null) {
        return {
          'data': jsonDecode(cacheData),
          'timestamp': cacheTime,
        };
      }
    } catch (e) {
      print('[StandardLibraryService] Error reading utensils cache: $e');
    }
    return null;
  }

  /// 获取缓存的调料库
  static Future<Map<String, dynamic>?> _getCachedSpices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_spicesCacheKey);
      final cacheTime = prefs.getInt(_spicesCacheTimeKey);
      
      if (cacheData != null && cacheTime != null) {
        return {
          'data': jsonDecode(cacheData),
          'timestamp': cacheTime,
        };
      }
    } catch (e) {
      print('[StandardLibraryService] Error reading spices cache: $e');
    }
    return null;
  }

  /// 加载并缓存标准厨具库
  static Future<List<Map<String, dynamic>>> _loadAndCacheUtensils() async {
    try {
      final utensils = await InventoryApiService.getAllStandardUtensils();
      
      // 保存到缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_utensilsCacheKey, jsonEncode(utensils));
      await prefs.setInt(_utensilsCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      return utensils;
    } catch (e) {
      print('[StandardLibraryService] Error loading utensils: $e');
      // 如果加载失败，尝试返回缓存（即使过期）
      final cached = await _getCachedUtensils();
      if (cached != null) {
        return List<Map<String, dynamic>>.from(cached['data'] as List);
      }
      rethrow;
    }
  }

  /// 加载并缓存标准调料库
  static Future<List<Map<String, dynamic>>> _loadAndCacheSpices() async {
    try {
      final spices = await InventoryApiService.getAllStandardSpices();
      
      // 保存到缓存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_spicesCacheKey, jsonEncode(spices));
      await prefs.setInt(_spicesCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      return spices;
    } catch (e) {
      print('[StandardLibraryService] Error loading spices: $e');
      // 如果加载失败，尝试返回缓存（即使过期）
      final cached = await _getCachedSpices();
      if (cached != null) {
        return List<Map<String, dynamic>>.from(cached['data'] as List);
      }
      rethrow;
    }
  }

  /// 清除缓存（用于手动刷新）
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ingredientsCacheKey);
    await prefs.remove(_allergensCacheKey);
    await prefs.remove(_utensilsCacheKey);
    await prefs.remove(_spicesCacheKey);
    await prefs.remove(_ingredientsCacheTimeKey);
    await prefs.remove(_allergensCacheTimeKey);
    await prefs.remove(_utensilsCacheTimeKey);
    await prefs.remove(_spicesCacheTimeKey);
  }
}

