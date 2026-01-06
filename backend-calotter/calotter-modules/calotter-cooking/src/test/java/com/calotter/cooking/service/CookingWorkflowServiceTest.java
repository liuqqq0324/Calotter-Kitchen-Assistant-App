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
    void testStartCooking_WithDishId_Success() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(1L);
        request.setInitiatorId(1L);
        request.setDishId(100L);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(favoriteRecipeService.cloneDishSnapshot(eq(1L), eq(100L))).thenReturn(dish);
        when(sessionRepository.save(any(CookingSession.class))).thenAnswer(invocation -> {
            CookingSession saved = invocation.getArgument(0);
            saved.setId(200L);
            return saved;
        });

        // When
        Long sessionId = cookingWorkflowService.startCooking(request);

        // Then
        assertThat(sessionId).isEqualTo(200L);
        verify(favoriteRecipeService, times(1)).cloneDishSnapshot(eq(1L), eq(100L));
        verify(sessionRepository, times(1)).save(any(CookingSession.class));
    }

    @Test
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
    void testStartCooking_DishNotFound() {
        // Given
        StartCookingRequest request = new StartCookingRequest();
        request.setHouseholdId(1L);
        request.setInitiatorId(1L);
        request.setDishId(999L);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(dishRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> cookingWorkflowService.startCooking(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("菜品不存在");

        verify(sessionRepository, never()).save(any());
    }

    @Test
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
    void testFinishCooking_Success() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());

        FinishCookingRequest.FinalIngredient ingredient = new FinishCookingRequest.FinalIngredient();
        ingredient.setName("五花肉");
        ingredient.setSourceType("INVENTORY");
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
    void testFinishCooking_WithCompletedDishIds() {
        // Given
        Dish dish2 = new Dish();
        dish2.setId(101L);
        dish2.setName("清炒时蔬");
        dish2.setTotalWeightGram(500);

        session.setDishes(Arrays.asList(dish, dish2));

        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());
        request.setCompletedDishIds(Arrays.asList(100L)); // 只完成第一道菜

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
        // 验证只创建了一个 LeftoverDish（只完成了第一道菜）
        verify(leftoverDishRepository, times(1)).save(any(LeftoverDish.class));
        
        ArgumentCaptor<LeftoverDish> leftoverCaptor = ArgumentCaptor.forClass(LeftoverDish.class);
        verify(leftoverDishRepository).save(leftoverCaptor.capture());
        assertThat(leftoverCaptor.getValue().getOriginalDishId()).isEqualTo(100L);
    }

    @Test
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
        ingredient.setSourceType("INVENTORY");
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
    void testFinishCooking_NoCompletedDishes() {
        // Given
        FinishCookingRequest request = new FinishCookingRequest();
        request.setSessionId(200L);
        request.setConsumedAt(LocalDateTime.now());
        request.setCompletedDishIds(Arrays.asList(999L)); // 不存在的 dishId

        when(sessionRepository.findById(200L)).thenReturn(Optional.of(session));

        // When & Then
        assertThatThrownBy(() -> cookingWorkflowService.finishCooking(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("没有已完成的菜品");

        verify(leftoverDishRepository, never()).save(any());
    }
}

