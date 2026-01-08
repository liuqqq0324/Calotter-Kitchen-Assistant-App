package com.calotter.cooking.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import com.calotter.common.core.domain.entity.RefAllergen;
import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.domain.entity.StandardSpice;
import com.calotter.common.core.domain.entity.StandardUtensil;
import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.ai.AiMenuGenerationService;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.HouseholdSpice;
import com.calotter.inventory.domain.entity.HouseholdUtensil;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.HouseholdSpiceRepository;
import com.calotter.inventory.repository.HouseholdUtensilRepository;
import com.calotter.user.domain.entity.User;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.repository.HealthGoalRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * AiMenuService 单元测试
 */
@ExtendWith(MockitoExtension.class)
class AiMenuServiceTest {

    @Mock
    private AiMenuGenerationService aiMenuGenerationService;

    @Mock
    private IngredientRepository ingredientRepository;

    @Mock
    private HouseholdSpiceRepository spiceRepository;

    @Mock
    private HouseholdUtensilRepository utensilRepository;

    @Mock
    private HouseholdRepository householdRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private HealthGoalRepository healthGoalRepository;

    @Mock
    private RecipeFilterValidationService recipeFilterValidationService;

    @InjectMocks
    private AiMenuService aiMenuService;

    private Household household;
    private User user;
    private HealthGoal healthGoal;
    private RecipeGenerationFilter filter;

    @BeforeEach
    void setUp() {
        household = new Household();
        household.setId(1L);
        household.setName("测试家庭");
        household.setOwnerId(1L);

        user = new User();
        user.setId(1L);
        user.setUsername("testuser");

        healthGoal = new HealthGoal();
        healthGoal.setId(1L);
        healthGoal.setUser(user);
        healthGoal.setStatus(1); // Active
        healthGoal.setDailyCalories(2000);

        filter = new RecipeGenerationFilter();
        RecipeGenerationFilter.DietPreferences dietPrefs = new RecipeGenerationFilter.DietPreferences();
        dietPrefs.setAllergies(new ArrayList<>());
        dietPrefs.setAvoidIngredients(new ArrayList<>());
        dietPrefs.setDietHabits(new ArrayList<>());
        dietPrefs.setCuisinePreferences(Arrays.asList("Chinese"));
        dietPrefs.setTastePreferences(Arrays.asList("spicy"));
        filter.setDietPreferences(dietPrefs);
        RecipeGenerationFilter.CalorieTarget calorieTarget = new RecipeGenerationFilter.CalorieTarget();
        calorieTarget.setMinTotalKcal(600.0);
        calorieTarget.setMaxTotalKcal(600.0);
        filter.setCalorieTarget(calorieTarget);
    }

    // ==================== getDefaultFilter 测试 ====================

