package com.calotter.inventory.service;

import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.domain.entity.StandardSpice;
import com.calotter.common.core.domain.entity.StandardUtensil;
import com.calotter.inventory.controller.dto.*;
import com.calotter.inventory.domain.entity.HouseholdSpice;
import com.calotter.inventory.domain.entity.HouseholdUtensil;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.*;
import com.calotter.common.core.repository.StandardIngredientRepository;
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

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * InventoryService 完整单元测试
 * 覆盖所有功能：食材、调料、厨具、剩菜管理，以及标准库查询和单位验证
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("库存服务测试")
class InventoryServiceTest {

    @Mock
    private IngredientRepository ingredientRepository;
    
    @Mock
    private HouseholdSpiceRepository spiceRepository;
    
    @Mock
    private HouseholdUtensilRepository utensilRepository;
    
    @Mock
    private LeftoverDishRepository leftoverRepository;
    
    @Mock
    private StandardIngredientRepository standardIngredientRepository;
    
    @Mock
    private StandardSpiceRepository standardSpiceRepository;
    
    @Mock
    private StandardUtensilRepository standardUtensilRepository;
    
    @Mock
    private HouseholdRepository householdRepository;
    
    @Mock
    private UnitValidationService unitValidationService;

    @InjectMocks
    private InventoryService inventoryService;

    private Household household;
    private StandardIngredient standardIngredient;
    private StandardSpice standardSpice;
    private StandardUtensil standardUtensil;

    @BeforeEach
    void setUp() {
        // 设置测试家庭
        household = new Household();
        household.setId(1L);
        household.setName("测试家庭");

        // 设置标准食材
        standardIngredient = new StandardIngredient();
        standardIngredient.setId(1001L);
        standardIngredient.setName("鸡蛋");
        standardIngredient.setCategory("MEAT");
        standardIngredient.setPrimaryUnit("pcs");
        standardIngredient.setSecondaryUnit("g");
        standardIngredient.setUnitConversionFactor(50.0);
        standardIngredient.setStandardUnit("g");

        // 设置标准调料
        standardSpice = new StandardSpice();
        standardSpice.setId(3001L);
        standardSpice.setName("酱油");

        // 设置标准厨具
        standardUtensil = new StandardUtensil();
        standardUtensil.setId(2001L);
        standardUtensil.setName("平底锅");
        standardUtensil.setIconUrl("icon_pan.png");
    }

    // ==================== 食材管理测试 ====================

    @Test
    @DisplayName("创建食材 - 成功")
    void testCreateIngredient_Success() {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(1L);
        request.setStandardIngredientId(1001L);
        request.setQuantity(10.0);
        request.setUnit("pcs");
        request.setExpirationDate(LocalDate.now().plusDays(7));
        request.setLocation("FRIDGE");

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenAnswer(invocation -> {
            Ingredient saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });
        doNothing().when(unitValidationService).validateUnit(anyLong(), anyString());

        // When
        IngredientResponse response = inventoryService.createIngredient(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getHouseholdId()).isEqualTo(1L);
        assertThat(response.getStandardIngredientId()).isEqualTo(1001L);
        assertThat(response.getStandardIngredientName()).isEqualTo("鸡蛋");
        assertThat(response.getQuantity()).isEqualTo(10.0);
        assertThat(response.getUnit()).isEqualTo("pcs");
        assertThat(response.getExpirationDate()).isNotNull();
        assertThat(response.getLocation()).isEqualTo("FRIDGE");

        verify(unitValidationService, times(1)).validateUnit(1001L, "pcs");
        verify(ingredientRepository, times(1)).save(any(Ingredient.class));
    }

