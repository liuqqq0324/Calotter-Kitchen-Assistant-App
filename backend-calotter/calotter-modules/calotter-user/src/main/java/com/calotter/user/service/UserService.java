package com.calotter.user.service;

import com.calotter.common.core.domain.entity.RefAllergen;
import com.calotter.user.controller.dto.*;
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
        
        // 更新 profile 信息
        if (request.getProfile() != null) {
            settings.put("profile", request.getProfile());
        }
        
        user.setSettings(settings);
        user = userRepository.save(user);
        
        // 返回更新后的用户信息
        @SuppressWarnings("unchecked")
        Map<String, Object> profile = (Map<String, Object>) user.getSettings().getOrDefault("profile", new HashMap<>());
        
        return UserResponse.builder()
                .userId(user.getId())
                .userName(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole())
                .profile(profile)
                .build();
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
        if (request.getCuisineTypes() != null) {
            preferences.put("cuisineTypes", request.getCuisineTypes());
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
     */
    public TaboosResponse getUserTaboos(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, Object> settings = user.getSettings();
        if (settings == null) {
            return TaboosResponse.builder()
                    .taboos(new ArrayList<>())
                    .build();
        }
        
        @SuppressWarnings("unchecked")
        List<String> taboos = (List<String>) settings.getOrDefault("taboos", new ArrayList<>());
        
        return TaboosResponse.builder()
                .taboos(taboos)
                .build();
    }
    
    /**
     * 更新用户禁忌
     */
    @Transactional
    public TaboosResponse updateUserTaboos(Long userId, TaboosRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        Map<String, Object> settings = user.getSettings();
        if (settings == null) {
            settings = new HashMap<>();
        }
        
        settings.put("taboos", request.getTaboos() != null ? request.getTaboos() : new ArrayList<>());
        user.setSettings(settings);
        user = userRepository.save(user);
        
        @SuppressWarnings("unchecked")
        List<String> taboos = (List<String>) user.getSettings().get("taboos");
        
        return TaboosResponse.builder()
                .taboos(taboos != null ? taboos : new ArrayList<>())
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
}