    @Test
    void testGetDefaultFilter_Success() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findByJoinedHouseholdsId(1L)).thenReturn(Arrays.asList(user));
        when(healthGoalRepository.findByUserAndStatus(user, 1)).thenReturn(healthGoal);
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        RecipeGenerationFilter result = aiMenuService.getDefaultFilter(1L);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getDietPreferences()).isNotNull();
        assertThat(result.getCalorieTarget()).isNotNull();
        assertThat(result.getServings()).isEqualTo(1);
        assertThat(result.getGenerationSettings()).isNotNull();
        assertThat(result.getGenerationSettings().getDishCount()).isEqualTo(1);
        verify(householdRepository, times(1)).findById(1L);
        verify(userRepository, times(1)).findByJoinedHouseholdsId(1L);
        verify(recipeFilterValidationService, times(1)).validate(any());
    }

    @Test
    void testGetDefaultFilter_HouseholdNotFound() {
        // Given
        when(householdRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> aiMenuService.getDefaultFilter(999L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");
    }

    @Test
    void testGetDefaultFilter_WithAllergies() {
        // Given
        RefAllergen allergen = new RefAllergen();
        allergen.setName("peanuts");
        user.setAllergies(Arrays.asList(allergen));

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findByJoinedHouseholdsId(1L)).thenReturn(Arrays.asList(user));
        when(healthGoalRepository.findByUserAndStatus(user, 1)).thenReturn(healthGoal);
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        RecipeGenerationFilter result = aiMenuService.getDefaultFilter(1L);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getDietPreferences().getAllergies()).contains("peanuts");
    }

    @Test
    void testGetDefaultFilter_WithInventory() {
        // Given
        Ingredient ingredient = new Ingredient();
        ingredient.setId(1L);
        ingredient.setQuantity(500.0);
        ingredient.setUnit("g");
        ingredient.setExpirationDate(LocalDate.now().plusDays(5));
        StandardIngredient standardIngredient = new StandardIngredient();
        standardIngredient.setName("chicken");
        ingredient.setMetadata(standardIngredient);

        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setId(1L);
        utensil.setIsAvailable(true);
        StandardUtensil standardUtensil = new StandardUtensil();
        standardUtensil.setName("wok");
        utensil.setMetadata(standardUtensil);

        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setIsAvailable(true);
        StandardSpice standardSpice = new StandardSpice();
        standardSpice.setName("salt");
        spice.setMetadata(standardSpice);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findByJoinedHouseholdsId(1L)).thenReturn(Arrays.asList(user));
        when(healthGoalRepository.findByUserAndStatus(user, 1)).thenReturn(healthGoal);
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(Arrays.asList(ingredient));
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(Arrays.asList(spice));
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(Arrays.asList(utensil));
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        RecipeGenerationFilter result = aiMenuService.getDefaultFilter(1L);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getInventory()).isNotNull();
        assertThat(result.getInventory()).hasSize(1);
        assertThat(result.getInventory().get(0).getName()).isEqualTo("chicken");
        assertThat(result.getCookers()).isNotNull();
        assertThat(result.getCookers()).contains("wok");
        assertThat(result.getSeasonings()).isNotNull();
        assertThat(result.getSeasonings()).contains("salt");
    }

    @Test
    void testGetDefaultFilter_WithMultipleUsers() {
        // Given
        User user2 = new User();
        user2.setId(2L);
        user2.setUsername("testuser2");

        RefAllergen allergen1 = new RefAllergen();
        allergen1.setName("peanuts");
        user.setAllergies(Arrays.asList(allergen1));

        RefAllergen allergen2 = new RefAllergen();
        allergen2.setName("milk");
        user2.setAllergies(Arrays.asList(allergen2));

        HealthGoal goal2 = new HealthGoal();
        goal2.setId(2L);
        goal2.setUser(user2);
        goal2.setStatus(1);
        goal2.setDailyCalories(1800);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findByJoinedHouseholdsId(1L)).thenReturn(Arrays.asList(user, user2));
        when(healthGoalRepository.findByUserAndStatus(user, 1)).thenReturn(healthGoal);
        when(healthGoalRepository.findByUserAndStatus(user2, 1)).thenReturn(goal2);
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        RecipeGenerationFilter result = aiMenuService.getDefaultFilter(1L);

        // Then
        assertThat(result).isNotNull();
        // 应该包含两个用户的过敏原（去重后）
        assertThat(result.getDietPreferences().getAllergies()).containsExactlyInAnyOrder("peanuts", "milk");
        // 应该计算平均卡路里：(2000 + 1800) / 2 = 1900
        assertThat(result.getCalorieTarget().getMinTotalKcal()).isEqualTo(1900.0);
        assertThat(result.getCalorieTarget().getMaxTotalKcal()).isEqualTo(1900.0);
        assertThat(result.getServings()).isEqualTo(2);
    }

    @Test
    void testGetDefaultFilter_NoHealthGoal_UsesDefault() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findByJoinedHouseholdsId(1L)).thenReturn(Arrays.asList(user));
        when(healthGoalRepository.findByUserAndStatus(user, 1)).thenReturn(null); // 没有健康目标
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        RecipeGenerationFilter result = aiMenuService.getDefaultFilter(1L);

        // Then: 应该使用默认值 600 卡
        assertThat(result.getCalorieTarget().getMinTotalKcal()).isEqualTo(600.0);
        assertThat(result.getCalorieTarget().getMaxTotalKcal()).isEqualTo(600.0);
    }

    @Test
    void testGetDefaultFilter_NoMembers_UsesOwner() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findByJoinedHouseholdsId(1L)).thenReturn(new ArrayList<>()); // 没有成员
        when(userRepository.findById(1L)).thenReturn(Optional.of(user)); // 返回所有者
        when(healthGoalRepository.findByUserAndStatus(user, 1)).thenReturn(healthGoal);
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        RecipeGenerationFilter result = aiMenuService.getDefaultFilter(1L);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getServings()).isEqualTo(1);
        verify(userRepository, times(1)).findById(1L); // 应该查找所有者
    }

    @Test
    void testGetDefaultFilter_WithPreferences() {
        // Given
        Map<String, List<String>> preferences = new HashMap<>();
        preferences.put(PreferenceStandardLibrary.PREF_KEY_CUISINE, Arrays.asList("Chinese", "Japanese"));
        preferences.put(PreferenceStandardLibrary.PREF_KEY_TASTE, Arrays.asList("spicy", "sweet"));
        user.setPreferences(preferences);

        Map<String, List<String>> dietaryStyles = new HashMap<>();
        dietaryStyles.put(PreferenceStandardLibrary.PREF_KEY_DIET_HABITS, Arrays.asList("vegetarian"));
        dietaryStyles.put(PreferenceStandardLibrary.PREF_KEY_AVOID_INGREDIENT, Arrays.asList("onion", "garlic"));
        user.setDietaryStyles(dietaryStyles);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findByJoinedHouseholdsId(1L)).thenReturn(Arrays.asList(user));
        when(healthGoalRepository.findByUserAndStatus(user, 1)).thenReturn(healthGoal);
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        RecipeGenerationFilter result = aiMenuService.getDefaultFilter(1L);

        // Then
        assertThat(result.getDietPreferences().getCuisinePreferences())
                .containsExactlyInAnyOrder("Chinese", "Japanese");
        assertThat(result.getDietPreferences().getTastePreferences())
                .containsExactlyInAnyOrder("spicy", "sweet");
        assertThat(result.getDietPreferences().getDietHabits())
                .containsExactly("vegetarian");
        assertThat(result.getDietPreferences().getAvoidIngredients())
                .containsExactlyInAnyOrder("onion", "garlic");
    }

    // ==================== generateMenus 测试 ====================

    @Test
    void testGenerateMenus_WithHouseholdId_FillsFilter() {
        // Given
        Ingredient ingredient = new Ingredient();
        ingredient.setId(1L);
        ingredient.setQuantity(500.0);
        ingredient.setUnit("g");
        StandardIngredient standardIngredient = new StandardIngredient();
        standardIngredient.setName("chicken");
        ingredient.setMetadata(standardIngredient);

        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(Arrays.asList(ingredient));
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());

        List<MenuDTO> mockMenus = new ArrayList<>();
        MenuDTO menu = new MenuDTO();
        menu.setMenuId(1);
        mockMenus.add(menu);
        when(aiMenuGenerationService.generateMenus(any(RecipeGenerationFilter.class)))
                .thenReturn(mockMenus);
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        List<MenuDTO> result = aiMenuService.generateMenus(filter, 1L);

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        verify(ingredientRepository, times(1)).findByHouseholdIdAndQuantityGreaterThan(1L, 0.0);
        verify(aiMenuGenerationService, times(1)).generateMenus(any(RecipeGenerationFilter.class));
        verify(recipeFilterValidationService, times(1)).validate(any());
    }

    @Test
    void testGenerateMenus_WithoutHouseholdId() {
        // Given
        List<MenuDTO> mockMenus = new ArrayList<>();
        when(aiMenuGenerationService.generateMenus(any(RecipeGenerationFilter.class)))
                .thenReturn(mockMenus);
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        List<MenuDTO> result = aiMenuService.generateMenus(filter, null);

        // Then
        assertThat(result).isNotNull();
        verify(householdRepository, never()).findById(any());
        verify(ingredientRepository, never()).findByHouseholdIdAndQuantityGreaterThan(any(), any());
        verify(aiMenuGenerationService, times(1)).generateMenus(any(RecipeGenerationFilter.class));
        verify(recipeFilterValidationService, times(1)).validate(any());
    }

    @Test
    void testGenerateMenus_WithAllergiesNone() {
        // Given
        filter.getDietPreferences().setAllergies(Arrays.asList("none"));

        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());

        List<MenuDTO> mockMenus = new ArrayList<>();
        when(aiMenuGenerationService.generateMenus(any(RecipeGenerationFilter.class)))
                .thenReturn(mockMenus);
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        List<MenuDTO> result = aiMenuService.generateMenus(filter, 1L);

        // Then: "none" 应该被移除，allergies 应该为空数组
        ArgumentCaptor<RecipeGenerationFilter> filterCaptor = ArgumentCaptor.forClass(RecipeGenerationFilter.class);
        verify(recipeFilterValidationService).validate(filterCaptor.capture());
        RecipeGenerationFilter validatedFilter = filterCaptor.getValue();
        assertThat(validatedFilter.getDietPreferences().getAllergies()).isEmpty();
    }

    @Test
    void testGenerateMenus_WithAllergiesNoneAndOthers() {
        // Given
        filter.getDietPreferences().setAllergies(Arrays.asList("peanuts", "none", "milk"));

        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());

        List<MenuDTO> mockMenus = new ArrayList<>();
        when(aiMenuGenerationService.generateMenus(any(RecipeGenerationFilter.class)))
                .thenReturn(mockMenus);
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        List<MenuDTO> result = aiMenuService.generateMenus(filter, 1L);

        // Then: "none" 应该被移除，但保留其他值
        ArgumentCaptor<RecipeGenerationFilter> filterCaptor = ArgumentCaptor.forClass(RecipeGenerationFilter.class);
        verify(recipeFilterValidationService).validate(filterCaptor.capture());
        RecipeGenerationFilter validatedFilter = filterCaptor.getValue();
        assertThat(validatedFilter.getDietPreferences().getAllergies())
                .containsExactlyInAnyOrder("peanuts", "milk");
    }

    @Test
    void testGenerateMenus_WithNullAllergies() {
        // Given
        filter.getDietPreferences().setAllergies(null);

        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());

        List<MenuDTO> mockMenus = new ArrayList<>();
        when(aiMenuGenerationService.generateMenus(any(RecipeGenerationFilter.class)))
                .thenReturn(mockMenus);
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        List<MenuDTO> result = aiMenuService.generateMenus(filter, 1L);

        // Then: null 应该被初始化为空数组
        ArgumentCaptor<RecipeGenerationFilter> filterCaptor = ArgumentCaptor.forClass(RecipeGenerationFilter.class);
        verify(recipeFilterValidationService).validate(filterCaptor.capture());
        RecipeGenerationFilter validatedFilter = filterCaptor.getValue();
        assertThat(validatedFilter.getDietPreferences().getAllergies()).isEmpty();
    }

    @Test
    void testGenerateMenus_ExistingInventory_NotOverwritten() {
        // Given: filter 已经有 inventory
        RecipeGenerationFilter.InventoryItem existingItem = new RecipeGenerationFilter.InventoryItem();
        existingItem.setName("existing");
        existingItem.setAmountValue(100.0);
        filter.setInventory(Arrays.asList(existingItem));

        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(1L, 0.0))
                .thenReturn(new ArrayList<>());
        when(spiceRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());
        when(utensilRepository.findByHouseholdIdAndIsAvailableTrue(1L))
                .thenReturn(new ArrayList<>());

        List<MenuDTO> mockMenus = new ArrayList<>();
        when(aiMenuGenerationService.generateMenus(any(RecipeGenerationFilter.class)))
                .thenReturn(mockMenus);
        doNothing().when(recipeFilterValidationService).validate(any());

        // When
        List<MenuDTO> result = aiMenuService.generateMenus(filter, 1L);

        // Then: 如果已有 inventory，不会被覆盖（因为 enrichFilterFromHousehold 检查 isEmpty）
        // 但实际上 cookers 和 seasonings 总是会被覆盖
        verify(ingredientRepository, never()).findByHouseholdIdAndQuantityGreaterThan(any(), any());
    }
}