    @Test
    @DisplayName("创建食材 - 家庭不存在")
    void testCreateIngredient_HouseholdNotFound() {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(999L);
        request.setStandardIngredientId(1001L);
        request.setQuantity(10.0);
        request.setUnit("pcs");

        when(householdRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createIngredient(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(ingredientRepository, never()).save(any());
    }

    @Test
    @DisplayName("创建食材 - 标准食材不存在")
    void testCreateIngredient_StandardIngredientNotFound() {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(1L);
        request.setStandardIngredientId(9999L);
        request.setQuantity(10.0);
        request.setUnit("pcs");

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardIngredientRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createIngredient(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准食材不存在");

        verify(ingredientRepository, never()).save(any());
    }

    @Test
    @DisplayName("创建食材 - 标准食材ID为空")
    void testCreateIngredient_StandardIngredientIdNull() {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(1L);
        request.setStandardIngredientId(null);
        request.setQuantity(10.0);
        request.setUnit("pcs");

        // When & Then
        assertThatThrownBy(() -> inventoryService.createIngredient(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准食材ID不能为空");

        verify(ingredientRepository, never()).save(any());
    }

    @Test
    @DisplayName("创建食材 - 单位验证失败")
    void testCreateIngredient_InvalidUnit() {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(1L);
        request.setStandardIngredientId(1001L);
        request.setQuantity(10.0);
        request.setUnit("invalid_unit");

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));
        doThrow(new IllegalArgumentException("单位不合法")).when(unitValidationService).validateUnit(1001L, "invalid_unit");

        // When & Then
        assertThatThrownBy(() -> inventoryService.createIngredient(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("单位不合法");

        verify(ingredientRepository, never()).save(any());
    }

    @Test
    @DisplayName("更新食材 - 成功")
    void testUpdateIngredient_Success() {
        // Given
        Ingredient existingIngredient = new Ingredient();
        existingIngredient.setId(1L);
        existingIngredient.setHousehold(household);
        existingIngredient.setMetadata(standardIngredient);
        existingIngredient.setQuantity(10.0);
        existingIngredient.setUnit("pcs");

        IngredientRequest request = new IngredientRequest();
        request.setQuantity(20.0);
        request.setUnit("g");
        request.setLocation("FREEZER");

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(existingIngredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenReturn(existingIngredient);
        doNothing().when(unitValidationService).validateUnit(anyLong(), anyString());

        // When
        IngredientResponse response = inventoryService.updateIngredient(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(existingIngredient.getQuantity()).isEqualTo(20.0);
        assertThat(existingIngredient.getUnit()).isEqualTo("g");
        assertThat(existingIngredient.getLocation()).isEqualTo("FREEZER");
        verify(unitValidationService, times(1)).validateUnit(1001L, "g");
        verify(ingredientRepository, times(1)).save(existingIngredient);
    }

    @Test
    @DisplayName("更新食材 - 部分更新")
    void testUpdateIngredient_PartialUpdate() {
        // Given
        Ingredient existingIngredient = new Ingredient();
        existingIngredient.setId(1L);
        existingIngredient.setHousehold(household);
        existingIngredient.setMetadata(standardIngredient);
        existingIngredient.setQuantity(10.0);
        existingIngredient.setUnit("pcs");
        existingIngredient.setLocation("FRIDGE");

        IngredientRequest request = new IngredientRequest();
        request.setQuantity(15.0);
        // 其他字段为 null，不应更新

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(existingIngredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenReturn(existingIngredient);

        // When
        IngredientResponse response = inventoryService.updateIngredient(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(existingIngredient.getQuantity()).isEqualTo(15.0);
        assertThat(existingIngredient.getUnit()).isEqualTo("pcs"); // 保持不变
        assertThat(existingIngredient.getLocation()).isEqualTo("FRIDGE"); // 保持不变
        verify(ingredientRepository, times(1)).save(existingIngredient);
    }

    @Test
    @DisplayName("更新食材 - 食材不存在")
    void testUpdateIngredient_NotFound() {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setQuantity(20.0);

        when(ingredientRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateIngredient(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("食材不存在");

        verify(ingredientRepository, never()).save(any());
    }

    @Test
    @DisplayName("更新食材 - 更新标准食材ID")
    void testUpdateIngredient_UpdateStandardIngredientId() {
        // Given
        Ingredient existingIngredient = new Ingredient();
        existingIngredient.setId(1L);
        existingIngredient.setHousehold(household);
        existingIngredient.setMetadata(standardIngredient);
        existingIngredient.setQuantity(10.0);
        existingIngredient.setUnit("pcs");

        StandardIngredient newStandardIngredient = new StandardIngredient();
        newStandardIngredient.setId(1002L);
        newStandardIngredient.setName("牛奶");
        newStandardIngredient.setPrimaryUnit("ml");
        newStandardIngredient.setSecondaryUnit("L");

        IngredientRequest request = new IngredientRequest();
        request.setStandardIngredientId(1002L);
        request.setQuantity(500.0);
        request.setUnit("ml");

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(existingIngredient));
        when(standardIngredientRepository.findById(1002L)).thenReturn(Optional.of(newStandardIngredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenReturn(existingIngredient);
        doNothing().when(unitValidationService).validateUnit(anyLong(), anyString());

        // When
        IngredientResponse response = inventoryService.updateIngredient(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(existingIngredient.getMetadata().getId()).isEqualTo(1002L);
        assertThat(existingIngredient.getQuantity()).isEqualTo(500.0);
        assertThat(existingIngredient.getUnit()).isEqualTo("ml");
        verify(unitValidationService, times(1)).validateUnit(1002L, "ml");
        verify(ingredientRepository, times(1)).save(existingIngredient);
    }

    @Test
    @DisplayName("更新食材 - 更新标准食材ID但标准食材不存在")
    void testUpdateIngredient_StandardIngredientNotFound() {
        // Given
        Ingredient existingIngredient = new Ingredient();
        existingIngredient.setId(1L);
        existingIngredient.setHousehold(household);
        existingIngredient.setMetadata(standardIngredient);

        IngredientRequest request = new IngredientRequest();
        request.setStandardIngredientId(9999L);

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(existingIngredient));
        when(standardIngredientRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateIngredient(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准食材不存在");

        verify(ingredientRepository, never()).save(any());
    }

    @Test
    @DisplayName("获取食材详情 - 成功")
    void testGetIngredient_Success() {
        // Given
        Ingredient ingredient = new Ingredient();
        ingredient.setId(1L);
        ingredient.setHousehold(household);
        ingredient.setMetadata(standardIngredient);
        ingredient.setQuantity(10.0);
        ingredient.setUnit("pcs");

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(ingredient));

        // When
        IngredientResponse response = inventoryService.getIngredient(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getStandardIngredientName()).isEqualTo("鸡蛋");
        assertThat(response.getQuantity()).isEqualTo(10.0);
    }

    @Test
    @DisplayName("获取食材详情 - 不存在")
    void testGetIngredient_NotFound() {
        // Given
        when(ingredientRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.getIngredient(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("食材不存在");
    }

    @Test
    @DisplayName("获取家庭食材列表 - 成功")
    void testGetIngredientsByHousehold_Success() {
        // Given
        Ingredient ingredient1 = new Ingredient();
        ingredient1.setId(1L);
        ingredient1.setHousehold(household);
        ingredient1.setMetadata(standardIngredient);
        ingredient1.setQuantity(10.0);
        ingredient1.setUnit("pcs");

        Ingredient ingredient2 = new Ingredient();
        ingredient2.setId(2L);
        ingredient2.setHousehold(household);
        ingredient2.setMetadata(standardIngredient);
        ingredient2.setQuantity(500.0);
        ingredient2.setUnit("g");

        when(ingredientRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(ingredient1, ingredient2));

        // When
        List<IngredientResponse> responses = inventoryService.getIngredientsByHousehold(1L);

        // Then
        assertThat(responses).hasSize(2);
        assertThat(responses.get(0).getId()).isEqualTo(1L);
        assertThat(responses.get(1).getId()).isEqualTo(2L);
    }

    @Test
    @DisplayName("获取家庭食材列表 - 空列表")
    void testGetIngredientsByHousehold_EmptyList() {
        // Given
        when(ingredientRepository.findByHouseholdId(1L)).thenReturn(Collections.emptyList());

        // When
        List<IngredientResponse> responses = inventoryService.getIngredientsByHousehold(1L);

        // Then
        assertThat(responses).isEmpty();
    }

    @Test
    @DisplayName("删除食材 - 成功")
    void testDeleteIngredient_Success() {
        // Given
        when(ingredientRepository.existsById(1L)).thenReturn(true);
        doNothing().when(ingredientRepository).deleteById(1L);

        // When
        inventoryService.deleteIngredient(1L);

        // Then
        verify(ingredientRepository, times(1)).existsById(1L);
        verify(ingredientRepository, times(1)).deleteById(1L);
    }

    @Test
    @DisplayName("删除食材 - 不存在")
    void testDeleteIngredient_NotFound() {
        // Given
        when(ingredientRepository.existsById(1L)).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> inventoryService.deleteIngredient(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("食材不存在");

        verify(ingredientRepository, never()).deleteById(any());
    }

    @Test
    @DisplayName("扣减食材库存 - 成功")
    void testDeductIngredient_Success() {
        // Given
        Ingredient ingredient = new Ingredient();
        ingredient.setId(1L);
        ingredient.setQuantity(100.0);

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(ingredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenReturn(ingredient);

        // When
        inventoryService.deductIngredient(1L, 30.0);

        // Then
        assertThat(ingredient.getQuantity()).isEqualTo(70.0);
        verify(ingredientRepository, times(1)).save(ingredient);
    }

    @Test
    @DisplayName("扣减食材库存 - 库存不足")
    void testDeductIngredient_InsufficientStock() {
        // Given
        Ingredient ingredient = new Ingredient();
        ingredient.setId(1L);
        ingredient.setQuantity(10.0);

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(ingredient));

        // When & Then
        assertThatThrownBy(() -> inventoryService.deductIngredient(1L, 20.0))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("库存不足");

        verify(ingredientRepository, never()).save(any());
    }

    @Test
    @DisplayName("扣减食材库存 - 食材不存在")
    void testDeductIngredient_NotFound() {
        // Given
        when(ingredientRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.deductIngredient(1L, 10.0))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("食材不存在");
    }

    // ==================== 调料管理测试 ====================

    @Test
    @DisplayName("创建调料 - 成功")
    void testCreateSpice_Success() {
        // Given
        SpiceRequest request = new SpiceRequest();
        request.setHouseholdId(1L);
        request.setStandardSpiceId(3001L);
        request.setIsAvailable(true);
        request.setRemark("新买的");

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardSpiceRepository.findById(3001L)).thenReturn(Optional.of(standardSpice));
        when(spiceRepository.save(any(HouseholdSpice.class))).thenAnswer(invocation -> {
            HouseholdSpice saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        SpiceResponse response = inventoryService.createSpice(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getHouseholdId()).isEqualTo(1L);
        assertThat(response.getStandardSpiceId()).isEqualTo(3001L);
        assertThat(response.getStandardSpiceName()).isEqualTo("酱油");
        assertThat(response.getIsAvailable()).isTrue();
        assertThat(response.getRemark()).isEqualTo("新买的");

        ArgumentCaptor<HouseholdSpice> captor = ArgumentCaptor.forClass(HouseholdSpice.class);
        verify(spiceRepository, times(1)).save(captor.capture());
        assertThat(captor.getValue().getIsAvailable()).isTrue();
    }

    @Test
    @DisplayName("创建调料 - 家庭不存在")
    void testCreateSpice_HouseholdNotFound() {
        // Given
        SpiceRequest request = new SpiceRequest();
        request.setHouseholdId(999L);
        request.setStandardSpiceId(3001L);
        request.setIsAvailable(true);

        when(householdRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createSpice(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(spiceRepository, never()).save(any());
    }

    @Test
    @DisplayName("创建调料 - 标准调料不存在")
    void testCreateSpice_StandardSpiceNotFound() {
        // Given
        SpiceRequest request = new SpiceRequest();
        request.setHouseholdId(1L);
        request.setStandardSpiceId(9999L);
        request.setIsAvailable(true);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardSpiceRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createSpice(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准调料不存在");

        verify(spiceRepository, never()).save(any());
    }

    @Test
    @DisplayName("更新调料 - 成功")
    void testUpdateSpice_Success() {
        // Given
        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setHousehold(household);
        spice.setMetadata(standardSpice);
        spice.setIsAvailable(true);

        SpiceRequest request = new SpiceRequest();
        request.setIsAvailable(false);
        request.setRemark("用完了");

        when(spiceRepository.findById(1L)).thenReturn(Optional.of(spice));
        when(spiceRepository.save(any(HouseholdSpice.class))).thenReturn(spice);

        // When
        SpiceResponse response = inventoryService.updateSpice(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(spice.getIsAvailable()).isFalse();
        assertThat(spice.getRemark()).isEqualTo("用完了");
        verify(spiceRepository, times(1)).save(spice);
    }

    @Test
    @DisplayName("更新调料 - 更新标准调料ID")
    void testUpdateSpice_UpdateStandardSpiceId() {
        // Given
        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setHousehold(household);
        spice.setMetadata(standardSpice);

        StandardSpice newStandardSpice = new StandardSpice();
        newStandardSpice.setId(3002L);
        newStandardSpice.setName("盐");

        SpiceRequest request = new SpiceRequest();
        request.setStandardSpiceId(3002L);
        request.setIsAvailable(true);

        when(spiceRepository.findById(1L)).thenReturn(Optional.of(spice));
        when(standardSpiceRepository.findById(3002L)).thenReturn(Optional.of(newStandardSpice));
        when(spiceRepository.save(any(HouseholdSpice.class))).thenReturn(spice);

        // When
        SpiceResponse response = inventoryService.updateSpice(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(spice.getMetadata().getId()).isEqualTo(3002L);
        verify(spiceRepository, times(1)).save(spice);
    }

    @Test
    @DisplayName("更新调料 - 标准调料不存在")
    void testUpdateSpice_StandardSpiceNotFound() {
        // Given
        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setHousehold(household);
        spice.setMetadata(standardSpice);

        SpiceRequest request = new SpiceRequest();
        request.setStandardSpiceId(9999L);

        when(spiceRepository.findById(1L)).thenReturn(Optional.of(spice));
        when(standardSpiceRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateSpice(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准调料不存在");

        verify(spiceRepository, never()).save(any());
    }

    @Test
    @DisplayName("获取调料详情 - 成功")
    void testGetSpice_Success() {
        // Given
        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setHousehold(household);
        spice.setMetadata(standardSpice);
        spice.setIsAvailable(true);

        when(spiceRepository.findById(1L)).thenReturn(Optional.of(spice));

        // When
        SpiceResponse response = inventoryService.getSpice(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getStandardSpiceName()).isEqualTo("酱油");
    }

    @Test
    @DisplayName("获取家庭调料列表 - 成功")
    void testGetSpicesByHousehold_Success() {
        // Given
        HouseholdSpice spice1 = new HouseholdSpice();
        spice1.setId(1L);
        spice1.setHousehold(household);
        spice1.setMetadata(standardSpice);
        spice1.setIsAvailable(true);

        HouseholdSpice spice2 = new HouseholdSpice();
        spice2.setId(2L);
        spice2.setHousehold(household);
        spice2.setMetadata(standardSpice);
        spice2.setIsAvailable(false);

        when(spiceRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(spice1, spice2));

        // When
        List<SpiceResponse> responses = inventoryService.getSpicesByHousehold(1L);

        // Then
        assertThat(responses).hasSize(2);
    }

    @Test
    @DisplayName("删除调料 - 成功")
    void testDeleteSpice_Success() {
        // Given
        when(spiceRepository.existsById(1L)).thenReturn(true);
        doNothing().when(spiceRepository).deleteById(1L);

        // When
        inventoryService.deleteSpice(1L);

        // Then
        verify(spiceRepository, times(1)).deleteById(1L);
    }

    @Test
    @DisplayName("切换调料可用性 - 从true到false")
    void testToggleSpiceAvailability_TrueToFalse() {
        // Given
        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setIsAvailable(true);

        when(spiceRepository.findById(1L)).thenReturn(Optional.of(spice));
        when(spiceRepository.save(any(HouseholdSpice.class))).thenReturn(spice);

        // When
        SpiceResponse response = inventoryService.toggleSpiceAvailability(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(spice.getIsAvailable()).isFalse();
        verify(spiceRepository, times(1)).save(spice);
    }

    @Test
    @DisplayName("切换调料可用性 - 从false到true")
    void testToggleSpiceAvailability_FalseToTrue() {
        // Given
        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setIsAvailable(false);

        when(spiceRepository.findById(1L)).thenReturn(Optional.of(spice));
        when(spiceRepository.save(any(HouseholdSpice.class))).thenReturn(spice);

        // When
        SpiceResponse response = inventoryService.toggleSpiceAvailability(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(spice.getIsAvailable()).isTrue();
    }

    @Test
    @DisplayName("切换调料可用性 - 从null到true")
    void testToggleSpiceAvailability_NullToTrue() {
        // Given
        HouseholdSpice spice = new HouseholdSpice();
        spice.setId(1L);
        spice.setIsAvailable(null);

        when(spiceRepository.findById(1L)).thenReturn(Optional.of(spice));
        when(spiceRepository.save(any(HouseholdSpice.class))).thenReturn(spice);

        // When
        SpiceResponse response = inventoryService.toggleSpiceAvailability(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(spice.getIsAvailable()).isTrue();
    }

    @Test
    @DisplayName("切换调料可用性 - 调料不存在")
    void testToggleSpiceAvailability_NotFound() {
        // Given
        when(spiceRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.toggleSpiceAvailability(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("调料不存在");

        verify(spiceRepository, never()).save(any());
    }

    // ==================== 厨具管理测试 ====================

    @Test
    @DisplayName("创建厨具 - 成功")
    void testCreateUtensil_Success() {
        // Given
        UtensilRequest request = new UtensilRequest();
        request.setHouseholdId(1L);
        request.setStandardUtensilId(2001L);
        request.setIsAvailable(true);
        request.setRemark("新买的");

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardUtensilRepository.findById(2001L)).thenReturn(Optional.of(standardUtensil));
        when(utensilRepository.save(any(HouseholdUtensil.class))).thenAnswer(invocation -> {
            HouseholdUtensil saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        UtensilResponse response = inventoryService.createUtensil(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getHouseholdId()).isEqualTo(1L);
        assertThat(response.getStandardUtensilId()).isEqualTo(2001L);
        assertThat(response.getStandardUtensilName()).isEqualTo("平底锅");
        assertThat(response.getIsAvailable()).isTrue();
    }

    @Test
    @DisplayName("创建厨具 - 家庭不存在")
    void testCreateUtensil_HouseholdNotFound() {
        // Given
        UtensilRequest request = new UtensilRequest();
        request.setHouseholdId(999L);
        request.setStandardUtensilId(2001L);
        request.setIsAvailable(true);

        when(householdRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createUtensil(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(utensilRepository, never()).save(any());
    }

    @Test
    @DisplayName("创建厨具 - 标准厨具不存在")
    void testCreateUtensil_StandardUtensilNotFound() {
        // Given
        UtensilRequest request = new UtensilRequest();
        request.setHouseholdId(1L);
        request.setStandardUtensilId(9999L);
        request.setIsAvailable(true);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardUtensilRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createUtensil(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准厨具不存在");

        verify(utensilRepository, never()).save(any());
    }

    @Test
    @DisplayName("更新厨具 - 成功")
    void testUpdateUtensil_Success() {
        // Given
        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setId(1L);
        utensil.setHousehold(household);
        utensil.setMetadata(standardUtensil);
        utensil.setIsAvailable(true);

        UtensilRequest request = new UtensilRequest();
        request.setIsAvailable(false);
        request.setRemark("坏了");

        when(utensilRepository.findById(1L)).thenReturn(Optional.of(utensil));
        when(utensilRepository.save(any(HouseholdUtensil.class))).thenReturn(utensil);

        // When
        UtensilResponse response = inventoryService.updateUtensil(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(utensil.getIsAvailable()).isFalse();
        assertThat(utensil.getRemark()).isEqualTo("坏了");
    }

    @Test
    @DisplayName("更新厨具 - 更新标准厨具ID")
    void testUpdateUtensil_UpdateStandardUtensilId() {
        // Given
        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setId(1L);
        utensil.setHousehold(household);
        utensil.setMetadata(standardUtensil);

        StandardUtensil newStandardUtensil = new StandardUtensil();
        newStandardUtensil.setId(2002L);
        newStandardUtensil.setName("炒锅");

        UtensilRequest request = new UtensilRequest();
        request.setStandardUtensilId(2002L);
        request.setIsAvailable(true);

        when(utensilRepository.findById(1L)).thenReturn(Optional.of(utensil));
        when(standardUtensilRepository.findById(2002L)).thenReturn(Optional.of(newStandardUtensil));
        when(utensilRepository.save(any(HouseholdUtensil.class))).thenReturn(utensil);

        // When
        UtensilResponse response = inventoryService.updateUtensil(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(utensil.getMetadata().getId()).isEqualTo(2002L);
        verify(utensilRepository, times(1)).save(utensil);
    }

    @Test
    @DisplayName("更新厨具 - 标准厨具不存在")
    void testUpdateUtensil_StandardUtensilNotFound() {
        // Given
        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setId(1L);
        utensil.setHousehold(household);
        utensil.setMetadata(standardUtensil);

        UtensilRequest request = new UtensilRequest();
        request.setStandardUtensilId(9999L);

        when(utensilRepository.findById(1L)).thenReturn(Optional.of(utensil));
        when(standardUtensilRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateUtensil(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准厨具不存在");

        verify(utensilRepository, never()).save(any());
    }

    @Test
    @DisplayName("获取厨具详情 - 成功")
    void testGetUtensil_Success() {
        // Given
        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setId(1L);
        utensil.setHousehold(household);
        utensil.setMetadata(standardUtensil);
        utensil.setIsAvailable(true);

        when(utensilRepository.findById(1L)).thenReturn(Optional.of(utensil));

        // When
        UtensilResponse response = inventoryService.getUtensil(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getStandardUtensilName()).isEqualTo("平底锅");
    }

    @Test
    @DisplayName("获取家庭厨具列表 - 成功")
    void testGetUtensilsByHousehold_Success() {
        // Given
        HouseholdUtensil utensil1 = new HouseholdUtensil();
        utensil1.setId(1L);
        utensil1.setHousehold(household);
        utensil1.setMetadata(standardUtensil);
        utensil1.setIsAvailable(true);

        HouseholdUtensil utensil2 = new HouseholdUtensil();
        utensil2.setId(2L);
        utensil2.setHousehold(household);
        utensil2.setMetadata(standardUtensil);
        utensil2.setIsAvailable(false);

        when(utensilRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(utensil1, utensil2));

        // When
        List<UtensilResponse> responses = inventoryService.getUtensilsByHousehold(1L);

        // Then
        assertThat(responses).hasSize(2);
    }

    @Test
    @DisplayName("删除厨具 - 成功")
    void testDeleteUtensil_Success() {
        // Given
        when(utensilRepository.existsById(1L)).thenReturn(true);
        doNothing().when(utensilRepository).deleteById(1L);

        // When
        inventoryService.deleteUtensil(1L);

        // Then
        verify(utensilRepository, times(1)).deleteById(1L);
    }

    @Test
    @DisplayName("切换厨具可用性 - 成功")
    void testToggleUtensilAvailability_Success() {
        // Given
        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setId(1L);
        utensil.setIsAvailable(true);

        when(utensilRepository.findById(1L)).thenReturn(Optional.of(utensil));
        when(utensilRepository.save(any(HouseholdUtensil.class))).thenReturn(utensil);

        // When
        UtensilResponse response = inventoryService.toggleUtensilAvailability(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(utensil.getIsAvailable()).isFalse();
    }

    @Test
    @DisplayName("切换厨具可用性 - 从null到true")
    void testToggleUtensilAvailability_NullToTrue() {
        // Given
        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setId(1L);
        utensil.setIsAvailable(null);

        when(utensilRepository.findById(1L)).thenReturn(Optional.of(utensil));
        when(utensilRepository.save(any(HouseholdUtensil.class))).thenReturn(utensil);

        // When
        UtensilResponse response = inventoryService.toggleUtensilAvailability(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(utensil.getIsAvailable()).isTrue();
    }

    @Test
    @DisplayName("切换厨具可用性 - 厨具不存在")
    void testToggleUtensilAvailability_NotFound() {
        // Given
        when(utensilRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.toggleUtensilAvailability(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("厨具不存在");

        verify(utensilRepository, never()).save(any());
    }

    // ==================== 剩菜管理测试 ====================

    @Test
    @DisplayName("创建剩菜 - 成功")
    void testCreateLeftover_Success() {
        // Given
        LeftoverRequest request = new LeftoverRequest();
        request.setHouseholdId(1L);
        request.setOriginalDishId(100L);
        request.setCurrentQuantityGram(500);
        request.setProducedTime(LocalDateTime.now());

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        LeftoverResponse response = inventoryService.createLeftover(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getHouseholdId()).isEqualTo(1L);
        assertThat(response.getOriginalDishId()).isEqualTo(100L);
        assertThat(response.getCurrentQuantityGram()).isEqualTo(500);

        ArgumentCaptor<LeftoverDish> captor = ArgumentCaptor.forClass(LeftoverDish.class);
        verify(leftoverRepository, times(1)).save(captor.capture());
        LeftoverDish saved = captor.getValue();
        assertThat(saved.getOriginalDishId()).isEqualTo(100L);
        assertThat(saved.getCurrentQuantityGram()).isEqualTo(500);
        assertThat(saved.getInitialQuantityGram()).isEqualTo(500); // 初始重量应等于当前重量
    }

    @Test
    @DisplayName("创建剩菜 - 家庭不存在")
    void testCreateLeftover_HouseholdNotFound() {
        // Given
        LeftoverRequest request = new LeftoverRequest();
        request.setHouseholdId(999L);
        request.setOriginalDishId(100L);
        request.setCurrentQuantityGram(500);

        when(householdRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createLeftover(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(leftoverRepository, never()).save(any());
    }

    @Test
    @DisplayName("更新剩菜 - 成功")
    void testUpdateLeftover_Success() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setHousehold(household);
        leftover.setOriginalDishId(100L);
        leftover.setCurrentQuantityGram(300);
        leftover.setInitialQuantityGram(500);

        LeftoverRequest request = new LeftoverRequest();
        request.setCurrentQuantityGram(200);

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenReturn(leftover);

        // When
        LeftoverResponse response = inventoryService.updateLeftover(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(leftover.getCurrentQuantityGram()).isEqualTo(200);
        verify(leftoverRepository, times(1)).save(leftover);
    }

    @Test
    @DisplayName("更新剩菜 - 部分更新")
    void testUpdateLeftover_PartialUpdate() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setHousehold(household);
        leftover.setOriginalDishId(100L);
        leftover.setCurrentQuantityGram(300);

        LeftoverRequest request = new LeftoverRequest();
        request.setCurrentQuantityGram(250);
        // originalDishId 为 null，不应更新

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenReturn(leftover);

        // When
        LeftoverResponse response = inventoryService.updateLeftover(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(leftover.getCurrentQuantityGram()).isEqualTo(250);
        assertThat(leftover.getOriginalDishId()).isEqualTo(100L); // 保持原值
    }

    @Test
    @DisplayName("更新剩菜 - 不存在")
    void testUpdateLeftover_NotFound() {
        // Given
        LeftoverRequest request = new LeftoverRequest();
        request.setCurrentQuantityGram(200);

        when(leftoverRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateLeftover(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("剩菜不存在");

        verify(leftoverRepository, never()).save(any());
    }

    @Test
    @DisplayName("获取剩菜详情 - 成功")
    void testGetLeftover_Success() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setHousehold(household);
        leftover.setOriginalDishId(100L);
        leftover.setCurrentQuantityGram(300);
        leftover.setDishName("测试菜品");
        leftover.setCoverImage("image.jpg");
        leftover.setCaloriesPer100g(200);

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));

        // When
        LeftoverResponse response = inventoryService.getLeftover(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getHouseholdId()).isEqualTo(1L);
        assertThat(response.getOriginalDishId()).isEqualTo(100L);
        assertThat(response.getCurrentQuantityGram()).isEqualTo(300);
        assertThat(response.getDishName()).isEqualTo("测试菜品");
        assertThat(response.getCoverImage()).isEqualTo("image.jpg");
        assertThat(response.getCaloriesPer100g()).isEqualTo(200);
    }

    @Test
    @DisplayName("获取剩菜详情 - 不存在")
    void testGetLeftover_NotFound() {
        // Given
        when(leftoverRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.getLeftover(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("剩菜不存在");
    }

    @Test
    @DisplayName("获取家庭剩菜列表 - 成功")
    void testGetLeftoversByHousehold_Success() {
        // Given
        LeftoverDish leftover1 = new LeftoverDish();
        leftover1.setId(1L);
        leftover1.setHousehold(household);
        leftover1.setOriginalDishId(100L);
        leftover1.setCurrentQuantityGram(300);
        leftover1.setDishName("菜品1");

        LeftoverDish leftover2 = new LeftoverDish();
        leftover2.setId(2L);
        leftover2.setHousehold(household);
        leftover2.setOriginalDishId(200L);
        leftover2.setCurrentQuantityGram(400);
        leftover2.setDishName("菜品2");

        when(leftoverRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(leftover1, leftover2));

        // When
        List<LeftoverResponse> responses = inventoryService.getLeftoversByHousehold(1L);

        // Then
        assertThat(responses).hasSize(2);
        assertThat(responses.get(0).getOriginalDishId()).isEqualTo(100L);
        assertThat(responses.get(1).getOriginalDishId()).isEqualTo(200L);
    }

    @Test
    @DisplayName("删除剩菜 - 成功")
    void testDeleteLeftover_Success() {
        // Given
        when(leftoverRepository.existsById(1L)).thenReturn(true);
        doNothing().when(leftoverRepository).deleteById(1L);

        // When
        inventoryService.deleteLeftover(1L);

        // Then
        verify(leftoverRepository, times(1)).existsById(1L);
        verify(leftoverRepository, times(1)).deleteById(1L);
    }

    @Test
    @DisplayName("删除剩菜 - 不存在")
    void testDeleteLeftover_NotFound() {
        // Given
        when(leftoverRepository.existsById(1L)).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> inventoryService.deleteLeftover(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("剩菜不存在");

        verify(leftoverRepository, never()).deleteById(any());
    }

    @Test
    @DisplayName("部分更新剩菜 - 成功")
    void testPatchLeftover_Success() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setHousehold(household);
        leftover.setOriginalDishId(100L);
        leftover.setCurrentQuantityGram(500);
        leftover.setInitialQuantityGram(1000); // 初始1000g
        leftover.setDishName("测试菜品");
        leftover.setCoverImage("image.jpg");
        leftover.setCaloriesPer100g(200);

        BigDecimal consumedPercentage = new BigDecimal("30.0"); // 消费30%

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenReturn(leftover);

        // When
        LeftoverResponse response = inventoryService.patchLeftover(1L, consumedPercentage);

        // Then
        assertThat(response).isNotNull();
        // 消费30% = 1000 * 0.3 = 300g，剩余 = 500 - 300 = 200g
        assertThat(leftover.getCurrentQuantityGram()).isEqualTo(200);
        verify(leftoverRepository, times(1)).save(leftover);
    }

    @Test
    @DisplayName("部分更新剩菜 - 初始重量无效")
    void testPatchLeftover_InvalidInitialQuantity() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setInitialQuantityGram(null); // 初始重量为null

        BigDecimal consumedPercentage = new BigDecimal("30.0");

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));

        // When & Then
        assertThatThrownBy(() -> inventoryService.patchLeftover(1L, consumedPercentage))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("初始重量无效");

        verify(leftoverRepository, never()).save(any());
    }

    @Test
    @DisplayName("部分更新剩菜 - 消费百分比超出范围")
    void testPatchLeftover_InvalidPercentage() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setInitialQuantityGram(1000);

        BigDecimal consumedPercentage = new BigDecimal("150.0"); // 超出100%

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));

        // When & Then
        assertThatThrownBy(() -> inventoryService.patchLeftover(1L, consumedPercentage))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("消费百分比必须在 0-100 之间");
    }

    @Test
    @DisplayName("部分更新剩菜 - 消费后剩余重量为负")
    void testPatchLeftover_NegativeRemaining() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setCurrentQuantityGram(100); // 当前剩余100g
        leftover.setInitialQuantityGram(1000);

        BigDecimal consumedPercentage = new BigDecimal("50.0"); // 消费50% = 500g，但当前只有100g

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));

        // When & Then
        assertThatThrownBy(() -> inventoryService.patchLeftover(1L, consumedPercentage))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("消费后剩余重量不能小于0");
    }

    @Test
    @DisplayName("部分更新剩菜 - 剩菜不存在")
    void testPatchLeftover_NotFound() {
        // Given
        BigDecimal consumedPercentage = new BigDecimal("30.0");
        when(leftoverRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.patchLeftover(1L, consumedPercentage))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("剩菜不存在");

        verify(leftoverRepository, never()).save(any());
    }

    @Test
    @DisplayName("部分更新剩菜 - 消费百分比为0")
    void testPatchLeftover_ZeroPercentage() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setHousehold(household);
        leftover.setCurrentQuantityGram(500);
        leftover.setInitialQuantityGram(1000);
        leftover.setDishName("测试菜品");
        leftover.setCoverImage("image.jpg");
        leftover.setCaloriesPer100g(200);

        BigDecimal consumedPercentage = new BigDecimal("0.0");

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        LeftoverResponse response = inventoryService.patchLeftover(1L, consumedPercentage);

        // Then
        assertThat(response).isNotNull();
        assertThat(leftover.getCurrentQuantityGram()).isEqualTo(500); // 没有变化
    }

    @Test
    @DisplayName("部分更新剩菜 - 消费百分比为100")
    void testPatchLeftover_OneHundredPercentage() {
        // Given
        LeftoverDish leftover = new LeftoverDish();
        leftover.setId(1L);
        leftover.setHousehold(household);
        leftover.setCurrentQuantityGram(1000);
        leftover.setInitialQuantityGram(1000);
        leftover.setDishName("测试菜品");
        leftover.setCoverImage("image.jpg");
        leftover.setCaloriesPer100g(200);

        BigDecimal consumedPercentage = new BigDecimal("100.0");

        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftover));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        LeftoverResponse response = inventoryService.patchLeftover(1L, consumedPercentage);

        // Then
        assertThat(response).isNotNull();
        assertThat(leftover.getCurrentQuantityGram()).isEqualTo(0); // 全部消费完
    }

    // ==================== 标准库查询测试 ====================

    @Test
    @DisplayName("通过名称查找标准食材 - 成功")
    void testFindStandardIngredientByName_Success() {
        // Given
        when(standardIngredientRepository.findByName("鸡蛋")).thenReturn(Optional.of(standardIngredient));

        // When
        StandardIngredient result = inventoryService.findStandardIngredientByName("鸡蛋");

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("鸡蛋");
    }

    @Test
    @DisplayName("通过名称查找标准食材 - 不存在")
    void testFindStandardIngredientByName_NotFound() {
        // Given
        when(standardIngredientRepository.findByName("不存在的食材")).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.findStandardIngredientByName("不存在的食材"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准食材不存在");
    }

    @Test
    @DisplayName("模糊查找标准食材 - 成功")
    void testSearchStandardIngredientsByName_Success() {
        // Given
        StandardIngredient ingredient1 = new StandardIngredient();
        ingredient1.setId(1001L);
        ingredient1.setName("鸡蛋");

        StandardIngredient ingredient2 = new StandardIngredient();
        ingredient2.setId(1002L);
        ingredient2.setName("鸡蛋饼");

        when(standardIngredientRepository.findByNameContainingIgnoreCase("鸡蛋"))
                .thenReturn(Arrays.asList(ingredient1, ingredient2));

        // When
        List<StandardIngredient> results = inventoryService.searchStandardIngredientsByName("鸡蛋");

        // Then
        assertThat(results).hasSize(2);
        assertThat(results.get(0).getName()).contains("鸡蛋");
    }

    @Test
    @DisplayName("获取所有标准食材 - 成功")
    void testGetAllStandardIngredients_Success() {
        // Given
        StandardIngredient ingredient1 = new StandardIngredient();
        ingredient1.setId(1001L);
        ingredient1.setName("鸡蛋");

        StandardIngredient ingredient2 = new StandardIngredient();
        ingredient2.setId(1002L);
        ingredient2.setName("牛奶");

        when(standardIngredientRepository.findAll())
                .thenReturn(Arrays.asList(ingredient1, ingredient2));

        // When
        List<StandardIngredient> results = inventoryService.getAllStandardIngredients();

        // Then
        assertThat(results).hasSize(2);
    }

    @Test
    @DisplayName("获取所有标准调料 - 成功")
    void testGetAllStandardSpices_Success() {
        // Given
        StandardSpice spice1 = new StandardSpice();
        spice1.setId(3001L);
        spice1.setName("酱油");

        StandardSpice spice2 = new StandardSpice();
        spice2.setId(3002L);
        spice2.setName("盐");

        when(standardSpiceRepository.findAll())
                .thenReturn(Arrays.asList(spice1, spice2));

        // When
        List<StandardSpice> results = inventoryService.getAllStandardSpices();

        // Then
        assertThat(results).hasSize(2);
    }

    @Test
    @DisplayName("获取所有标准厨具 - 成功")
    void testGetAllStandardUtensils_Success() {
        // Given
        StandardUtensil utensil1 = new StandardUtensil();
        utensil1.setId(2001L);
        utensil1.setName("平底锅");

        StandardUtensil utensil2 = new StandardUtensil();
        utensil2.setId(2002L);
        utensil2.setName("炒锅");

        when(standardUtensilRepository.findAll())
                .thenReturn(Arrays.asList(utensil1, utensil2));

        // When
        List<StandardUtensil> results = inventoryService.getAllStandardUtensils();

        // Then
        assertThat(results).hasSize(2);
    }

    @Test
    @DisplayName("获取允许的单位列表 - 成功")
    void testGetAllowedUnits_Success() {
        // Given
        List<String> allowedUnits = Arrays.asList("pcs", "g");
        when(unitValidationService.getAllowedUnits(1001L)).thenReturn(allowedUnits);

        // When
        List<String> results = inventoryService.getAllowedUnits(1001L);

        // Then
        assertThat(results).hasSize(2);
        assertThat(results).containsExactly("pcs", "g");
    }

    // ==================== 边界情况测试 ====================

    @Test
    @DisplayName("创建食材 - 单位为null（允许）")
    void testCreateIngredient_UnitNull() {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(1L);
        request.setStandardIngredientId(1001L);
        request.setQuantity(10.0);
        request.setUnit(null); // 单位可以为null

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenAnswer(invocation -> {
            Ingredient saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        IngredientResponse response = inventoryService.createIngredient(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getUnit()).isNull();
        verify(unitValidationService, never()).validateUnit(anyLong(), anyString());
    }

    @Test
    @DisplayName("更新调料 - 调料不存在")
    void testUpdateSpice_NotFound() {
        // Given
        SpiceRequest request = new SpiceRequest();
        request.setIsAvailable(false);

        when(spiceRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateSpice(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("调料不存在");

        verify(spiceRepository, never()).save(any());
    }

    @Test
    @DisplayName("获取调料详情 - 调料不存在")
    void testGetSpice_NotFound() {
        // Given
        when(spiceRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.getSpice(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("调料不存在");
    }

    @Test
    @DisplayName("获取厨具详情 - 厨具不存在")
    void testGetUtensil_NotFound() {
        // Given
        when(utensilRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.getUtensil(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("厨具不存在");
    }

    @Test
    @DisplayName("更新厨具 - 厨具不存在")
    void testUpdateUtensil_NotFound() {
        // Given
        UtensilRequest request = new UtensilRequest();
        request.setIsAvailable(false);

        when(utensilRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateUtensil(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("厨具不存在");

        verify(utensilRepository, never()).save(any());
    }

    @Test
    @DisplayName("扣减食材库存 - 数量为0")
    void testDeductIngredient_ZeroAmount() {
        // Given
        Ingredient ingredient = new Ingredient();
        ingredient.setId(1L);
        ingredient.setQuantity(100.0);

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(ingredient));
        when(ingredientRepository.save(any(Ingredient.class))).thenReturn(ingredient);

        // When
        inventoryService.deductIngredient(1L, 0.0);

        // Then
        assertThat(ingredient.getQuantity()).isEqualTo(100.0); // 没有变化
        verify(ingredientRepository, times(1)).save(ingredient);
    }

    @Test
    @DisplayName("扣减食材库存 - 数量为负数")
    void testDeductIngredient_NegativeAmount() {
        // Given
        Ingredient ingredient = new Ingredient();
        ingredient.setId(1L);
        ingredient.setQuantity(100.0);

        when(ingredientRepository.findById(1L)).thenReturn(Optional.of(ingredient));

        // When & Then
        assertThatThrownBy(() -> inventoryService.deductIngredient(1L, -10.0))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("库存不足");

        verify(ingredientRepository, never()).save(any());
    }
}
