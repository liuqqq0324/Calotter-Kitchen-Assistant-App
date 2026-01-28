package com.calotter.inventory.service;

import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.repository.StandardIngredientRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

/**
 * UnitValidationService 单元测试
 * 测试单位验证和允许单位列表获取功能
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("单位验证服务测试")
class UnitValidationServiceTest {

    @Mock
    private StandardIngredientRepository standardIngredientRepository;

    @InjectMocks
    private UnitValidationService unitValidationService;

    private StandardIngredient standardIngredient;

    @BeforeEach
    void setUp() {
        // 设置标准食材（支持 pcs 和 g 两种单位）
        standardIngredient = new StandardIngredient();
        standardIngredient.setId(1001L);
        standardIngredient.setName("鸡蛋");
        standardIngredient.setPrimaryUnit("pcs");
        standardIngredient.setSecondaryUnit("g");
        standardIngredient.setUnitConversionFactor(50.0);
        standardIngredient.setStandardUnit("g");
    }

    @Test
    @DisplayName("验证单位 - 成功（主单位）")
    void testValidateUnit_Success_PrimaryUnit() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then - 不应抛出异常
        unitValidationService.validateUnit(1001L, "pcs");
        verify(standardIngredientRepository, times(1)).findById(1001L);
    }

    @Test
    @DisplayName("验证单位 - 成功（次单位）")
    void testValidateUnit_Success_SecondaryUnit() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then - 不应抛出异常
        unitValidationService.validateUnit(1001L, "g");
        verify(standardIngredientRepository, times(1)).findById(1001L);
    }

    @Test
    @DisplayName("验证单位 - 成功（大小写不敏感）")
    void testValidateUnit_Success_CaseInsensitive() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then - 不应抛出异常（大小写不敏感）
        unitValidationService.validateUnit(1001L, "PCS");
        unitValidationService.validateUnit(1001L, "G");
        unitValidationService.validateUnit(1001L, "Pcs");
        verify(standardIngredientRepository, times(3)).findById(1001L);
    }

    @Test
    @DisplayName("验证单位 - 标准食材不存在")
    void testValidateUnit_StandardIngredientNotFound() {
        // Given
        when(standardIngredientRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> unitValidationService.validateUnit(9999L, "pcs"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准食材不存在");
    }

    @Test
    @DisplayName("验证单位 - 单位不合法")
    void testValidateUnit_InvalidUnit() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then
        assertThatThrownBy(() -> unitValidationService.validateUnit(1001L, "kg"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("单位 'kg' 不合法");
    }

    @Test
    @DisplayName("验证单位 - 单位不合法（空字符串）")
    void testValidateUnit_InvalidUnit_EmptyString() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then
        assertThatThrownBy(() -> unitValidationService.validateUnit(1001L, ""))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("单位 '' 不合法");
    }

    @Test
    @DisplayName("验证单位 - 单位不合法（null）")
    void testValidateUnit_InvalidUnit_Null() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then
        assertThatThrownBy(() -> unitValidationService.validateUnit(1001L, null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("单位 'null' 不合法");
    }

    @Test
    @DisplayName("验证单位 - 单位不合法（带空格）")
    void testValidateUnit_InvalidUnit_WithSpaces() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then - 带空格的单位应该被trim后验证
        // 注意：isUnitAllowed 方法会 trim，所以 " pcs " 应该能通过验证
        unitValidationService.validateUnit(1001L, " pcs ");
        verify(standardIngredientRepository, times(1)).findById(1001L);
    }

    @Test
    @DisplayName("获取允许的单位列表 - 成功")
    void testGetAllowedUnits_Success() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When
        List<String> allowedUnits = unitValidationService.getAllowedUnits(1001L);

        // Then
        assertThat(allowedUnits).isNotNull();
        assertThat(allowedUnits).hasSize(2);
        assertThat(allowedUnits).containsExactly("pcs", "g");
    }

    @Test
    @DisplayName("获取允许的单位列表 - 标准食材不存在")
    void testGetAllowedUnits_StandardIngredientNotFound() {
        // Given
        when(standardIngredientRepository.findById(9999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> unitValidationService.getAllowedUnits(9999L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("标准食材不存在");
    }

    @Test
    @DisplayName("获取允许的单位列表 - 单位字段为null")
    void testGetAllowedUnits_NullUnits() {
        // Given
        StandardIngredient ingredientWithNullUnits = new StandardIngredient();
        ingredientWithNullUnits.setId(1002L);
        ingredientWithNullUnits.setName("测试食材");
        ingredientWithNullUnits.setPrimaryUnit(null);
        ingredientWithNullUnits.setSecondaryUnit(null);

        when(standardIngredientRepository.findById(1002L)).thenReturn(Optional.of(ingredientWithNullUnits));

        // When
        List<String> allowedUnits = unitValidationService.getAllowedUnits(1002L);

        // Then
        assertThat(allowedUnits).isNotNull();
        assertThat(allowedUnits).isEmpty();
    }

    @Test
    @DisplayName("获取允许的单位列表 - 只有主单位")
    void testGetAllowedUnits_OnlyPrimaryUnit() {
        // Given
        StandardIngredient ingredient = new StandardIngredient();
        ingredient.setId(1003L);
        ingredient.setName("测试食材");
        ingredient.setPrimaryUnit("ml");
        ingredient.setSecondaryUnit(null);

        when(standardIngredientRepository.findById(1003L)).thenReturn(Optional.of(ingredient));

        // When
        List<String> allowedUnits = unitValidationService.getAllowedUnits(1003L);

        // Then
        // 注意：getAllowedUnits 方法会检查 primaryUnit 和 secondaryUnit 是否为 null
        // 如果任一为 null，返回空列表
        assertThat(allowedUnits).isNotNull();
        assertThat(allowedUnits).isEmpty();
    }

    @Test
    @DisplayName("验证单位 - 不同食材的不同单位")
    void testValidateUnit_DifferentIngredients() {
        // Given - 食材1：支持 pcs 和 g
        StandardIngredient ingredient1 = new StandardIngredient();
        ingredient1.setId(1001L);
        ingredient1.setName("鸡蛋");
        ingredient1.setPrimaryUnit("pcs");
        ingredient1.setSecondaryUnit("g");

        // Given - 食材2：支持 ml 和 L
        StandardIngredient ingredient2 = new StandardIngredient();
        ingredient2.setId(1002L);
        ingredient2.setName("牛奶");
        ingredient2.setPrimaryUnit("ml");
        ingredient2.setSecondaryUnit("L");

        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(ingredient1));
        when(standardIngredientRepository.findById(1002L)).thenReturn(Optional.of(ingredient2));

        // When & Then - 食材1应该支持 pcs 和 g
        unitValidationService.validateUnit(1001L, "pcs");
        unitValidationService.validateUnit(1001L, "g");

        // When & Then - 食材2应该支持 ml 和 L
        unitValidationService.validateUnit(1002L, "ml");
        unitValidationService.validateUnit(1002L, "L");

        // When & Then - 食材1不应该支持 ml
        assertThatThrownBy(() -> unitValidationService.validateUnit(1001L, "ml"))
                .isInstanceOf(IllegalArgumentException.class);

        // When & Then - 食材2不应该支持 pcs
        assertThatThrownBy(() -> unitValidationService.validateUnit(1002L, "pcs"))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("验证单位 - 错误消息包含食材名称和允许单位")
    void testValidateUnit_ErrorMessageContainsDetails() {
        // Given
        when(standardIngredientRepository.findById(1001L)).thenReturn(Optional.of(standardIngredient));

        // When & Then
        assertThatThrownBy(() -> unitValidationService.validateUnit(1001L, "kg"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("单位 'kg' 不合法")
                .hasMessageContaining("鸡蛋") // 包含食材名称
                .hasMessageContaining("pcs") // 包含允许的单位
                .hasMessageContaining("g");
    }

    @Test
    @DisplayName("获取允许的单位列表 - 两个单位都存在")
    void testGetAllowedUnits_BothUnitsExist() {
        // Given
        StandardIngredient ingredient = new StandardIngredient();
        ingredient.setId(1004L);
        ingredient.setName("测试食材");
        ingredient.setPrimaryUnit("kg");
        ingredient.setSecondaryUnit("g");

        when(standardIngredientRepository.findById(1004L)).thenReturn(Optional.of(ingredient));

        // When
        List<String> allowedUnits = unitValidationService.getAllowedUnits(1004L);

        // Then
        assertThat(allowedUnits).isNotNull();
        assertThat(allowedUnits).hasSize(2);
        assertThat(allowedUnits).containsExactly("kg", "g");
    }
}

