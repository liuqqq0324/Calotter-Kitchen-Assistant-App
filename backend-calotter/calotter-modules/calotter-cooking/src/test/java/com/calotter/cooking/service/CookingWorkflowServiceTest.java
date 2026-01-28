package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.FinishCookingRequest;
import com.calotter.cooking.controller.dto.StartCookingRequest;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * CookingWorkflowService 单元测试
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("烹饪工作流服务测试")
class CookingWorkflowServiceTest {

    @Mock
    private CookingSessionRepository sessionRepository;

    @Mock
    private DishRepository dishRepository;

    @Mock
    private HouseholdRepository householdRepository;

    @Mock
    private LeftoverDishRepository leftoverDishRepository;

    @Mock
    private IngredientRepository ingredientRepository;

    @Mock
    private FavoriteRecipeService favoriteRecipeService;

    @InjectMocks
    private CookingWorkflowService cookingWorkflowService;

    private Household household;
    private Dish dish;
    private CookingSession session;

    @BeforeEach
    void setUp() {
        household = new Household();
        household.setId(1L);
        household.setName("测试家庭");

        dish = new Dish();
        dish.setId(100L);
        dish.setName("红烧肉");
        dish.setTotalCalories(2000);
        dish.setTotalProtein(100.0);
        dish.setTotalFat(150.0);
        dish.setTotalCarb(50.0);
        dish.setTotalWeightGram(1000);

        session = new CookingSession();
        session.setId(200L);
        session.setHouseholdId(1L);
        session.setInitiatorId(1L);
        session.setMenuId(1);
        session.setStatus(CookingSession.SessionStatus.PENDING);
        session.setRemainingRatio(1.0);
        session.setDishes(Arrays.asList(dish));
        session.setFinalDish(dish);
    }

    // ==================== startCooking 测试 ====================

    @Test
    @DisplayName("开始烹饪 - 使用recipes成功")
    void testStartCooking_WithRecipes_Success() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(1L);
        request.setInitiatorId(1L);
        request.setMenuId(1);

        MenuDTO.RecipeDTO recipeDto = new MenuDTO.RecipeDTO();
        recipeDto.setTitle("红烧肉");
        request.setRecipes(Arrays.asList(recipeDto));

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(favoriteRecipeService.createDishSnapshot(eq(1L), any(MenuDTO.RecipeDTO.class)))
                .thenReturn(dish);
        when(sessionRepository.save(any(CookingSession.class))).thenAnswer(invocation -> {
            CookingSession saved = invocation.getArgument(0);
            saved.setId(200L);
            return saved;
        });

        // When
        Long sessionId = cookingWorkflowService.startCooking(request);

