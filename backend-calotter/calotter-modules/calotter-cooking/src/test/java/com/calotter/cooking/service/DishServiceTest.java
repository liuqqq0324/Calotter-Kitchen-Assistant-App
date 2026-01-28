package com.calotter.cooking.service;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.domain.enums.DifficultyLevel;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.AiRecipeResponse;
import com.calotter.user.domain.entity.Household;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

/**
 * DishService 单元测试
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("菜品服务测试")
class DishServiceTest {

    @Mock
    private DishRepository dishRepository;

    @InjectMocks
    private DishService dishService;

    private Household household;
    private AiRecipeResponse aiResponse;

    @BeforeEach
    void setUp() {
        household = new Household();
        household.setId(1L);
        
        // 准备AI响应数据
        aiResponse = new AiRecipeResponse();
        
        AiRecipeResponse.GeneratedDish mainDish = new AiRecipeResponse.GeneratedDish();
        mainDish.setDishName("红烧肉");
        mainDish.setDescription("经典红烧肉");
        mainDish.setTotalTimeMin(60);
        mainDish.setDifficulty("MEDIUM");
        
        // 准备食材
        AiRecipeResponse.RequiredIngredient ingredient1 = new AiRecipeResponse.RequiredIngredient();
        ingredient1.setName("五花肉");
        ingredient1.setAmountValue(500.0);
        ingredient1.setAmountUnit("g");
        
        AiRecipeResponse.RequiredIngredient ingredient2 = new AiRecipeResponse.RequiredIngredient();
        ingredient2.setName("生抽");
        ingredient2.setAmountValue(30.0);
        ingredient2.setAmountUnit("ml"); // ml 单位不累加重量
        
        AiRecipeResponse.RequiredIngredient ingredient3 = new AiRecipeResponse.RequiredIngredient();
        ingredient3.setName("糖");
        ingredient3.setAmountValue(20.0);
        ingredient3.setAmountUnit("g");
        
        mainDish.setIngredients(Arrays.asList(ingredient1, ingredient2, ingredient3));
        
        // 准备步骤
        AiRecipeResponse.CookingStep step1 = new AiRecipeResponse.CookingStep();
        step1.setStepNumber(1);
        step1.setInstruction("切肉");
        step1.setTimeMin(10);
        
        AiRecipeResponse.CookingStep step2 = new AiRecipeResponse.CookingStep();
        step2.setStepNumber(2);
        step2.setInstruction("炒制");
        step2.setTimeMin(30);
        
        mainDish.setSteps(Arrays.asList(step1, step2));
        aiResponse.setDishes(Arrays.asList(mainDish));
        
        // 准备营养信息
        AiRecipeResponse.NutritionSummary nutrition = new AiRecipeResponse.NutritionSummary();
        nutrition.setCalories(2000);
        nutrition.setProtein(100);
        nutrition.setFat(150);
        nutrition.setCarb(50);
        nutrition.setFiber(5);
        aiResponse.setTotalNutrition(nutrition);
    }

    @Test
    @DisplayName("从AI响应创建Dish - 成功")
    void testCreateDishFromAiResponse_Success() {
        // Given
        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getName()).isEqualTo("红烧肉");
        assertThat(result.getDescription()).isEqualTo("经典红烧肉");
        assertThat(result.getCookingTimeMinutes()).isEqualTo(60);
        assertThat(result.getDifficulty()).isEqualTo(DifficultyLevel.MEDIUM);
        assertThat(result.getTotalCalories()).isEqualTo(2000);
        assertThat(result.getTotalProtein()).isEqualTo(100.0);
        assertThat(result.getTotalFat()).isEqualTo(150.0);
        assertThat(result.getTotalCarb()).isEqualTo(50.0);
        assertThat(result.getTotalFiber()).isEqualTo(5.0);
        // 只累加单位为 g 的食材：500g + 20g = 520g
        assertThat(result.getTotalWeightGram()).isEqualTo(520);
        assertThat(result.getSteps()).hasSize(2);
        assertThat(result.getIngredientSnapshots()).hasSize(3);
        assertThat(result.getTags()).isEmpty();
        assertThat(result.getHousehold()).isEqualTo(household);
    }

    @Test
    void testCreateDishFromAiResponse_NullResponse() {
        // When & Then
        assertThatThrownBy(() -> dishService.createDishFromAiResponse(null, household))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("AI响应数据不完整");
    }

    @Test
    void testCreateDishFromAiResponse_EmptyDishes() {
        // Given
        aiResponse.setDishes(new ArrayList<>());

        // When & Then
        assertThatThrownBy(() -> dishService.createDishFromAiResponse(aiResponse, household))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("AI响应数据不完整");
    }

    @Test
    void testCreateDishFromAiResponse_NullDishes() {
        // Given
        aiResponse.setDishes(null);

        // When & Then
        assertThatThrownBy(() -> dishService.createDishFromAiResponse(aiResponse, household))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("AI响应数据不完整");
    }

    @Test
    void testCreateDishFromAiResponse_InvalidDifficulty() {
        // Given
        aiResponse.getDishes().get(0).setDifficulty("UNKNOWN");

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 应该使用默认值MEDIUM
        assertThat(result.getDifficulty()).isEqualTo(DifficultyLevel.MEDIUM);
    }

    @Test
    void testCreateDishFromAiResponse_NullDifficulty() {
        // Given
        aiResponse.getDishes().get(0).setDifficulty(null);

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 难度应该为null（未设置）
        assertThat(result.getDifficulty()).isNull();
    }

    @Test
    void testCreateDishFromAiResponse_LowercaseDifficulty() {
        // Given
        aiResponse.getDishes().get(0).setDifficulty("easy");

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 应该转换为大写
        assertThat(result.getDifficulty()).isEqualTo(DifficultyLevel.EASY);
    }

    @Test
    void testCreateDishFromAiResponse_NoWeightIngredients_UsesDefault() {
        // Given: 移除所有单位为 g 的食材，或者改为非 g 单位
        AiRecipeResponse.RequiredIngredient ingredient = new AiRecipeResponse.RequiredIngredient();
        ingredient.setName("油");
        ingredient.setAmountValue(30.0);
        ingredient.setAmountUnit("ml"); // ml 不累加重量
        aiResponse.getDishes().get(0).setIngredients(Arrays.asList(ingredient));

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 应该使用默认值1000g
        assertThat(result.getTotalWeightGram()).isEqualTo(1000);
    }

    @Test
    void testCreateDishFromAiResponse_NoIngredients_UsesDefault() {
        // Given
        aiResponse.getDishes().get(0).setIngredients(new ArrayList<>());

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 应该使用默认值1000g
        assertThat(result.getTotalWeightGram()).isEqualTo(1000);
    }

    @Test
    void testCreateDishFromAiResponse_NullNutrition() {
        // Given
        aiResponse.setTotalNutrition(null);

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 营养信息应该为null
        assertThat(result.getTotalCalories()).isNull();
        assertThat(result.getTotalProtein()).isNull();
        assertThat(result.getTotalFat()).isNull();
        assertThat(result.getTotalCarb()).isNull();
        assertThat(result.getTotalFiber()).isNull();
    }

    @Test
    void testCreateDishFromAiResponse_NullNutritionFields() {
        // Given
        AiRecipeResponse.NutritionSummary nutrition = new AiRecipeResponse.NutritionSummary();
        nutrition.setCalories(2000);
        nutrition.setProtein(null);
        nutrition.setFat(null);
        nutrition.setCarb(null);
        nutrition.setFiber(null);
        aiResponse.setTotalNutrition(nutrition);

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: calories 应该设置，其他为 null
        assertThat(result.getTotalCalories()).isEqualTo(2000);
        assertThat(result.getTotalProtein()).isNull();
        assertThat(result.getTotalFat()).isNull();
        assertThat(result.getTotalCarb()).isNull();
        assertThat(result.getTotalFiber()).isNull();
    }

    @Test
    void testCreateDishFromAiResponse_NoSteps() {
        // Given
        aiResponse.getDishes().get(0).setSteps(null);

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 步骤应该为null
        assertThat(result.getSteps()).isNull();
    }

    @Test
    void testCreateDishFromAiResponse_EmptySteps() {
        // Given
        aiResponse.getDishes().get(0).setSteps(new ArrayList<>());

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 步骤应该为空列表
        assertThat(result.getSteps()).isEmpty();
    }

    @Test
    void testCreateDishFromAiResponse_NoIngredientSnapshots() {
        // Given
        aiResponse.getDishes().get(0).setIngredients(null);

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 食材快照应该为null
        assertThat(result.getIngredientSnapshots()).isNull();
    }

    @Test
    void testCreateDishFromAiResponse_IngredientWithNullValues() {
        // Given: 食材有 null 值
        AiRecipeResponse.RequiredIngredient ingredient = new AiRecipeResponse.RequiredIngredient();
        ingredient.setName("盐");
        ingredient.setAmountValue(null);
        ingredient.setAmountUnit(null);
        aiResponse.getDishes().get(0).setIngredients(Arrays.asList(ingredient));

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 应该使用默认值
        assertThat(result.getIngredientSnapshots()).hasSize(1);
        assertThat(result.getIngredientSnapshots().get(0).getAmountValue()).isEqualTo(0.0);
        assertThat(result.getIngredientSnapshots().get(0).getAmountUnit()).isEqualTo("g");
    }

    @Test
    void testCreateDishFromAiResponse_MultipleDishes_UsesFirst() {
        // Given: 多个菜品，应该只使用第一个
        AiRecipeResponse.GeneratedDish dish2 = new AiRecipeResponse.GeneratedDish();
        dish2.setDishName("配菜");
        dish2.setTotalTimeMin(20);
        dish2.setDifficulty("EASY");
        dish2.setIngredients(new ArrayList<>());
        
        aiResponse.setDishes(Arrays.asList(aiResponse.getDishes().get(0), dish2));

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 应该使用第一个菜品的信息
        assertThat(result.getName()).isEqualTo("红烧肉");
        assertThat(result.getCookingTimeMinutes()).isEqualTo(60);
        // 但是重量应该累加所有菜品的食材
        assertThat(result.getTotalWeightGram()).isEqualTo(520); // 第一个菜品的重量
    }

    @Test
    void testCreateDishFromAiResponse_MultipleDishes_WeightAccumulation() {
        // Given: 多个菜品，重量应该累加所有菜品的 g 单位食材
        AiRecipeResponse.GeneratedDish dish2 = new AiRecipeResponse.GeneratedDish();
        dish2.setDishName("配菜");
        
        AiRecipeResponse.RequiredIngredient ingredient = new AiRecipeResponse.RequiredIngredient();
        ingredient.setName("蔬菜");
        ingredient.setAmountValue(200.0);
        ingredient.setAmountUnit("g");
        dish2.setIngredients(Arrays.asList(ingredient));
        
        aiResponse.setDishes(Arrays.asList(aiResponse.getDishes().get(0), dish2));

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 重量应该累加所有菜品：520g (第一个) + 200g (第二个) = 720g
        assertThat(result.getTotalWeightGram()).isEqualTo(720);
    }

    @Test
    @DisplayName("从AI响应创建Dish - 包含分类")
    void testCreateDishFromAiResponse_WithCategory() {
        // Given
        aiResponse.getDishes().get(0).setCategory("MAIN_COURSE");

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then
        assertThat(result.getCategory()).isNotNull();
        assertThat(result.getCategory().name()).isEqualTo("MAIN_COURSE");
    }

    @Test
    @DisplayName("从AI响应创建Dish - 无效分类")
    void testCreateDishFromAiResponse_InvalidCategory() {
        // Given
        aiResponse.getDishes().get(0).setCategory("INVALID_CATEGORY");

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 无效分类应该设置为null
        assertThat(result.getCategory()).isNull();
    }

    @Test
    @DisplayName("从AI响应创建Dish - 分类为null")
    void testCreateDishFromAiResponse_NullCategory() {
        // Given
        aiResponse.getDishes().get(0).setCategory(null);

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: null分类应该保持为null
        assertThat(result.getCategory()).isNull();
    }

    @Test
    @DisplayName("从AI响应创建Dish - 小写分类")
    void testCreateDishFromAiResponse_LowercaseCategory() {
        // Given
        aiResponse.getDishes().get(0).setCategory("main_course");

        when(dishRepository.save(any(Dish.class))).thenAnswer(invocation -> {
            Dish dish = invocation.getArgument(0);
            dish.setId(1L);
            return dish;
        });

        // When
        Dish result = dishService.createDishFromAiResponse(aiResponse, household);

        // Then: 应该转换为大写
        assertThat(result.getCategory()).isNotNull();
        assertThat(result.getCategory().name()).isEqualTo("MAIN_COURSE");
    }
}
