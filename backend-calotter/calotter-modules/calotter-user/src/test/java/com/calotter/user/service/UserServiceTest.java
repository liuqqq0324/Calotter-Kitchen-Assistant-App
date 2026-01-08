package com.calotter.user.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import com.calotter.common.core.domain.entity.RefAllergen;
import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.repository.StandardIngredientRepository;
import com.calotter.user.controller.dto.*;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.RefAllergenRepository;
import com.calotter.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * UserService 完整单元测试
 * 覆盖所有功能：注册、登录、用户信息管理、偏好管理、过敏管理等
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("用户服务测试")
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private HouseholdService householdService;

    @Mock
    private RefAllergenRepository refAllergenRepository;

    @Mock
    private StandardIngredientRepository standardIngredientRepository;

    @Mock
    private HouseholdRepository householdRepository;

    @InjectMocks
    private UserService userService;

    private User user;
    private RegisterRequest registerRequest;
    private LoginRequest loginRequest;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPasswordHash("$2a$10$encodedPasswordHash");
        user.setRole("ROLE_USER");
        user.setStatus(1);
        user.setIsOnboarded(false);
        user.setSettings(new HashMap<>());
        user.setPreferences(new HashMap<>());
        user.setDietaryStyles(new HashMap<>());

        registerRequest = new RegisterRequest();
        registerRequest.setUsername("testuser");
        registerRequest.setPassword("password123");
        registerRequest.setEmail("test@example.com");

        loginRequest = new LoginRequest();
        loginRequest.setUsernameOrEmail("testuser");
        loginRequest.setPassword("password123");
    }

    // ==================== 注册测试 ====================

    @Test
    @DisplayName("注册 - 成功")
    void testRegister_Success() {
        // Given
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("$2a$10$encodedPasswordHash");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdService.createHousehold(any(HouseholdRequest.class))).thenAnswer(invocation -> {
            HouseholdResponse response = new HouseholdResponse();
            response.setId(1L);
            response.setName("testuser's Home");
            response.setOwnerId(1L);
            response.setInviteCode("ABC123");
            return response;
        });
        when(householdRepository.findById(1L)).thenReturn(Optional.of(new Household()));
        when(jwtService.generateToken(1L, "testuser")).thenReturn("test-token");

        // When
        AuthResponse response = userService.register(registerRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getToken()).isEqualTo("test-token");
        assertThat(response.getUserId()).isEqualTo(1L);
        assertThat(response.getUsername()).isEqualTo("testuser");
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getRole()).isEqualTo("ROLE_USER");
        assertThat(response.getHouseholdId()).isEqualTo(1L);

        verify(userRepository, atLeastOnce()).save(any(User.class));
        verify(householdService, times(1)).createHousehold(any(HouseholdRequest.class));
        verify(jwtService, times(1)).generateToken(1L, "testuser");
    }

    @Test
    @DisplayName("注册 - 用户名已存在")
    void testRegister_UsernameAlreadyExists() {
        // Given
        when(userRepository.existsByUsername("testuser")).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.register(registerRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户名已存在");

        verify(userRepository, never()).save(any());
    }

    @Test
    @DisplayName("注册 - 邮箱已被注册")
    void testRegister_EmailAlreadyExists() {
        // Given
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.register(registerRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("邮箱已被注册");

        verify(userRepository, never()).save(any());
    }

    // ==================== 登录测试 ====================

    @Test
    @DisplayName("登录 - 使用用户名成功")
    void testLogin_WithUsername_Success() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);
        when(jwtService.generateToken(1L, "testuser")).thenReturn("test-token");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        AuthResponse response = userService.login(loginRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getToken()).isEqualTo("test-token");
        assertThat(response.getUserId()).isEqualTo(1L);
        assertThat(response.getUsername()).isEqualTo("testuser");

        verify(userRepository, times(1)).findByUsername("testuser");
        verify(userRepository, never()).findByEmail(anyString());
    }

    @Test
    @DisplayName("登录 - 使用邮箱成功")
    void testLogin_WithEmail_Success() {
        // Given
        loginRequest.setUsernameOrEmail("test@example.com");
        when(userRepository.findByUsername("test@example.com")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);
        when(jwtService.generateToken(1L, "testuser")).thenReturn("test-token");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        AuthResponse response = userService.login(loginRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getToken()).isEqualTo("test-token");
        verify(userRepository, times(1)).findByEmail("test@example.com");
    }

    @Test
    @DisplayName("登录 - 用户不存在")
    void testLogin_UserNotFound() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("testuser")).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户名或密码错误");

        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    @DisplayName("登录 - 密码错误")
    void testLogin_WrongPassword() {
        // Given
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrongpassword", user.getPasswordHash())).thenReturn(false);
        loginRequest.setPassword("wrongpassword");

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户名或密码错误");

        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    @DisplayName("登录 - 账户未激活")
    void testLogin_AccountNotActivated() {
        // Given
        user.setStatus(0);
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("账户未激活");

        verify(jwtService, never()).generateToken(any(), any());
    }

    @Test
    @DisplayName("登录 - 账户被封禁")
    void testLogin_AccountBanned() {
        // Given
        user.setStatus(2);
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", user.getPasswordHash())).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.login(loginRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("账户已被封禁");

        verify(jwtService, never()).generateToken(any(), any());
    }

    // ==================== 用户信息管理测试 ====================

    @Test
    @DisplayName("获取用户信息 - 成功")
    void testGetUserInfo_Success() {
        // Given
        user.setBirthdate(LocalDate.of(1990, 1, 1));
        user.setGender(1);
        user.setCurrentHeight(175);
        user.setCurrentWeight(new BigDecimal("70.5"));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        UserResponse response = userService.getUserInfo(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getUserId()).isEqualTo(1L);
        assertThat(response.getUserName()).isEqualTo("testuser");
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getProfile()).isNotNull();
        assertThat(response.getProfile().get("birthdate")).isEqualTo("1990-01-01");
        assertThat(response.getProfile().get("gender")).isEqualTo("1");
        assertThat(response.getProfile().get("height")).isEqualTo(175);
    }

    @Test
    @DisplayName("获取用户信息 - 用户不存在")
    void testGetUserInfo_UserNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> userService.getUserInfo(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
    @DisplayName("更新用户信息 - 成功")
    void testUpdateUserInfo_Success() {
        // Given
        UserRequest request = new UserRequest();
        Map<String, Object> profile = new HashMap<>();
        profile.put("birthdate", "1990-01-01");
        profile.put("gender", "1");
        profile.put("height", 175);
        profile.put("weight", 70);
        request.setProfile(profile);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        UserResponse response = userService.updateUserInfo(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(user.getBirthdate()).isEqualTo(LocalDate.of(1990, 1, 1));
        assertThat(user.getGender()).isEqualTo(1);
        assertThat(user.getCurrentHeight()).isEqualTo(175);
        verify(userRepository, times(1)).save(user);
    }

    @Test
    @DisplayName("更新用户信息 - 用户不存在")
    void testUpdateUserInfo_UserNotFound() {
        // Given
        UserRequest request = new UserRequest();
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> userService.updateUserInfo(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    // ==================== 用户偏好测试 ====================

    @Test
    @DisplayName("获取用户偏好 - 成功")
    void testGetUserPreferences_Success() {
        // Given
        Map<String, Object> settings = new HashMap<>();
        Map<String, Object> preferences = new HashMap<>();
        preferences.put("dietaryType", "vegetarian");
        preferences.put("spiceLevel", "medium");
        settings.put("preferences", preferences);
        user.setSettings(settings);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        PreferencesResponse response = userService.getUserPreferences(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getPreferences()).isNotNull();
        assertThat(response.getPreferences().get("dietaryType")).isEqualTo("vegetarian");
    }

    @Test
    @DisplayName("更新用户偏好 - 成功")
    void testUpdateUserPreferences_Success() {
        // Given
        PreferencesRequest request = new PreferencesRequest();
        request.setDietaryType("vegetarian");
        request.setSpiceLevel("medium");
        request.setCuisineTypes(Arrays.asList("chinese", "japanese"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        PreferencesResponse response = userService.updateUserPreferences(1L, request);

        // Then
        assertThat(response).isNotNull();
        verify(userRepository, times(1)).save(user);
    }

    @Test
    @DisplayName("更新用户偏好 - 无效的菜系")
    void testUpdateUserPreferences_InvalidCuisine() {
        // Given
        PreferencesRequest request = new PreferencesRequest();
        request.setCuisineTypes(Arrays.asList("invalid_cuisine"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When & Then
        assertThatThrownBy(() -> userService.updateUserPreferences(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("无效的菜系偏好值");
    }

    // ==================== 饮食习惯测试 ====================

    @Test
    @DisplayName("获取用户饮食习惯 - 成功")
    void testGetUserDietHabits_Success() {
        // Given
        Map<String, List<String>> dietaryStyles = new HashMap<>();
        dietaryStyles.put(PreferenceStandardLibrary.PREF_KEY_DIET_HABITS, Arrays.asList("low_sodium", "low_sugar"));
        user.setDietaryStyles(dietaryStyles);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        DietHabitsResponse response = userService.getUserDietHabits(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDietHabits()).hasSize(2);
        assertThat(response.getDietHabits()).contains("low_sodium", "low_sugar");
    }

    @Test
    @DisplayName("更新用户饮食习惯 - 成功")
    void testUpdateUserDietHabits_Success() {
        // Given
        DietHabitsRequest request = new DietHabitsRequest();
        request.setDietHabits(Arrays.asList("low_sodium", "low_sugar"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        DietHabitsResponse response = userService.updateUserDietHabits(1L, request);

        // Then
        assertThat(response).isNotNull();
        verify(userRepository, times(1)).save(user);
    }

    @Test
    @DisplayName("更新用户饮食习惯 - 无效的饮食习惯")
    void testUpdateUserDietHabits_InvalidDietHabit() {
        // Given
        DietHabitsRequest request = new DietHabitsRequest();
        request.setDietHabits(Arrays.asList("invalid_habit", "中文习惯"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When & Then
        assertThatThrownBy(() -> userService.updateUserDietHabits(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("无效的 dietHabits");
    }

    // ==================== 过敏管理测试 ====================

    @Test
    @DisplayName("获取用户过敏 - 成功")
    void testGetUserAllergies_Success() {
        // Given
        RefAllergen allergen1 = new RefAllergen();
        allergen1.setId(1L);
        allergen1.setName("Peanuts");
        RefAllergen allergen2 = new RefAllergen();
        allergen2.setId(2L);
        allergen2.setName("Shellfish");
        user.setAllergies(Arrays.asList(allergen1, allergen2));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        AllergiesResponse response = userService.getUserAllergies(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getAllergies()).hasSize(2);
        assertThat(response.getAllergies()).contains("Peanuts", "Shellfish");
    }

    @Test
    @DisplayName("获取用户过敏 - 空列表")
    void testGetUserAllergies_Empty() {
        // Given
        user.setAllergies(new ArrayList<>());
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        AllergiesResponse response = userService.getUserAllergies(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getAllergies()).isEmpty();
    }

    @Test
    @DisplayName("更新用户过敏 - 成功")
    void testUpdateUserAllergies_Success() {
        // Given
        AllergiesRequest request = new AllergiesRequest();
        request.setAllergies(Arrays.asList("Peanuts", "Shellfish"));

        RefAllergen allergen1 = new RefAllergen();
        allergen1.setId(1L);
        allergen1.setName("Peanuts");
        RefAllergen allergen2 = new RefAllergen();
        allergen2.setId(2L);
        allergen2.setName("Shellfish");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(refAllergenRepository.findByNameIn(Arrays.asList("Peanuts", "Shellfish")))
                .thenReturn(Arrays.asList(allergen1, allergen2));
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        AllergiesResponse response = userService.updateUserAllergies(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(user.getAllergies()).hasSize(2);
        verify(userRepository, times(1)).save(user);
    }

    @Test
    @DisplayName("更新用户过敏 - 无效的过敏源")
    void testUpdateUserAllergies_InvalidAllergen() {
        // Given
        AllergiesRequest request = new AllergiesRequest();
        request.setAllergies(Arrays.asList("InvalidAllergen"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(refAllergenRepository.findByNameIn(Arrays.asList("InvalidAllergen")))
                .thenReturn(Collections.emptyList());

        // When & Then
        assertThatThrownBy(() -> userService.updateUserAllergies(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("无效的 allergies");
    }

    // ==================== 标准库查询测试 ====================

    @Test
    @DisplayName("获取所有标准过敏源 - 成功")
    void testGetAllStandardAllergens_Success() {
        // Given
        RefAllergen allergen1 = new RefAllergen();
        allergen1.setId(1L);
        allergen1.setName("Peanuts");
        RefAllergen allergen2 = new RefAllergen();
        allergen2.setId(2L);
        allergen2.setName("Shellfish");
        when(refAllergenRepository.findAll()).thenReturn(Arrays.asList(allergen1, allergen2));

        // When
        List<RefAllergen> result = userService.getAllStandardAllergens();

        // Then
        assertThat(result).hasSize(2);
    }

    @Test
    @DisplayName("搜索标准过敏源 - 精确匹配")
    void testSearchStandardAllergens_ExactMatch() {
        // Given
        RefAllergen allergen = new RefAllergen();
        allergen.setId(1L);
        allergen.setName("Peanuts");
        when(refAllergenRepository.findByName("Peanuts")).thenReturn(Optional.of(allergen));

        // When
        List<RefAllergen> result = userService.searchStandardAllergens("Peanuts", false);

        // Then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getName()).isEqualTo("Peanuts");
    }

    @Test
    @DisplayName("搜索标准过敏源 - 模糊匹配")
    void testSearchStandardAllergens_FuzzyMatch() {
        // Given
        RefAllergen allergen = new RefAllergen();
        allergen.setId(1L);
        allergen.setName("Peanuts");
        when(refAllergenRepository.findByNameContainingIgnoreCase("Pea")).thenReturn(Arrays.asList(allergen));

        // When
        List<RefAllergen> result = userService.searchStandardAllergens("Pea", true);

        // Then
        assertThat(result).hasSize(1);
    }

    @Test
    @DisplayName("获取所有标准饮食习惯 - 成功")
    void testGetAllStandardDietHabits_Success() {
        // When
        List<String> result = userService.getAllStandardDietHabits();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).isNotEmpty();
    }

    @Test
    @DisplayName("搜索标准饮食习惯 - 成功")
    void testSearchStandardDietHabits_Success() {
        // When
        List<String> result = userService.searchStandardDietHabits("low");

        // Then
        assertThat(result).isNotNull();
    }

    @Test
    @DisplayName("搜索标准避免食材 - 精确匹配")
    void testSearchStandardAvoidIngredients_ExactMatch() {
        // Given
        StandardIngredient ingredient = new StandardIngredient();
        ingredient.setId(1001L);
        ingredient.setName("Cilantro");
        when(standardIngredientRepository.findFirstByNameIgnoreCase("Cilantro"))
                .thenReturn(Optional.of(ingredient));

        // When
        List<StandardIngredient> result = userService.searchStandardAvoidIngredients("Cilantro", false);

        // Then
        assertThat(result).hasSize(1);
    }

    @Test
    @DisplayName("搜索标准避免食材 - 模糊匹配")
    void testSearchStandardAvoidIngredients_FuzzyMatch() {
        // Given
        StandardIngredient ingredient = new StandardIngredient();
        ingredient.setId(1001L);
        ingredient.setName("Cilantro");
        when(standardIngredientRepository.findByNameContainingIgnoreCase("Cil"))
                .thenReturn(Arrays.asList(ingredient));

        // When
        List<StandardIngredient> result = userService.searchStandardAvoidIngredients("Cil", true);

        // Then
        assertThat(result).hasSize(1);
    }

    // ==================== 用户偏好Map测试 ====================

    @Test
    @DisplayName("获取用户偏好Map - 成功")
    void testGetUserPreferencesMap_Success() {
        // Given
        Map<String, List<String>> preferences = new HashMap<>();
        preferences.put(PreferenceStandardLibrary.PREF_KEY_TASTE, Arrays.asList("sweet", "spicy"));
        preferences.put(PreferenceStandardLibrary.PREF_KEY_CUISINE, Arrays.asList("chinese", "japanese"));
        user.setPreferences(preferences);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        UserPreferencesResponse response = userService.getUserPreferencesMap(1L);

        // Then
        assertThat(response).isNotNull();
    }

    @Test
    @DisplayName("更新用户偏好Map - 成功")
    void testUpdateUserPreferencesMap_Success() {
        // Given
        UserPreferencesRequest request = new UserPreferencesRequest();
        request.setTastes(Arrays.asList("sweet", "spicy"));
        request.setCuisines(Arrays.asList("chinese", "japanese"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        UserPreferencesResponse response = userService.updateUserPreferencesMap(1L, request);

        // Then
        assertThat(response).isNotNull();
        verify(userRepository, times(1)).save(user);
    }

    @Test
    @DisplayName("更新用户偏好Map - 无效的口味")
    void testUpdateUserPreferencesMap_InvalidTaste() {
        // Given
        UserPreferencesRequest request = new UserPreferencesRequest();
        request.setTastes(Arrays.asList("invalid_taste"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When & Then
        assertThatThrownBy(() -> userService.updateUserPreferencesMap(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("无效的口味偏好值");
    }

    @Test
    @DisplayName("更新用户偏好Map - 无效的菜系")
    void testUpdateUserPreferencesMap_InvalidCuisine() {
        // Given
        UserPreferencesRequest request = new UserPreferencesRequest();
        request.setCuisines(Arrays.asList("invalid_cuisine"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When & Then
        assertThatThrownBy(() -> userService.updateUserPreferencesMap(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("无效的菜系偏好值");
    }
}
