package com.calotter.cooking.service;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.LeftoverDishDetailDTO;
import com.calotter.cooking.service.dto.LeftoverDishSummaryDTO;
import com.calotter.cooking.service.dto.NutritionInfo;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anySet;
import static org.mockito.Mockito.*;

/**
 * LeftoverDishService 单元测试
 */
@ExtendWith(MockitoExtension.class)
class LeftoverDishServiceTest {

    @Mock
    private LeftoverDishRepository leftoverDishRepository;

    @Mock
    private DishRepository dishRepository;

    @InjectMocks
    private LeftoverDishService leftoverDishService;

    private Dish dish;
    private LeftoverDish leftoverDish;
    private Household household;

    @BeforeEach
    void setUp() {
        household = new Household();
        household.setId(1L);

        dish = new Dish();
        dish.setId(100L);
        dish.setName("红烧肉");
        dish.setDescription("经典红烧肉");
        dish.setCoverImage("http://example.com/image.jpg");
        dish.setTotalCalories(2000);
        dish.setTotalProtein(100.0);
        dish.setTotalFat(150.0);
        dish.setTotalCarb(50.0);
        dish.setTotalFiber(5.0);
        dish.setTotalWeightGram(1000); // 1000g

        leftoverDish = new LeftoverDish();
        leftoverDish.setId(1L);
        leftoverDish.setHousehold(household);
        leftoverDish.setOriginalDishId(100L);
        leftoverDish.setDishName("红烧肉");
        leftoverDish.setCoverImage("http://example.com/image.jpg");
        leftoverDish.setCurrentQuantityGram(300); // 剩余300g
        leftoverDish.setInitialQuantityGram(1000); // 初始1000g
        leftoverDish.setProducedTime(LocalDateTime.now());
        // 设置每100g的营养素快照（基于 dish 的数据计算）
        leftoverDish.setCaloriesPer100g(200); // 2000 / 1000 * 100
        leftoverDish.setProteinPer100g(10.0); // 100 / 1000 * 100
        leftoverDish.setFatPer100g(15.0); // 150 / 1000 * 100
        leftoverDish.setCarbPer100g(5.0); // 50 / 1000 * 100
        leftoverDish.setFiberPer100g(0.5); // 5 / 1000 * 100
    }

