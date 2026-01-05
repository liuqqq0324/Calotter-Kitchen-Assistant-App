package com.calotter.user.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import com.calotter.common.core.domain.entity.RefAllergen;
import com.calotter.user.controller.dto.*;
import com.calotter.user.controller.dto.UserPreferencesRequest;
import com.calotter.user.controller.dto.UserPreferencesResponse;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.RefAllergenRepository;
import com.calotter.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 用户服务
 */
@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final HouseholdService householdService;
    private final RefAllergenRepository refAllergenRepository;
    private final com.calotter.user.repository.HouseholdRepository householdRepository;
    
    /**
     * 用户注册
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // 检查用户名是否已存在
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("用户名已存在");
        }
        
        // 检查邮箱是否已存在
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("邮箱已被注册");
        }
        
        // 创建新用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        user.setRole("ROLE_USER");
        user.setStatus(1); // 1: 可用
        user.setIsOnboarded(false);
        
        // 保存用户
        user = userRepository.save(user);
        
        // 自动创建默认家庭
        Long householdId = null;
        try {
            HouseholdRequest householdRequest = new HouseholdRequest();
            householdRequest.setName(user.getUsername() + "'s Home");
            householdRequest.setOwnerId(user.getId());
            HouseholdResponse household = householdService.createHousehold(householdRequest);
            householdId = household.getId();
        } catch (Exception e) {
            // 如果创建家庭失败，记录日志但不影响注册流程
            // log.warn("Failed to create default household for user: " + user.getId(), e);
        }
        
        // 生成 JWT Token
        String token = jwtService.generateToken(user.getId(), user.getUsername());
        
        // 返回认证响应
        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .householdId(householdId)
                .build();
    }
    
    /**
     * 用户登录
     */
    public AuthResponse login(LoginRequest request) {
        // 查找用户（支持用户名或邮箱登录）
        User user = userRepository.findByUsername(request.getUsernameOrEmail())
                .orElseGet(() -> userRepository.findByEmail(request.getUsernameOrEmail())
                        .orElseThrow(() -> new IllegalArgumentException("用户名或密码错误")));
        
        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("用户名或密码错误");
        }
        
        // 检查用户状态
        if (user.getStatus() == 0) {
            throw new IllegalArgumentException("账户未激活，请联系管理员");
        }
        if (user.getStatus() == 2) {
            throw new IllegalArgumentException("账户已被封禁，请联系管理员");
        }
        
        // 生成 JWT Token
        String token = jwtService.generateToken(user.getId(), user.getUsername());
        
        // 获取用户的第一个家庭（如果有）
        Long householdId = null;
        try {
            List<HouseholdResponse> households = householdService.getHouseholdsByOwner(user.getId());
            if (!households.isEmpty()) {
                householdId = households.get(0).getId(); // 使用第一个家庭
            }
        } catch (Exception e) {
            // 如果获取家庭失败，householdId 保持为 null
        }
        
        // 返回认证响应
        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .householdId(householdId)
                .build();
    }
    
    /**
     * 获取用户信息
     */
    public UserResponse getUserInfo(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, Object> settings = user.getSettings();
        if (settings == null) {
            settings = new HashMap<>();
        }
        
        // 从 settings 中提取 profile，如果不存在则返回空 Map
        @SuppressWarnings("unchecked")
        Map<String, Object> profile = (Map<String, Object>) settings.getOrDefault("profile", new HashMap<>());
        
        // 同步 User 实体字段到 profile（优先使用实体字段）
        if (user.getBirthdate() != null) {
            profile.put("birthdate", user.getBirthdate().toString()); // ISO格式: YYYY-MM-DD
            // 计算年龄
            int age = calculateAge(user.getBirthdate());
            profile.put("age", age);
        }
        if (user.getGender() != null) {
            profile.put("gender", user.getGender().toString());
        }
        if (user.getCurrentHeight() != null) {
            profile.put("height", user.getCurrentHeight());
        }
        if (user.getCurrentWeight() != null) {
            profile.put("weight", user.getCurrentWeight().intValue());
        }
        
        return UserResponse.builder()
                .userId(user.getId())
                .userName(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .profile(profile)
                .build();
    }
    
    /**
     * 更新用户信息
     */
    @Transactional
    public UserResponse updateUserInfo(Long userId, UserRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, Object> settings = user.getSettings();
        if (settings == null) {
            settings = new HashMap<>();
        }
        
        // 更新 profile 信息并同步到 User 实体字段
        if (request.getProfile() != null) {
            Map<String, Object> profile = request.getProfile();
            
            // 同步 birthdate 到 User.birthdate
            Object birthdateObj = profile.get("birthdate");
            if (birthdateObj != null && !birthdateObj.toString().trim().isEmpty()) {
                try {
                    java.time.LocalDate birthdate = java.time.LocalDate.parse(birthdateObj.toString());
                    user.setBirthdate(birthdate);
                    // 计算并更新 age
                    int age = calculateAge(birthdate);
                    profile.put("age", age);
                } catch (Exception e) {
                    // 如果解析失败，忽略（不更新 birthdate）
                }
            } else {
                // 如果 birthdate 为空，清空 User.birthdate
                user.setBirthdate(null);
            }
            
            // 同步 gender 到 User.gender
            Object genderObj = profile.get("gender");
            if (genderObj != null && !genderObj.toString().trim().isEmpty()) {
                try {
                    Integer gender = parseGender(genderObj.toString());
                    user.setGender(gender);
                } catch (Exception e) {
                    // 如果解析失败，忽略
                }
            } else {
                user.setGender(null);
            }
            
            // 同步 height 到 User.currentHeight
            Object heightObj = profile.get("height");
            if (heightObj != null) {
                try {
                    Integer height = Integer.parseInt(heightObj.toString());
                    user.setCurrentHeight(height);
                } catch (NumberFormatException e) {
                    // 如果解析失败，忽略
                }
            } else {
                user.setCurrentHeight(null);
            }
            
            // 同步 weight 到 User.currentWeight
            Object weightObj = profile.get("weight");
            if (weightObj != null) {
                try {
                    java.math.BigDecimal weight = new java.math.BigDecimal(weightObj.toString());
                    user.setCurrentWeight(weight);
                } catch (NumberFormatException e) {
                    // 如果解析失败，忽略
                }
            } else {
                user.setCurrentWeight(null);
            }
            
            // 保存 profile 到 settings（用于向后兼容）
            settings.put("profile", profile);
        }
        
        user.setSettings(settings);
        user = userRepository.save(user);
        
        // 返回更新后的用户信息（从实体字段构建）
        @SuppressWarnings("unchecked")
        Map<String, Object> profile = (Map<String, Object>) user.getSettings().getOrDefault("profile", new HashMap<>());
        
        // 同步实体字段到 profile（确保返回最新数据）
        if (user.getBirthdate() != null) {
            profile.put("birthdate", user.getBirthdate().toString());
            profile.put("age", calculateAge(user.getBirthdate()));
        }
        if (user.getGender() != null) {
            profile.put("gender", user.getGender().toString());
        }
        if (user.getCurrentHeight() != null) {
            profile.put("height", user.getCurrentHeight());
        }
        if (user.getCurrentWeight() != null) {
            profile.put("weight", user.getCurrentWeight().intValue());
        }
        
        return UserResponse.builder()
                .userId(user.getId())
                .userName(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .profile(profile)
                .build();
    }
    
    /**
     * 计算年龄（基于出生日期）
     */
    private int calculateAge(java.time.LocalDate birthdate) {
        if (birthdate == null) {
            return 0;
        }
        return (int) java.time.temporal.ChronoUnit.YEARS.between(birthdate, java.time.LocalDate.now());
    }
    
    /**
     * 解析性别字符串为 Integer
     * 0: 未知, 1: 男, 2: 女
     */
    private Integer parseGender(String genderStr) {
        if (genderStr == null || genderStr.trim().isEmpty()) {
            return null;
        }
        String lower = genderStr.trim().toLowerCase();
        if (lower.equals("male") || lower.equals("男") || lower.equals("1") || lower.equals("m")) {
            return 1;
        } else if (lower.equals("female") || lower.equals("女") || lower.equals("2") || lower.equals("f")) {
            return 2;
        } else {
            return 0; // 未知
        }
    }
    
    /**
     * 获取用户偏好
     */
    public PreferencesResponse getUserPreferences(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, Object> settings = user.getSettings();
        if (settings == null) {
            settings = new HashMap<>();
        }
        
        // 从 settings 中提取 preferences，如果不存在则返回空 Map
        @SuppressWarnings("unchecked")
        Map<String, Object> preferences = (Map<String, Object>) settings.getOrDefault("preferences", new HashMap<>());
        
        return PreferencesResponse.builder()
                .preferences(preferences)
                .build();
    }
    
    /**
     * 更新用户偏好
     */
    @Transactional
    public PreferencesResponse updateUserPreferences(Long userId, PreferencesRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, Object> settings = user.getSettings();
        if (settings == null) {
            settings = new HashMap<>();
        }
        
        // 更新偏好信息
        Map<String, Object> preferences = new HashMap<>();
        if (request.getDietaryType() != null) {
            preferences.put("dietaryType", request.getDietaryType());
        }
        
        // 验证并过滤 cuisineTypes（只保留标准库中的值）
        if (request.getCuisineTypes() != null) {
            List<String> validCuisines = request.getCuisineTypes().stream()
                    .filter(cuisine -> PreferenceStandardLibrary.isValidCuisine(cuisine))
                    .collect(java.util.stream.Collectors.toList());
            
            // 如果有无效值，抛出异常
            List<String> invalidCuisines = request.getCuisineTypes().stream()
                    .filter(cuisine -> !PreferenceStandardLibrary.isValidCuisine(cuisine))
                    .collect(java.util.stream.Collectors.toList());
            
            if (!invalidCuisines.isEmpty()) {
                throw new IllegalArgumentException(
                    "无效的菜系偏好值: " + String.join(", ", invalidCuisines) + 
                    ". 请使用标准库中的值: " + String.join(", ", PreferenceStandardLibrary.CUISINE_OPTIONS)
                );
            }
            
            preferences.put("cuisineTypes", validCuisines);
            
            // 同步到 User.preferences["CUISINE"]（供 Cooking 模块使用）
            Map<String, List<String>> userPreferences = user.getPreferences();
            if (userPreferences == null) {
                userPreferences = new HashMap<>();
            }
            userPreferences.put(PreferenceStandardLibrary.PREF_KEY_CUISINE, validCuisines);
            user.setPreferences(userPreferences);
        }
        
        if (request.getSpiceLevel() != null) {
            preferences.put("spiceLevel", request.getSpiceLevel());
        }
        if (request.getCookingTimePreference() != null) {
            preferences.put("cookingTimePreference", request.getCookingTimePreference());
        }
        
        // 合并到 settings 中
        settings.put("preferences", preferences);
        user.setSettings(settings);
        user = userRepository.save(user);
        
        return PreferencesResponse.builder()
                .preferences((Map<String, Object>) user.getSettings().get("preferences"))
                .build();
    }
    
    /**
     * 获取用户禁忌
     * 从 dietaryStyles Map 的 TABOO 键中获取
     */
    public TaboosResponse getUserTaboos(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        // 从 dietaryStyles Map 中获取 TABOO 列表
        Map<String, List<String>> dietaryStyles = user.getDietaryStyles();
        List<String> taboos = new ArrayList<>();
        
        if (dietaryStyles != null && dietaryStyles.containsKey(PreferenceStandardLibrary.PREF_KEY_TABOO)) {
            taboos = dietaryStyles.get(PreferenceStandardLibrary.PREF_KEY_TABOO);
            if (taboos == null) {
                taboos = new ArrayList<>();
            }
        }
        
        return TaboosResponse.builder()
                .taboos(taboos)
                .build();
    }
    
    /**
     * 更新用户禁忌
     * 更新到 dietaryStyles Map 的 TABOO 键中
     */
    @Transactional
    public TaboosResponse updateUserTaboos(Long userId, TaboosRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        // 获取或创建 dietaryStyles Map
        Map<String, List<String>> dietaryStyles = user.getDietaryStyles();
        if (dietaryStyles == null) {
            dietaryStyles = DietaryStylesValidator.createEmptyMap();
        }
        
        // 验证并清理 taboos（确保值都是英文）
        List<String> taboos = request.getTaboos() != null ? request.getTaboos() : new ArrayList<>();
        List<String> cleanedTaboos = new ArrayList<>();
        for (String taboo : taboos) {
            if (taboo != null && !taboo.trim().isEmpty()) {
                // 检查是否包含中文字符
                if (!taboo.matches(".*[\\u4e00-\\u9fa5].*")) {
                    cleanedTaboos.add(taboo.trim().toLowerCase());
                }
            }
        }
        
        // 更新 dietaryStyles Map
        dietaryStyles.put(PreferenceStandardLibrary.PREF_KEY_TABOO, cleanedTaboos);
        user.setDietaryStyles(dietaryStyles);
        
        // 保存用户（会触发 @PreUpdate 钩子进行最终验证）
        user = userRepository.save(user);
        
        // 返回更新后的 taboos
        List<String> result = user.getDietaryStyles() != null 
                ? user.getDietaryStyles().getOrDefault(PreferenceStandardLibrary.PREF_KEY_TABOO, new ArrayList<>())
                : new ArrayList<>();
        
        return TaboosResponse.builder()
                .taboos(result)
                .build();
    }
    
    /**
     * 获取用户过敏
     */
    public AllergiesResponse getUserAllergies(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        List<RefAllergen> allergies = user.getAllergies();
        
        if (allergies == null || allergies.isEmpty()) {
            return AllergiesResponse.builder()
                    .allergies(new ArrayList<>())
                    .build();
        }
        
        // 转换为名称列表
        List<String> allergyNames = allergies.stream()
                .map(RefAllergen::getName)
                .collect(Collectors.toList());
        
        return AllergiesResponse.builder()
                .allergies(allergyNames)
                .build();
    }
    
    /**
     * 更新用户过敏
     */
    @Transactional
    public AllergiesResponse updateUserAllergies(Long userId, AllergiesRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        // 根据名称查找过敏原
        List<String> allergyNames = request.getAllergies() != null ? request.getAllergies() : new ArrayList<>();
        List<RefAllergen> allergens = refAllergenRepository.findByNameIn(allergyNames);
        
        // 更新过敏列表
        user.setAllergies(allergens);
        user = userRepository.save(user);
        
        // 转换为名称列表返回
        List<String> result = user.getAllergies() != null ? user.getAllergies().stream()
                .map(RefAllergen::getName)
                .collect(Collectors.toList()) : new ArrayList<>();
        
        return AllergiesResponse.builder()
                .allergies(result)
                .build();
    }

    /**
     * 获取所有标准过敏源库
     */
    public List<RefAllergen> getAllStandardAllergens() {
        return refAllergenRepository.findAll();
    }
    
    /**
     * 获取用户偏好（操作 User.preferences Map，包含两个大类：TASTE, CUISINE）
     */
    public UserPreferencesResponse getUserPreferencesMap(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, List<String>> preferences = user.getPreferences();
        return UserPreferencesResponse.fromMap(preferences);
    }
    
    /**
     * 更新用户偏好（操作 User.preferences Map，包含两个大类：TASTE, CUISINE）
     */
    @Transactional
    public UserPreferencesResponse updateUserPreferencesMap(Long userId, UserPreferencesRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, List<String>> preferences = user.getPreferences();
        if (preferences == null) {
            preferences = new HashMap<>();
        }
        
        // 更新 TASTE（验证标准库）
        if (request.getTastes() != null) {
            List<String> validTastes = request.getTastes().stream()
                    .filter(taste -> PreferenceStandardLibrary.isValidTaste(taste))
                    .collect(java.util.stream.Collectors.toList());
            
            List<String> invalidTastes = request.getTastes().stream()
                    .filter(taste -> !PreferenceStandardLibrary.isValidTaste(taste))
                    .collect(java.util.stream.Collectors.toList());
            
            if (!invalidTastes.isEmpty()) {
                throw new IllegalArgumentException(
                    "无效的口味偏好值: " + String.join(", ", invalidTastes) + 
                    ". 请使用标准库中的值: " + String.join(", ", PreferenceStandardLibrary.TASTE_OPTIONS)
                );
            }
            
            preferences.put(PreferenceStandardLibrary.PREF_KEY_TASTE, validTastes);
        }
        
        // 更新 CUISINE（验证标准库）
        if (request.getCuisines() != null) {
            List<String> validCuisines = request.getCuisines().stream()
                    .filter(cuisine -> PreferenceStandardLibrary.isValidCuisine(cuisine))
                    .collect(java.util.stream.Collectors.toList());
            
            List<String> invalidCuisines = request.getCuisines().stream()
                    .filter(cuisine -> !PreferenceStandardLibrary.isValidCuisine(cuisine))
                    .collect(java.util.stream.Collectors.toList());
            
            if (!invalidCuisines.isEmpty()) {
                throw new IllegalArgumentException(
                    "无效的菜系偏好值: " + String.join(", ", invalidCuisines) + 
                    ". 请使用标准库中的值: " + String.join(", ", PreferenceStandardLibrary.CUISINE_OPTIONS)
                );
            }
            
            preferences.put(PreferenceStandardLibrary.PREF_KEY_CUISINE, validCuisines);
        }
        
        user.setPreferences(preferences);
        user = userRepository.save(user);
        
        return UserPreferencesResponse.fromMap(user.getPreferences());
    }
}