        // Then
        assertThat(sessionId).isEqualTo(200L);
        verify(householdRepository, times(1)).findById(1L);
        verify(favoriteRecipeService, times(1)).createDishSnapshot(eq(1L), any(MenuDTO.RecipeDTO.class));
        verify(sessionRepository, times(1)).save(any(CookingSession.class));
    }

    @Test
    @DisplayName("开始烹饪 - 使用dishId成功")
    void testStartCooking_WithDishId_Success() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(1L);
        request.setInitiatorId(1L);
        request.setDishId(100L);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(favoriteRecipeService.cookFromFavorite(eq(1L), eq(100L))).thenReturn(dish);
        when(sessionRepository.save(any(CookingSession.class))).thenAnswer(invocation -> {
            CookingSession saved = invocation.getArgument(0);
            saved.setId(200L);
            return saved;
        });

        // When
        Long sessionId = cookingWorkflowService.startCooking(request);

        // Then
        assertThat(sessionId).isEqualTo(200L);
        verify(favoriteRecipeService, times(1)).cookFromFavorite(eq(1L), eq(100L));
        verify(sessionRepository, times(1)).save(any(CookingSession.class));
    }

    @Test
    @DisplayName("开始烹饪 - 使用单个recipe成功")
    void testStartCooking_WithSingleRecipe_Success() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(1L);
        request.setInitiatorId(1L);

        MenuDTO.RecipeDTO recipeDto = new MenuDTO.RecipeDTO();
        recipeDto.setTitle("红烧肉");
        request.setRecipe(recipeDto);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(favoriteRecipeService.createDishSnapshot(eq(1L), any(MenuDTO.RecipeDTO.class)))
                .thenReturn(dish);
        when(sessionRepository.save(any(CookingSession.class))).thenAnswer(invocation -> {
            CookingSession saved = invocation.getArgument(0);
            saved.setId(200L);
            return saved;
        });

        // When
        Long sessionId = cookingWorkflowService.startCooking(request);

        // Then
        assertThat(sessionId).isEqualTo(200L);
        verify(favoriteRecipeService, times(1)).createDishSnapshot(eq(1L), any(MenuDTO.RecipeDTO.class));
        verify(sessionRepository, times(1)).save(any(CookingSession.class));
    }

    @Test
    @DisplayName("开始烹饪 - 家庭不存在")
    void testStartCooking_HouseholdNotFound() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(999L);
        request.setInitiatorId(1L);
        request.setDishId(100L);

        when(householdRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> cookingWorkflowService.startCooking(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(sessionRepository, never()).save(any());
    }

    @Test
    @DisplayName("开始烹饪 - 菜谱不存在")
    void testStartCooking_DishNotFound() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(1L);
        request.setInitiatorId(1L);
        request.setDishId(999L);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(favoriteRecipeService.cookFromFavorite(eq(1L), eq(999L)))
                .thenThrow(new IllegalArgumentException("菜谱不存在: 999"));

        // When & Then
        assertThatThrownBy(() -> cookingWorkflowService.startCooking(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("菜谱不存在");

        verify(sessionRepository, never()).save(any());
    }

    @Test
    @DisplayName("开始烹饪 - 未提供recipes、dishId或recipe")
    void testStartCooking_NoRecipeOrDishId() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(1L);
        request.setInitiatorId(1L);
        // 不设置 recipes、dishId 或 recipe

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        // When & Then
        assertThatThrownBy(() -> cookingWorkflowService.startCooking(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("必须提供 dishId、recipe 或 recipes");

        verify(sessionRepository, never()).save(any());
    }

    // ==================== finishCooking 测试 ====================

    @Test
    @DisplayName("完成烹饪 - 成功")
    void testFinishCooking_Success() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        FinishCookingRequest.FinalIngredient ingredient = new FinishCookingRequest.FinalIngredient();
        ingredient.setName("五花肉");
        ingredient.setAmountValue(500.0);
        ingredient.setAmountUnit("g");
        request.setFinalIngredients(Arrays.asList(ingredient));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getStatus()).isEqualTo(CookingSession.SessionStatus.COOKED);
        verify(sessionRepository, times(1)).save(any(CookingSession.class));
        verify(leftoverDishRepository, times(1)).save(any(LeftoverDish.class));
    }

    @Test
    @DisplayName("完成烹饪 - 会话不存在")
    void testFinishCooking_SessionNotFound() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(999L);

        when(sessionRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> cookingWorkflowService.finishCooking(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("会话不存在");

        verify(sessionRepository, never()).save(any());
    }

    @Test
    @DisplayName("完成烹饪 - 多道菜")
    void testFinishCooking_WithMultipleDishes() {
        // Given: session 中有多道菜
        Dish dish2 = new Dish();
        dish2.setId(101L);
        dish2.setName("清炒时蔬");
        dish2.setTotalWeightGram(500);

        session.setDishes(Arrays.asList(dish, dish2));

        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then: 验证完成了所有菜品（创建了 2 个 LeftoverDish）
        assertThat(result).isNotNull();
        verify(leftoverDishRepository, times(2)).save(any(LeftoverDish.class));
    }

    @Test
    @DisplayName("完成烹饪 - 扣减库存")
    void testFinishCooking_DeductInventory() {
        // Given
        Ingredient inventoryIngredient = new Ingredient();
        inventoryIngredient.setId(1L);
        inventoryIngredient.setQuantity(1000.0);
        inventoryIngredient.setUnit("g");
        // 设置 metadata（使用 StandardIngredient）
        com.calotter.common.core.domain.entity.StandardIngredient standardIngredient = 
                new com.calotter.common.core.domain.entity.StandardIngredient();
        standardIngredient.setName("五花肉");
        inventoryIngredient.setMetadata(standardIngredient);

        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        FinishCookingRequest.FinalIngredient ingredient = new FinishCookingRequest.FinalIngredient();
        ingredient.setName("五花肉");
        ingredient.setAmountValue(500.0);
        ingredient.setAmountUnit("g");
        request.setFinalIngredients(Arrays.asList(ingredient));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(Arrays.asList(inventoryIngredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenReturn(inventoryIngredient);
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        cookingWorkflowService.finishCooking(request);

        // Then
        // 验证库存被扣减
        ArgumentCaptor<Ingredient> ingredientCaptor = ArgumentCaptor.forClass(Ingredient.class);
        verify(ingredientRepository, times(1)).save(ingredientCaptor.capture());
        Ingredient savedIngredient = ingredientCaptor.getValue();
        assertThat(savedIngredient.getQuantity()).isEqualTo(500.0); // 1000 - 500 = 500
    }

    @Test
    @DisplayName("完成烹饪 - 通过dishId更新dish总质量")
    void testFinishCooking_UpdateDishTotalWeight_ByDishId() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        // 设置dishTotalWeights（通过dishId匹配）
        FinishCookingRequest.DishTotalWeight weightInfo = new FinishCookingRequest.DishTotalWeight();
        weightInfo.setDishId(100L);
        weightInfo.setTotalWeightGram(1200); // 更新为1200g
        request.setDishTotalWeights(Arrays.asList(weightInfo));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(dishRepository.save(any(Dish.class))).thenReturn(dish);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1200); // 验证总质量已更新
        verify(dishRepository, times(1)).save(dish);
        verify(leftoverDishRepository, times(1)).save(any(LeftoverDish.class));
    }

    @Test
    @DisplayName("完成烹饪 - 通过recipeId更新dish总质量")
    void testFinishCooking_UpdateDishTotalWeight_ByRecipeId() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        // 设置dishTotalWeights（通过recipeId匹配，即dish的name）
        FinishCookingRequest.DishTotalWeight weightInfo = new FinishCookingRequest.DishTotalWeight();
        weightInfo.setRecipeId("红烧肉"); // 使用dish的name匹配
        weightInfo.setTotalWeightGram(1500); // 更新为1500g
        request.setDishTotalWeights(Arrays.asList(weightInfo));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(dishRepository.save(any(Dish.class))).thenReturn(dish);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1500); // 验证总质量已更新
        verify(dishRepository, times(1)).save(dish);
    }

    @Test
    @DisplayName("完成烹饪 - 更新多道菜的总质量")
    void testFinishCooking_UpdateDishTotalWeight_MultipleDishes() {
        // Given: session中有多道菜
        Dish dish2 = new Dish();
        dish2.setId(101L);
        dish2.setName("清炒时蔬");
        dish2.setTotalWeightGram(500);
        dish2.setTotalCalories(500);
        dish2.setTotalProtein(20.0);
        dish2.setTotalFat(10.0);
        dish2.setTotalCarb(30.0);

        session.setDishes(Arrays.asList(dish, dish2));

        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        // 设置多个dish的总质量
        FinishCookingRequest.DishTotalWeight weightInfo1 = new FinishCookingRequest.DishTotalWeight();
        weightInfo1.setRecipeId("红烧肉");
        weightInfo1.setTotalWeightGram(1200);

        FinishCookingRequest.DishTotalWeight weightInfo2 = new FinishCookingRequest.DishTotalWeight();
        weightInfo2.setRecipeId("清炒时蔬");
        weightInfo2.setTotalWeightGram(600);

        request.setDishTotalWeights(Arrays.asList(weightInfo1, weightInfo2));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1200);
        assertThat(dish2.getTotalWeightGram()).isEqualTo(600);
        verify(dishRepository, times(2)).save(any(Dish.class));
        verify(leftoverDishRepository, times(2)).save(any(LeftoverDish.class));
    }

    @Test
    @DisplayName("完成烹饪 - 更新总质量时未找到匹配的dish")
    void testFinishCooking_UpdateDishTotalWeight_NoMatch() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        // 设置不匹配的dishTotalWeights
        FinishCookingRequest.DishTotalWeight weightInfo = new FinishCookingRequest.DishTotalWeight();
        weightInfo.setRecipeId("不存在的菜品");
        weightInfo.setTotalWeightGram(1200);
        request.setDishTotalWeights(Arrays.asList(weightInfo));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then: 应该正常完成，但不会更新dish（因为没有匹配）
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1000); // 保持原值
        verify(dishRepository, never()).save(any(Dish.class));
    }

    @Test
    @DisplayName("完成烹饪 - 更新总质量时总质量无效")
    void testFinishCooking_UpdateDishTotalWeight_InvalidWeight() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        // 设置无效的总质量（null或0）
        FinishCookingRequest.DishTotalWeight weightInfo = new FinishCookingRequest.DishTotalWeight();
        weightInfo.setDishId(100L);
        weightInfo.setTotalWeightGram(0); // 无效值
        request.setDishTotalWeights(Arrays.asList(weightInfo));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then: 应该正常完成，但不会更新dish（因为总质量无效）
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1000); // 保持原值
        verify(dishRepository, never()).save(any(Dish.class));
    }

    @Test
    @DisplayName("完成烹饪 - dishId优先于recipeId匹配")
    void testFinishCooking_UpdateDishTotalWeight_PriorityDishIdOverRecipeId() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        // 同时设置dishId和recipeId，应该优先使用dishId
        FinishCookingRequest.DishTotalWeight weightInfo = new FinishCookingRequest.DishTotalWeight();
        weightInfo.setDishId(100L);
        weightInfo.setRecipeId("不匹配的名称");
        weightInfo.setTotalWeightGram(1300);
        request.setDishTotalWeights(Arrays.asList(weightInfo));

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(dishRepository.save(any(Dish.class))).thenReturn(dish);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then: 应该通过dishId匹配成功
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1300);
        verify(dishRepository, times(1)).save(dish);
    }

    @Test
    @DisplayName("完成烹饪 - 未提供dish总质量")
    void testFinishCooking_NoDishTotalWeights() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());
        request.setDishTotalWeights(null); // 不提供总质量

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then: 应该正常完成，不更新dish总质量
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1000); // 保持原值
        verify(dishRepository, never()).save(any(Dish.class));
    }

    @Test
    @DisplayName("完成烹饪 - dish总质量列表为空")
    void testFinishCooking_EmptyDishTotalWeights() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());
        request.setDishTotalWeights(new ArrayList<>()); // 空列表

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then: 应该正常完成，不更新dish总质量
        assertThat(result).isNotNull();
        assertThat(dish.getTotalWeightGram()).isEqualTo(1000); // 保持原值
        verify(dishRepository, never()).save(any(Dish.class));
    }

    @Test
    @DisplayName("完成烹饪 - session没有dishes时使用finalDish")
    void testFinishCooking_SessionNoDishes_UsesFinalDish() {
        // Given: session没有dishes，但有finalDish
        session.setDishes(null);
        session.setFinalDish(dish);

        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then: 应该使用finalDish
        assertThat(result).isNotNull();
        verify(leftoverDishRepository, times(1)).save(any(LeftoverDish.class));
    }

    @Test
    @DisplayName("完成烹饪 - session既没有dishes也没有finalDish")
    void testFinishCooking_SessionNoDishesAndNoFinalDish() {
        // Given: session既没有dishes，也没有finalDish
        session.setDishes(null);
        session.setFinalDish(null);

        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));

        // When & Then
        assertThatThrownBy(() -> cookingWorkflowService.finishCooking(request))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("会话未绑定菜品");

        verify(sessionRepository, never()).save(any());
    }

    @Test
    @DisplayName("完成烹饪 - 包含总营养信息")
    void testFinishCooking_WithTotalNutrition() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        FinishCookingRequest.NutritionSnapshot nutrition = new FinishCookingRequest.NutritionSnapshot();
        nutrition.setCalories(2500.0);
        nutrition.setProtein(120.0);
        nutrition.setFat(180.0);
        nutrition.setCarbs(60.0);
        request.setTotalNutrition(nutrition);

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(eq(1L), eq(0.0)))
                .thenReturn(new ArrayList<>());
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingSession result = cookingWorkflowService.finishCooking(request);

        // Then
        assertThat(result).isNotNull();
        ArgumentCaptor<CookingSession> sessionCaptor = ArgumentCaptor.forClass(CookingSession.class);
        verify(sessionRepository, times(1)).save(sessionCaptor.capture());
        CookingSession savedSession = sessionCaptor.getValue();
        assertThat(savedSession.getTotalNutritionSnapshot()).isNotNull();
    }

}

