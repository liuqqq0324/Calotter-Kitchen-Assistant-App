package com.calotter.cooking.service;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.domain.enums.DifficultyLevel;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.AiRecipeResponse;
import com.calotter.user.domain.entity.Household;
import org.junit.jupiter.api.BeforeEach;
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
        ingredient2.setAmountUnit("ml");
        
        mainDish.setIngredients(Arrays.asList(ingredient1, ingredient2));
        
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
    void testCreateDishFromAiResponse_Success() {
        // Given
        Dish savedDish = new Dish();
        savedDish.setId(1L);
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
        assertThat(result.getTotalWeightGram()).isEqualTo(500); // 只累加单位为g的食材
        assertThat(result.getSteps()).hasSize(2);
        assertThat(result.getIngredientSnapshots()).hasSize(2);
        assertThat(result.getTags()).isEmpty();
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
    void testCreateDishFromAiResponse_NoWeightUsesDefault() {
        // Given: 移除所有食材或改为非g单位
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
    }
}

