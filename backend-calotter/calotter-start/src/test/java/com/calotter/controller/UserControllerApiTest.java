package com.calotter.controller;

import com.calotter.common.core.domain.entity.RefAllergen;
import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.user.controller.UserController;
import com.calotter.user.controller.dto.*;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.service.JwtService;
import com.calotter.user.service.UserHealthService;
import com.calotter.user.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * UserController API 完整测试
 * 覆盖所有用户相关API端点
 */
@WebMvcTest(controllers = UserController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("用户控制器API测试")
class UserControllerApiTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private UserHealthService userHealthService;

    @Autowired
    private ObjectMapper objectMapper;

    private String validToken;

    @BeforeEach
    void setUp() {
        validToken = "Bearer test-token";
        when(jwtService.validateToken("test-token")).thenReturn(true);
        when(jwtService.extractUserId("test-token")).thenReturn(1L);
    }

    // ==================== 注册和登录测试 ====================

    @Test
    @DisplayName("用户注册 - 成功")
    void testRegister_Success() throws Exception {
        // Given
        RegisterRequest request = new RegisterRequest();
        request.setUsername("testuser");
        request.setPassword("password123");
        request.setEmail("test@example.com");

        AuthResponse authResponse = AuthResponse.builder()
                .token("test-token")
                .userId(1L)
                .username("testuser")
                .email("test@example.com")
                .role("ROLE_USER")
                .householdId(1L)
                .build();

        when(userService.register(any(RegisterRequest.class))).thenReturn(authResponse);

        // When & Then
        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.token").value("test-token"))
                .andExpect(jsonPath("$.data.userId").value(1))
                .andExpect(jsonPath("$.data.username").value("testuser"))
                .andExpect(jsonPath("$.data.email").value("test@example.com"))
                .andExpect(jsonPath("$.data.householdId").value(1));
    }

    @Test
    @DisplayName("用户注册 - 用户名已存在")
    void testRegister_UsernameExists() throws Exception {
        // Given
        RegisterRequest request = new RegisterRequest();
        request.setUsername("existinguser");
        request.setPassword("password123");
        request.setEmail("test@example.com");

        when(userService.register(any(RegisterRequest.class)))
                .thenThrow(new IllegalArgumentException("用户名已存在"));

        // When & Then
        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("用户名已存在"));
    }

    @Test
    @DisplayName("用户注册 - 验证错误")
    void testRegister_ValidationError() throws Exception {
        // Given - 缺少必需字段
        RegisterRequest request = new RegisterRequest();
        request.setUsername(""); // 空用户名

        // When & Then
        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("用户登录 - 成功")
    void testLogin_Success() throws Exception {
        // Given
        LoginRequest request = new LoginRequest();
        request.setUsernameOrEmail("testuser");
        request.setPassword("password123");

        AuthResponse authResponse = AuthResponse.builder()
                .token("test-token")
                .userId(1L)
                .username("testuser")
                .email("test@example.com")
                .role("ROLE_USER")
                .householdId(1L)
                .build();

        when(userService.login(any(LoginRequest.class))).thenReturn(authResponse);

        // When & Then
        mockMvc.perform(post("/api/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.token").value("test-token"))
                .andExpect(jsonPath("$.data.userId").value(1));
    }

    @Test
    @DisplayName("用户登录 - 无效凭证")
    void testLogin_InvalidCredentials() throws Exception {
        // Given
        LoginRequest request = new LoginRequest();
        request.setUsernameOrEmail("testuser");
        request.setPassword("wrongpassword");

        when(userService.login(any(LoginRequest.class)))
                .thenThrow(new IllegalArgumentException("用户名或密码错误"));

        // When & Then
        mockMvc.perform(post("/api/user/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("用户名或密码错误"));
    }

    @Test
    @DisplayName("用户登出 - 成功")
    void testLogout_Success() throws Exception {
        // When & Then
        mockMvc.perform(post("/api/user/logout")
                        .header("Authorization", validToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").value("Logged out successfully"));
    }

    @Test
    @DisplayName("用户登出 - 无Token")
    void testLogout_NoToken() throws Exception {
        // When & Then
        mockMvc.perform(post("/api/user/logout"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").value("Logged out successfully"));
    }

    // ==================== 用户信息管理测试 ====================

    @Test
    @DisplayName("获取用户信息 - 成功")
    void testGetUserInfo_Success() throws Exception {
        // Given
        UserResponse response = UserResponse.builder()
                .userId(1L)
                .userName("testuser")
                .email("test@example.com")
                .role("ROLE_USER")
                .profile(new HashMap<>())
                .build();

        when(userService.getUserInfo(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/user")
                        .header("Authorization", validToken)
                        .param("id", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.userId").value(1))
                .andExpect(jsonPath("$.data.userName").value("testuser"));
    }

    @Test
    @DisplayName("更新用户信息 - 成功")
    void testUpdateUserInfo_Success() throws Exception {
        // Given
        UserRequest request = new UserRequest();
        Map<String, Object> profile = new HashMap<>();
        profile.put("birthdate", "1990-01-01");
        request.setProfile(profile);

        UserResponse response = UserResponse.builder()
                .userId(1L)
                .userName("testuser")
                .email("test@example.com")
                .role("ROLE_USER")
                .profile(profile)
                .build();

        when(userService.updateUserInfo(eq(1L), any(UserRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/user")
                        .header("Authorization", validToken)
                        .param("id", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.userId").value(1));
    }

    // ==================== 用户偏好测试 ====================

    @Test
    @DisplayName("获取用户偏好 - 成功")
    void testGetPreferences_Success() throws Exception {
        // Given
        PreferencesResponse response = PreferencesResponse.builder()
                .preferences(new HashMap<>())
                .build();

        when(userService.getUserPreferences(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/user/preferences")
                        .header("Authorization", validToken)
                        .param("id", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    @DisplayName("更新用户偏好 - 成功")
    void testUpdatePreferences_Success() throws Exception {
        // Given
        PreferencesRequest request = new PreferencesRequest();
        request.setDietaryType("vegetarian");
        request.setCuisineTypes(Arrays.asList("chinese", "japanese"));

        PreferencesResponse response = PreferencesResponse.builder()
                .preferences(new HashMap<>())
                .build();

        when(userService.updateUserPreferences(eq(1L), any(PreferencesRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/user/preferences")
                        .header("Authorization", validToken)
                        .param("id", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    // ==================== 饮食习惯测试 ====================

    @Test
    @DisplayName("获取用户饮食习惯 - 成功")
    void testGetDietHabits_Success() throws Exception {
        // Given
        DietHabitsResponse response = DietHabitsResponse.builder()
                .dietHabits(Arrays.asList("low_sodium", "low_sugar"))
                .build();

        when(userService.getUserDietHabits(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/user/diet-habits")
                        .header("Authorization", validToken)
                        .param("id", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.dietHabits").isArray());
    }

    @Test
    @DisplayName("更新用户饮食习惯 - 成功")
    void testUpdateDietHabits_Success() throws Exception {
        // Given
        DietHabitsRequest request = new DietHabitsRequest();
        request.setDietHabits(Arrays.asList("low_sodium", "low_sugar"));

        DietHabitsResponse response = DietHabitsResponse.builder()
                .dietHabits(Arrays.asList("low_sodium", "low_sugar"))
                .build();

        when(userService.updateUserDietHabits(eq(1L), any(DietHabitsRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/user/diet-habits")
                        .header("Authorization", validToken)
                        .param("id", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    // ==================== 过敏管理测试 ====================

    @Test
    @DisplayName("获取用户过敏 - 成功")
    void testGetAllergies_Success() throws Exception {
        // Given
        AllergiesResponse response = AllergiesResponse.builder()
                .allergies(Arrays.asList("Peanuts", "Shellfish"))
                .build();

        when(userService.getUserAllergies(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/user/allergies")
                        .header("Authorization", validToken)
                        .param("id", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.allergies").isArray());
    }

    @Test
    @DisplayName("更新用户过敏 - 成功")
    void testUpdateAllergies_Success() throws Exception {
        // Given
        AllergiesRequest request = new AllergiesRequest();
        request.setAllergies(Arrays.asList("Peanuts", "Shellfish"));

        AllergiesResponse response = AllergiesResponse.builder()
                .allergies(Arrays.asList("Peanuts", "Shellfish"))
                .build();

        when(userService.updateUserAllergies(eq(1L), any(AllergiesRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/user/allergies")
                        .header("Authorization", validToken)
                        .param("id", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    // ==================== 标准库查询测试 ====================

    @Test
    @DisplayName("获取所有标准过敏源 - 成功")
    void testGetAllStandardAllergens_Success() throws Exception {
        // Given
        RefAllergen allergen1 = new RefAllergen();
        allergen1.setId(1L);
        allergen1.setName("Peanuts");
        List<RefAllergen> allergens = Arrays.asList(allergen1);

        when(userService.getAllStandardAllergens()).thenReturn(allergens);

        // When & Then
        mockMvc.perform(get("/api/user/standard-allergens"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    @DisplayName("搜索标准过敏源 - 成功")
    void testSearchStandardAllergens_Success() throws Exception {
        // Given
        RefAllergen allergen = new RefAllergen();
        allergen.setId(1L);
        allergen.setName("Peanuts");
        List<RefAllergen> allergens = Arrays.asList(allergen);

        when(userService.searchStandardAllergens("pea", true)).thenReturn(allergens);

        // When & Then
        mockMvc.perform(get("/api/user/standard-allergens/search")
                        .param("name", "pea")
                        .param("fuzzy", "true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    @DisplayName("获取所有标准饮食习惯 - 成功")
    void testGetAllStandardDietHabits_Success() throws Exception {
        // Given
        List<String> dietHabits = Arrays.asList("low_sodium", "low_sugar", "vegetarian");

        when(userService.getAllStandardDietHabits()).thenReturn(dietHabits);

        // When & Then
        mockMvc.perform(get("/api/user/standard-diet-habits"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    @DisplayName("搜索标准饮食习惯 - 成功")
    void testSearchStandardDietHabits_Success() throws Exception {
        // Given
        List<String> dietHabits = Arrays.asList("low_sodium", "low_sugar");

        when(userService.searchStandardDietHabits("low")).thenReturn(dietHabits);

        // When & Then
        mockMvc.perform(get("/api/user/standard-diet-habits/search")
                        .param("q", "low"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    @DisplayName("搜索标准避免食材 - 成功")
    void testSearchStandardAvoidIngredients_Success() throws Exception {
        // Given
        StandardIngredient ingredient = new StandardIngredient();
        ingredient.setId(1001L);
        ingredient.setName("Cilantro");
        List<StandardIngredient> ingredients = Arrays.asList(ingredient);

        when(userService.searchStandardAvoidIngredients("cil", true)).thenReturn(ingredients);

        // When & Then
        mockMvc.perform(get("/api/user/standard-avoid-ingredients/search")
                        .param("name", "cil")
                        .param("fuzzy", "true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    // ==================== 用户偏好Map测试 ====================

    @Test
    @DisplayName("获取用户偏好Map - 成功")
    void testGetPreferencesMap_Success() throws Exception {
        // Given
        UserPreferencesResponse response = UserPreferencesResponse.builder()
                .tastes(Arrays.asList("sweet", "spicy"))
                .cuisines(Arrays.asList("chinese", "japanese"))
                .build();

        when(userService.getUserPreferencesMap(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/user/preferences-map")
                        .header("Authorization", validToken)
                        .param("id", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    @DisplayName("更新用户偏好Map - 成功")
    void testUpdatePreferencesMap_Success() throws Exception {
        // Given
        UserPreferencesRequest request = new UserPreferencesRequest();
        request.setTastes(Arrays.asList("sweet", "spicy"));
        request.setCuisines(Arrays.asList("chinese", "japanese"));

        UserPreferencesResponse response = UserPreferencesResponse.builder()
                .tastes(Arrays.asList("sweet", "spicy"))
                .cuisines(Arrays.asList("chinese", "japanese"))
                .build();

        when(userService.updateUserPreferencesMap(eq(1L), any(UserPreferencesRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/user/preferences-map")
                        .header("Authorization", validToken)
                        .param("id", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    // ==================== 健康目标测试 ====================

    @Test
    @DisplayName("创建或更新健康目标 - 成功")
    void testCreateOrUpdateHealthGoal_Success() throws Exception {
        // Given
        HealthGoalRequest request = new HealthGoalRequest();
        request.setGoalType(HealthGoal.GoalType.LOSE_FAT);
        request.setActivityLevel(1.5); // Double类型

        HealthGoalResponse response = new HealthGoalResponse();
        response.setId(1L);
        response.setGoalType(HealthGoal.GoalType.LOSE_FAT);
        response.setActivityLevel(1.5);
        response.setDailyCalories(2000);

        HealthGoal goal = new HealthGoal();
        goal.setId(1L);
        goal.setGoalType(HealthGoal.GoalType.LOSE_FAT);
        goal.setActivityLevel(1.5);
        goal.setDailyCalories(2000);

        when(userHealthService.createOrUpdateHealthGoal(1L, HealthGoal.GoalType.LOSE_FAT, 1.5))
                .thenReturn(goal);

        // When & Then
        mockMvc.perform(post("/api/user/health-goal")
                        .header("Authorization", validToken)
                        .param("id", "1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1));
    }

    @Test
    @DisplayName("获取用户健康信息 - 成功")
    void testGetHealthInfo_Success() throws Exception {
        // Given
        UserHealthService.UserHealthInfo healthInfo = new UserHealthService.UserHealthInfo();
        healthInfo.setBmi(new java.math.BigDecimal("22.5"));
        healthInfo.setDailyEnergy(2000);
        healthInfo.setDailyProtein(150);
        healthInfo.setDailyFat(65);
        healthInfo.setDailyCarbohydrates(250);
        healthInfo.setDailyFiber(30);

        when(userHealthService.getUserHealthInfo(1L)).thenReturn(healthInfo);

        // When & Then
        mockMvc.perform(get("/api/user/health-info")
                        .header("Authorization", validToken)
                        .param("id", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.bmi").value(22.5))
                .andExpect(jsonPath("$.data.dailyEnergy").value(2000));
    }
}
