package com.calotter.user.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import com.calotter.common.core.domain.entity.RefAllergen;
import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.user.controller.dto.*;
import com.calotter.user.controller.dto.UserPreferencesRequest;
import com.calotter.user.controller.dto.UserPreferencesResponse;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.RefAllergenRepository;
import com.calotter.common.core.repository.StandardIngredientRepository;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.domain.entity.Household;
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
    private final StandardIngredientRepository standardIngredientRepository;
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
            
            // 设置 currentHouseholdId
            final Long finalHouseholdId = householdId; // 声明为 final 供 lambda 使用
            user.setCurrentHouseholdId(finalHouseholdId);
            
            // 将用户添加到 joinedHouseholds（保持数据一致性）
            // 需要重新加载 user 以获取 joinedHouseholds 集合（因为之前是新建的 user）
            user = userRepository.findById(user.getId()).orElse(user);
            Household householdEntity = householdRepository.findById(finalHouseholdId).orElse(null);
            if (householdEntity != null && user.getJoinedHouseholds() != null) {
                // 检查是否已经存在，避免重复添加
                boolean alreadyJoined = user.getJoinedHouseholds().stream()
                        .anyMatch(h -> h.getId().equals(finalHouseholdId));
                if (!alreadyJoined) {
                    user.getJoinedHouseholds().add(householdEntity);
                }
            }
            
            // 保存更新后的用户
            user = userRepository.save(user);
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
            // 如果 currentHouseholdId 为 NULL，尝试自动设置
            if (user.getCurrentHouseholdId() == null) {
                // 优先使用拥有的家庭
                List<HouseholdResponse> ownedHouseholds = householdService.getHouseholdsByOwner(user.getId());
                if (!ownedHouseholds.isEmpty()) {
                    householdId = ownedHouseholds.get(0).getId();
                    final Long finalHouseholdId = householdId; // 声明为 final 供 lambda 使用
                    // 设置 currentHouseholdId
                    user.setCurrentHouseholdId(finalHouseholdId);
                    // 确保用户也在 joinedHouseholds 中
                    user = userRepository.findById(user.getId()).orElse(user);
                    Household householdEntity = householdRepository.findById(finalHouseholdId).orElse(null);
                    if (householdEntity != null && user.getJoinedHouseholds() != null) {
                        boolean alreadyJoined = user.getJoinedHouseholds().stream()
                                .anyMatch(h -> h.getId().equals(finalHouseholdId));
                        if (!alreadyJoined) {
                            user.getJoinedHouseholds().add(householdEntity);
                        }
                    }
                    user = userRepository.save(user);
                } else {
                    // 如果没有拥有的家庭，尝试从 joinedHouseholds 获取
                    user = userRepository.findById(user.getId()).orElse(user);
                    if (user.getJoinedHouseholds() != null && !user.getJoinedHouseholds().isEmpty()) {
                        householdId = user.getJoinedHouseholds().get(0).getId();
                        user.setCurrentHouseholdId(householdId);
                        user = userRepository.save(user);
                    }
                }
            } else {
                // 如果已有 currentHouseholdId，直接使用
                householdId = user.getCurrentHouseholdId();
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
     * 获取用户饮食习惯
     * 从 dietaryStyles Map 的 DIET_HABITS 键中获取
     */
    public DietHabitsResponse getUserDietHabits(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        // 从 dietaryStyles Map 中获取 DIET_HABITS 列表
        Map<String, List<String>> dietaryStyles = user.getDietaryStyles();
        List<String> dietHabits = new ArrayList<>();
        
        if (dietaryStyles != null && dietaryStyles.containsKey(PreferenceStandardLibrary.PREF_KEY_DIET_HABITS)) {
            dietHabits = dietaryStyles.get(PreferenceStandardLibrary.PREF_KEY_DIET_HABITS);
            if (dietHabits == null) {
                dietHabits = new ArrayList<>();
            }
        }
        
        return DietHabitsResponse.builder()
                .dietHabits(dietHabits)
                .build();
    }
    
    /**
     * 更新用户饮食习惯
     * 更新到 dietaryStyles Map 的 DIET_HABITS 键中
     */
    @Transactional
    public DietHabitsResponse updateUserDietHabits(Long userId, DietHabitsRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        // 获取或创建 dietaryStyles Map
        Map<String, List<String>> dietaryStyles = user.getDietaryStyles();
        if (dietaryStyles == null) {
            dietaryStyles = DietaryStylesValidator.createEmptyMap();
        }
        
        // ✅ 严格校验：dietHabits 必须来自标准库（并且是英文）
        List<String> dietHabits = request.getDietHabits() != null ? request.getDietHabits() : new ArrayList<>();
        List<String> cleanedDietHabits = dietHabits.stream()
                .filter(t -> t != null && !t.trim().isEmpty())
                .map(t -> t.trim().toLowerCase())
                .toList();

        List<String> invalidDietHabits = cleanedDietHabits.stream()
                .filter(t -> t.matches(".*[\\u4e00-\\u9fa5].*") || !PreferenceStandardLibrary.isValidDietHabit(t))
                .toList();

        if (!invalidDietHabits.isEmpty()) {
            throw new IllegalArgumentException(
                    "无效的 dietHabits: " + String.join(", ", invalidDietHabits) +
                            ". 只能使用标准库中的值: " + String.join(", ", PreferenceStandardLibrary.DIET_HABITS_OPTIONS)
            );
        }
        
        // 更新 dietaryStyles Map
        dietaryStyles.put(PreferenceStandardLibrary.PREF_KEY_DIET_HABITS, cleanedDietHabits);
        user.setDietaryStyles(dietaryStyles);
        
        // 保存用户（会触发 @PreUpdate 钩子进行最终验证）
        user = userRepository.save(user);
        
        // 返回更新后的 dietHabits
        List<String> result = user.getDietaryStyles() != null 
                ? user.getDietaryStyles().getOrDefault(PreferenceStandardLibrary.PREF_KEY_DIET_HABITS, new ArrayList<>())
                : new ArrayList<>();
        
        return DietHabitsResponse.builder()
                .dietHabits(result)
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
        
        // ✅ 严格校验：allergies 必须来自标准过敏源库
        List<String> allergyNames = request.getAllergies() != null ? request.getAllergies() : new ArrayList<>();
        List<RefAllergen> allergens = refAllergenRepository.findByNameIn(allergyNames);

        List<String> foundNames = allergens.stream().map(RefAllergen::getName).toList();
        List<String> invalid = allergyNames.stream()
                .filter(n -> n != null && !n.trim().isEmpty())
                .filter(n -> !foundNames.contains(n))
                .toList();

        if (!invalid.isEmpty()) {
            throw new IllegalArgumentException(
                    "无效的 allergies（不在标准库中）: " + String.join(", ", invalid)
            );
        }
        
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

    public List<RefAllergen> searchStandardAllergens(String name, boolean fuzzy) {
        if (name == null || name.trim().isEmpty()) {
            return refAllergenRepository.findAll();
        }
        String q = name.trim();
        if (fuzzy) {
            return refAllergenRepository.findByNameContainingIgnoreCase(q);
        }
        return refAllergenRepository.findByName(q)
                .map(List::of)
                .orElse(List.of());
    }

    public List<String> getAllStandardDietHabits() {
        return PreferenceStandardLibrary.DIET_HABITS_OPTIONS;
    }

    public List<String> searchStandardDietHabits(String query) {
        if (query == null || query.trim().isEmpty()) {
            return PreferenceStandardLibrary.DIET_HABITS_OPTIONS;
        }
        String q = query.trim().toLowerCase();
        return PreferenceStandardLibrary.DIET_HABITS_OPTIONS.stream()
                .filter(t -> t.contains(q))
                .toList();
    }

    public List<StandardIngredient> searchStandardAvoidIngredients(String name, boolean fuzzy) {
        if (name == null || name.trim().isEmpty()) {
            return List.of();
        }
        String q = name.trim();
        if (fuzzy) {
            return standardIngredientRepository.findByNameContainingIgnoreCase(q);
        }
        return standardIngredientRepository.findFirstByNameIgnoreCase(q)
                .map(List::of)
                .orElse(List.of());
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