    @Test
    void testGetLeftoverDishDetail_Success() {
        // Given
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));
        when(dishRepository.findById(100L)).thenReturn(Optional.of(dish));

        // When
        LeftoverDishDetailDTO result = leftoverDishService.getLeftoverDishDetail(1L);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getOriginalDishId()).isEqualTo(100L);
        assertThat(result.getName()).isEqualTo("红烧肉");
        assertThat(result.getDescription()).isEqualTo("经典红烧肉");
        assertThat(result.getCoverImage()).isEqualTo("http://example.com/image.jpg");
        assertThat(result.getCurrentQuantityGram()).isEqualTo(300);
        
        // 验证营养计算：使用快照数据，300g = 3 * 100g，所以应该是 200 * 3 = 600卡
        assertThat(result.getCurrentCalories()).isEqualTo(600);
        assertThat(result.getCaloriesPer100g()).isEqualTo(200); // 从快照获取
        assertThat(result.getCurrentNutrition()).isNotNull();
        assertThat(result.getCurrentNutrition().getCalories()).isEqualTo(600);
        assertThat(result.getCurrentNutrition().getProtein()).isEqualTo(30.0); // 10.0 * 3
    }

    @Test
    void testGetLeftoverDishDetail_LeftoverNotFound() {
        // Given
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> leftoverDishService.getLeftoverDishDetail(1L))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("剩菜不存在");
    }

    @Test
    void testGetLeftoverDishDetail_DishNotFound() {
        // Given: Dish 不存在，但可以使用快照数据
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));
        when(dishRepository.findById(100L)).thenReturn(Optional.empty());

        // When: 应该能正常返回，使用快照数据
        LeftoverDishDetailDTO result = leftoverDishService.getLeftoverDishDetail(1L);

        // Then: 应该使用快照数据
        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("红烧肉"); // 从快照获取
        assertThat(result.getDescription()).isNull(); // Dish 不存在，description 为 null
        assertThat(result.getCurrentCalories()).isEqualTo(600); // 使用快照数据计算
    }

    @Test
    void testGetLeftoverDishesByHousehold_Success() {
        // Given
        LeftoverDish leftover1 = new LeftoverDish();
        leftover1.setId(1L);
        leftover1.setOriginalDishId(100L);
        leftover1.setCurrentQuantityGram(300);

        LeftoverDish leftover2 = new LeftoverDish();
        leftover2.setId(2L);
        leftover2.setOriginalDishId(101L);
        leftover2.setCurrentQuantityGram(200);

        Dish dish2 = new Dish();
        dish2.setId(101L);
        dish2.setName("糖醋里脊");
        dish2.setCoverImage("http://example.com/image2.jpg");
        dish2.setTotalCalories(1500);
        dish2.setTotalWeightGram(800);

        when(leftoverDishRepository.findByHouseholdId(1L))
            .thenReturn(Arrays.asList(leftover1, leftover2));
        when(dishRepository.findAllById(anySet()))
            .thenReturn(Arrays.asList(dish, dish2));

        // When
        List<LeftoverDishSummaryDTO> result = leftoverDishService.getLeftoverDishesByHousehold(1L);

        // Then
        assertThat(result).hasSize(2);
        assertThat(result.get(0).getName()).isEqualTo("红烧肉");
        assertThat(result.get(0).getCurrentQuantityGram()).isEqualTo(300);
        assertThat(result.get(1).getName()).isEqualTo("糖醋里脊");
        assertThat(result.get(1).getCurrentQuantityGram()).isEqualTo(200);
    }

    @Test
    void testGetLeftoverDishesByHousehold_EmptyList() {
        // Given
        when(leftoverDishRepository.findByHouseholdId(1L)).thenReturn(Collections.emptyList());

        // When
        List<LeftoverDishSummaryDTO> result = leftoverDishService.getLeftoverDishesByHousehold(1L);

        // Then
        assertThat(result).isEmpty();
        verify(dishRepository, never()).findAllById(anySet());
    }

    @Test
    void testCalculateNutritionForConsumption_Success() {
        // Given: 剩菜300g，吃100g（使用快照数据，无需查询 Dish）
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));

        // When
        NutritionInfo result = leftoverDishService.calculateNutritionForConsumption(1L, 100);

        // Then: 100g = 1 * 100g，所以应该是 200 * 1 = 200卡（使用快照数据）
        assertThat(result.getCalories()).isEqualTo(200);
        assertThat(result.getProtein()).isEqualTo(10.0); // 10.0 * 1
        assertThat(result.getFat()).isEqualTo(15.0); // 15.0 * 1
        assertThat(result.getCarb()).isEqualTo(5.0); // 5.0 * 1
        assertThat(result.getFiber()).isEqualTo(0.5); // 0.5 * 1
        
        // 验证没有查询 Dish
        verify(dishRepository, never()).findById(any());
    }

    @Test
    void testCalculateNutritionForConsumption_InvalidWeight() {
        // When & Then
        assertThatThrownBy(() -> leftoverDishService.calculateNutritionForConsumption(1L, 0))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("食用重量必须大于0");

        assertThatThrownBy(() -> leftoverDishService.calculateNutritionForConsumption(1L, -10))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("食用重量必须大于0");
    }

    @Test
    void testCalculateNutritionForConsumption_ExceedsQuantity() {
        // Given: 剩菜300g，尝试吃500g
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));

        // When & Then
        assertThatThrownBy(() -> leftoverDishService.calculateNutritionForConsumption(1L, 500))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("食用重量(500克)超过剩余重量(300克)");
    }

    @Test
    void testCalculateNutritionForConsumption_ZeroWeight() {
        // Given: 快照数据为 null 或 0
        leftoverDish.setCaloriesPer100g(null);
        leftoverDish.setProteinPer100g(null);
        leftoverDish.setFatPer100g(null);
        leftoverDish.setCarbPer100g(null);
        leftoverDish.setFiberPer100g(null);
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));

        // When
        NutritionInfo result = leftoverDishService.calculateNutritionForConsumption(1L, 100);

        // Then: 应该返回0营养（null 值处理为 0）
        assertThat(result.getCalories()).isEqualTo(0);
        assertThat(result.getProtein()).isEqualTo(0.0);
        assertThat(result.getFat()).isEqualTo(0.0);
        assertThat(result.getCarb()).isEqualTo(0.0);
        assertThat(result.getFiber()).isEqualTo(0.0);
        
        // 验证没有查询 Dish
        verify(dishRepository, never()).findById(any());
    }

    @Test
    void testCanConsume_Success() {
        // Given
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));

        // When & Then
        assertThat(leftoverDishService.canConsume(1L, 200)).isTrue();
        assertThat(leftoverDishService.canConsume(1L, 300)).isTrue();
        assertThat(leftoverDishService.canConsume(1L, 400)).isFalse();
    }

    @Test
    void testCanConsume_InvalidInput() {
        // When & Then
        assertThat(leftoverDishService.canConsume(1L, 0)).isFalse();
        assertThat(leftoverDishService.canConsume(1L, -10)).isFalse();
        assertThat(leftoverDishService.canConsume(1L, null)).isFalse();
    }

    @Test
    void testCanConsume_LeftoverNotFound() {
        // Given
        when(leftoverDishRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThat(leftoverDishService.canConsume(999L, 100)).isFalse();
    }
}

