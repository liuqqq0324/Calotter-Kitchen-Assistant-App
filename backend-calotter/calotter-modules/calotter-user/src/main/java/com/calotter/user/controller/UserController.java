package com.calotter.user.controller;

import com.calotter.common.core.Result;
import com.calotter.user.controller.dto.*;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.service.UserHealthService;
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
    private final UserHealthService userHealthService;
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
     * 获取用户饮食习惯
     * GET /api/user/diet-habits
     */
    @GetMapping("/diet-habits")
    public Result<DietHabitsResponse> getDietHabits(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            DietHabitsResponse response = userService.getUserDietHabits(targetUserId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("获取用户饮食习惯失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新用户饮食习惯
     * PUT /api/user/diet-habits
     */
    @PutMapping("/diet-habits")
    public Result<DietHabitsResponse> updateDietHabits(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId,
            @Valid @RequestBody DietHabitsRequest request) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            DietHabitsResponse response = userService.updateUserDietHabits(targetUserId, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("更新用户饮食习惯失败: " + e.getMessage());
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
     * 搜索标准过敏源库（模糊查询）
     * GET /api/user/standard-allergens/search?name=pea&fuzzy=true
     */
    @GetMapping("/standard-allergens/search")
    public Result<java.util.List<com.calotter.common.core.domain.entity.RefAllergen>> searchStandardAllergens(
            @RequestParam("name") String name,
            @RequestParam(value = "fuzzy", defaultValue = "true") boolean fuzzy) {
        try {
            return Result.success(userService.searchStandardAllergens(name, fuzzy));
        } catch (Exception e) {
            return Result.error("搜索标准过敏源库失败: " + e.getMessage());
        }
    }

    /**
     * 获取标准饮食习惯库（diet habits）
     * GET /api/user/standard-diet-habits
     */
    @GetMapping("/standard-diet-habits")
    public Result<java.util.List<String>> getAllStandardDietHabits() {
        try {
            return Result.success(userService.getAllStandardDietHabits());
        } catch (Exception e) {
            return Result.error("获取标准饮食习惯库失败: " + e.getMessage());
        }
    }

    /**
     * 搜索标准饮食习惯库（diet habits）模糊查询
     * GET /api/user/standard-diet-habits/search?q=veg
     */
    @GetMapping("/standard-diet-habits/search")
    public Result<java.util.List<String>> searchStandardDietHabits(@RequestParam("q") String q) {
        try {
            return Result.success(userService.searchStandardDietHabits(q));
        } catch (Exception e) {
            return Result.error("搜索标准饮食习惯库失败: " + e.getMessage());
        }
    }

    /**
     * 搜索标准避免食材库（avoid ingredients）模糊查询
     * 这里复用标准食材库（StandardIngredient），用于限制用户只能选择标准值。
     * GET /api/user/standard-avoid-ingredients/search?name=veg&fuzzy=true
     */
    @GetMapping("/standard-avoid-ingredients/search")
    public Result<java.util.List<com.calotter.common.core.domain.entity.StandardIngredient>> searchStandardAvoidIngredients(
            @RequestParam("name") String name,
            @RequestParam(value = "fuzzy", defaultValue = "true") boolean fuzzy) {
        try {
            return Result.success(userService.searchStandardAvoidIngredients(name, fuzzy));
        } catch (Exception e) {
            return Result.error("搜索标准避免食材库失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户偏好（操作 User.preferences Map，包含两个大类：TASTE, CUISINE）
     * GET /api/user/preferences-map
     */
    @GetMapping("/preferences-map")
    public Result<com.calotter.user.controller.dto.UserPreferencesResponse> getPreferencesMap(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            com.calotter.user.controller.dto.UserPreferencesResponse response = 
                    userService.getUserPreferencesMap(targetUserId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("获取用户偏好失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新用户偏好（操作 User.preferences Map，包含两个大类：TASTE, CUISINE）
     * PUT /api/user/preferences-map
     */
    @PutMapping("/preferences-map")
    public Result<com.calotter.user.controller.dto.UserPreferencesResponse> updatePreferencesMap(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId,
            @Valid @RequestBody com.calotter.user.controller.dto.UserPreferencesRequest request) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            com.calotter.user.controller.dto.UserPreferencesResponse response = 
                    userService.updateUserPreferencesMap(targetUserId, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("更新用户偏好失败: " + e.getMessage());
        }
    }
    
    /**
     * 创建或更新健康目标
     * POST /api/user/health-goal
     */
    @PostMapping("/health-goal")
    public Result<HealthGoalResponse> createOrUpdateHealthGoal(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId,
            @Valid @RequestBody HealthGoalRequest request) {
        try {
            // 添加日志以便调试
            System.out.println("📥 Received health goal request:");
            System.out.println("   User ID: " + userId);
            System.out.println("   Goal Type: " + (request.getGoalType() != null ? request.getGoalType().name() : "null"));
            System.out.println("   Activity Level: " + request.getActivityLevel());
            
            Long targetUserId = getUserId(authHeader, userId);
            
            System.out.println("🔄 开始创建/更新健康目标");
            System.out.println("   用户ID: " + targetUserId);
            System.out.println("   目标类型: " + (request.getGoalType() != null ? request.getGoalType().name() : "null"));
            System.out.println("   活动水平: " + request.getActivityLevel());
            
            HealthGoal goal = userHealthService.createOrUpdateHealthGoal(
                    targetUserId,
                    request.getGoalType(),
                    request.getActivityLevel()
            );
            
            System.out.println("✅ 健康目标保存成功");
            System.out.println("   目标ID: " + goal.getId());
            System.out.println("   目标类型: " + (goal.getGoalType() != null ? goal.getGoalType().name() : "null"));
            System.out.println("   营养数据:");
            System.out.println("     卡路里: " + goal.getDailyCalories());
            System.out.println("     蛋白质: " + goal.getProtein() + "g");
            System.out.println("     脂肪: " + goal.getFat() + "g");
            System.out.println("     碳水: " + goal.getCarb() + "g");
            System.out.println("     纤维: " + goal.getFiber() + "g");
            
            // 转换为响应DTO
            HealthGoalResponse response = new HealthGoalResponse();
            response.setId(goal.getId());
            response.setGoalType(goal.getGoalType());
            response.setActivityLevel(goal.getActivityLevel());
            response.setStartWeight(goal.getStartWeight());
            response.setHeight(goal.getHeight());
            response.setAge(goal.getAge());
            response.setDailyCalories(goal.getDailyCalories());
            response.setProtein(goal.getProtein());
            response.setFat(goal.getFat());
            response.setCarb(goal.getCarb());
            response.setFiber(goal.getFiber());
            
            System.out.println("📤 返回给前端的响应数据:");
            System.out.println("   卡路里: " + response.getDailyCalories());
            System.out.println("   蛋白质: " + response.getProtein() + "g");
            System.out.println("   脂肪: " + response.getFat() + "g");
            System.out.println("   碳水: " + response.getCarb() + "g");
            System.out.println("   纤维: " + response.getFiber() + "g");
            
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("创建或更新健康目标失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户健康信息（含BMI）
     * GET /api/user/health-info
     */
    @GetMapping("/health-info")
    public Result<UserHealthInfoResponse> getHealthInfo(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "id", required = false) Long userId) {
        try {
            Long targetUserId = getUserId(authHeader, userId);
            UserHealthService.UserHealthInfo healthInfo = userHealthService.getUserHealthInfo(targetUserId);
            
            // 转换为响应DTO
            UserHealthInfoResponse response = new UserHealthInfoResponse();
            response.setBmi(healthInfo.getBmi());
            response.setGoalType(healthInfo.getGoalType());
            response.setDailyEnergy(healthInfo.getDailyEnergy());
            response.setDailyProtein(healthInfo.getDailyProtein());
            response.setDailyFat(healthInfo.getDailyFat());
            response.setDailyCarbohydrates(healthInfo.getDailyCarbohydrates());
            response.setDailyFiber(healthInfo.getDailyFiber());
            
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error("获取健康信息失败: " + e.getMessage());
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
