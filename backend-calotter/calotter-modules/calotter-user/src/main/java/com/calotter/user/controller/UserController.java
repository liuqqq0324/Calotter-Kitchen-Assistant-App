package com.calotter.user.controller;

import com.calotter.common.core.Result;
import com.calotter.user.controller.dto.*;
import com.calotter.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import com.calotter.user.service.JwtService;

/**
 * 用户控制器
 * 支持两种路径：
 * - /api/user/* (标准路径)
 * - /api/ums/user/* (兼容前端现有路径)
 */
@RestController
@RequestMapping({"/api/user", "/api/ums/user"})
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    private final JwtService jwtService;
    /**
     * 用户注册
     * POST /api/user/register
     */
    @PostMapping("/register")
    public Result<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = userService.register(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        }
    }
    
    /**
     * 用户登录
     * POST /api/user/login
     */
    @PostMapping("/login")
    public Result<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = userService.login(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        }
    }


    /**
     * 用户登出
     * POST /api/user/logout
     * 注意：JWT 是无状态的，这里主要验证 token 有效性并返回成功
     * 前端负责删除本地存储的 token
     */
    @PostMapping("/logout")
    public Result<String> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            // 提取 token
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                // 即使没有 token，也返回成功（前端可能已经删除了）
                return Result.success("Logged out successfully");
            }
            
            String token = authHeader.substring(7); // 移除 "Bearer " 前缀
            
            // 验证 token 是否有效（可选，主要用于日志记录）
            if (jwtService.validateToken(token)) {
                // Token 有效，可以在这里记录日志或执行其他操作
                // 注意：JWT 无法主动失效，除非使用黑名单机制
            }
            
            // 返回成功响应
            return Result.success("Logged out successfully");
        } catch (Exception e) {
            // 即使出错也返回成功，确保前端可以清理本地存储
            return Result.success("Logged out (local storage cleared)");
        }
    }
    
    /**
     * 获取用户信息
     * GET /api/user?id={userId}
     */
    @GetMapping
    public Result<UserResponse> getUserInfo(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            UserResponse response = userService.getUserInfo(targetUserId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("获取用户信息失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新用户信息
     * PUT /api/user?id={userId}
     */
    @PutMapping
    public Result<UserResponse> updateUserInfo(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId,
            @Valid @RequestBody UserRequest request) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            UserResponse response = userService.updateUserInfo(targetUserId, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("更新用户信息失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户偏好
     * GET /api/user/preferences
     */
    @GetMapping("/preferences")
    public Result<PreferencesResponse> getPreferences(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            PreferencesResponse response = userService.getUserPreferences(targetUserId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("获取用户偏好失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新用户偏好
     * PUT /api/user/preferences
     */
    @PutMapping("/preferences")
    public Result<PreferencesResponse> updatePreferences(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId,
            @Valid @RequestBody PreferencesRequest request) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            PreferencesResponse response = userService.updateUserPreferences(targetUserId, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("更新用户偏好失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户禁忌
     * GET /api/user/taboos
     */
    @GetMapping("/taboos")
    public Result<TaboosResponse> getTaboos(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            TaboosResponse response = userService.getUserTaboos(targetUserId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("获取用户禁忌失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新用户禁忌
     * PUT /api/user/taboos
     */
    @PutMapping("/taboos")
    public Result<TaboosResponse> updateTaboos(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId,
            @Valid @RequestBody TaboosRequest request) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            TaboosResponse response = userService.updateUserTaboos(targetUserId, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("更新用户禁忌失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户过敏
     * GET /api/user/allergies
     */
    @GetMapping("/allergies")
    public Result<AllergiesResponse> getAllergies(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            AllergiesResponse response = userService.getUserAllergies(targetUserId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("获取用户过敏失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新用户过敏
     * PUT /api/user/allergies
     */
    @PutMapping("/allergies")
    public Result<AllergiesResponse> updateAllergies(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId,
            @Valid @RequestBody AllergiesRequest request) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            AllergiesResponse response = userService.updateUserAllergies(targetUserId, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("更新用户过敏失败: " + e.getMessage());
        }
    }

    /**
     * 获取所有标准过敏源库
     * GET /api/user/standard-allergens
     */
    @GetMapping("/standard-allergens")
    public Result<java.util.List<com.calotter.common.core.domain.entity.RefAllergen>> getAllStandardAllergens() {
        try {
            java.util.List<com.calotter.common.core.domain.entity.RefAllergen> allergens = 
                    userService.getAllStandardAllergens();
            return Result.success(allergens);
        } catch (Exception e) {
            return Result.error("获取标准过敏源库失败: " + e.getMessage());
        }
    }
    
    /**
     * 从 Authorization header 或请求参数中获取用户ID
     */
    private Long getUserId(String authHeader, Long userId) {
        // 如果请求参数中提供了 userId，优先使用（用于测试或管理员操作）
        if (userId != null) {
            return userId;
        }
        
        // 否则从 JWT token 中提取
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new IllegalArgumentException("未提供有效的认证信息");
        }
        
        String token = authHeader.substring(7); // 移除 "Bearer " 前缀
        
        if (!jwtService.validateToken(token)) {
            throw new IllegalArgumentException("Token 无效或已过期");
        }
        
        Long extractedUserId = jwtService.extractUserId(token);
        if (extractedUserId == null) {
            throw new IllegalArgumentException("无法从 Token 中提取用户ID");
        }
        
        return extractedUserId;
    }
}
