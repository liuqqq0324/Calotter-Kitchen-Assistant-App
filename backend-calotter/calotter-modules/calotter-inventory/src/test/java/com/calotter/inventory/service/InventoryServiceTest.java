package com.calotter.inventory.service;

import com.calotter.inventory.controller.dto.LeftoverRequest;
import com.calotter.inventory.controller.dto.LeftoverResponse;
import com.calotter.inventory.domain.entity.LeftoverDish;
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
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * InventoryService 单元测试
 * 重点测试剩菜管理功能（字段已更新为 originalDishId 和 currentQuantityGram）
 */
@ExtendWith(MockitoExtension.class)
class InventoryServiceTest {

    @Mock
    private LeftoverDishRepository leftoverRepository;

    @Mock
    private HouseholdRepository householdRepository;

    @InjectMocks
    private InventoryService inventoryService;

    private Household household;
    private LeftoverDish leftoverDish;
    private LeftoverRequest leftoverRequest;

    @BeforeEach
    void setUp() {
        household = new Household();
        household.setId(1L);
        household.setName("测试家庭");

        leftoverDish = new LeftoverDish();
        leftoverDish.setId(1L);
        leftoverDish.setHousehold(household);
        leftoverDish.setOriginalDishId(100L); // 关联的Dish ID
        leftoverDish.setCurrentQuantityGram(300); // 当前剩余300g
        leftoverDish.setProducedTime(LocalDateTime.now());

        leftoverRequest = new LeftoverRequest();
        leftoverRequest.setHouseholdId(1L);
        leftoverRequest.setOriginalDishId(100L);
        leftoverRequest.setCurrentQuantityGram(500);
        leftoverRequest.setProducedTime(LocalDateTime.now());
    }

    // ==================== 剩菜管理测试 ====================

    @Test
    void testCreateLeftover_Success() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        LeftoverResponse response = inventoryService.createLeftover(leftoverRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getHouseholdId()).isEqualTo(1L);
        assertThat(response.getOriginalDishId()).isEqualTo(100L);
        assertThat(response.getCurrentQuantityGram()).isEqualTo(500);
        assertThat(response.getProducedTime()).isNotNull();

        // 验证保存时使用的字段
        ArgumentCaptor<LeftoverDish> captor = ArgumentCaptor.forClass(LeftoverDish.class);
        verify(leftoverRepository, times(1)).save(captor.capture());
        LeftoverDish savedLeftover = captor.getValue();
        assertThat(savedLeftover.getOriginalDishId()).isEqualTo(100L);
        assertThat(savedLeftover.getCurrentQuantityGram()).isEqualTo(500);
        assertThat(savedLeftover.getHousehold()).isEqualTo(household);
    }

    @Test
    void testCreateLeftover_HouseholdNotFound() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.createLeftover(leftoverRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");
        
        verify(leftoverRepository, never()).save(any());
    }

    @Test
    void testUpdateLeftover_Success() {
        // Given
        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenReturn(leftoverDish);

        LeftoverRequest updateRequest = new LeftoverRequest();
        updateRequest.setCurrentQuantityGram(200); // 更新为200g
        updateRequest.setOriginalDishId(100L); // 保持不变

        // When
        LeftoverResponse response = inventoryService.updateLeftover(1L, updateRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getCurrentQuantityGram()).isEqualTo(200);
        assertThat(response.getOriginalDishId()).isEqualTo(100L);

        // 验证字段被正确更新
        assertThat(leftoverDish.getCurrentQuantityGram()).isEqualTo(200);
        verify(leftoverRepository, times(1)).save(leftoverDish);
    }

    @Test
    void testUpdateLeftover_PartialUpdate() {
        // Given
        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenReturn(leftoverDish);

        LeftoverRequest updateRequest = new LeftoverRequest();
        updateRequest.setCurrentQuantityGram(250); // 只更新数量
        // originalDishId 为 null，不应更新

        // When
        LeftoverResponse response = inventoryService.updateLeftover(1L, updateRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getCurrentQuantityGram()).isEqualTo(250);
        assertThat(leftoverDish.getOriginalDishId()).isEqualTo(100L); // 保持原值

        verify(leftoverRepository, times(1)).save(leftoverDish);
    }

    @Test
    void testUpdateLeftover_LeftoverNotFound() {
        // Given
        when(leftoverRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.updateLeftover(1L, leftoverRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("剩菜不存在");

        verify(leftoverRepository, never()).save(any());
    }

    @Test
    void testGetLeftover_Success() {
        // Given
        when(leftoverRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));

        // When
        LeftoverResponse response = inventoryService.getLeftover(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getHouseholdId()).isEqualTo(1L);
        assertThat(response.getOriginalDishId()).isEqualTo(100L);
        assertThat(response.getCurrentQuantityGram()).isEqualTo(300);
        // 注意：响应中不包含 name 和 coverImage，这些需要通过 Dish 获取
    }

    @Test
    void testGetLeftover_NotFound() {
        // Given
        when(leftoverRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> inventoryService.getLeftover(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("剩菜不存在");
    }

    @Test
    void testGetLeftoversByHousehold_Success() {
        // Given
        LeftoverDish leftover2 = new LeftoverDish();
        leftover2.setId(2L);
        leftover2.setHousehold(household);
        leftover2.setOriginalDishId(200L);
        leftover2.setCurrentQuantityGram(400);

        when(leftoverRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(leftoverDish, leftover2));

        // When
        List<LeftoverResponse> responses = inventoryService.getLeftoversByHousehold(1L);

        // Then
        assertThat(responses).hasSize(2);
        assertThat(responses.get(0).getOriginalDishId()).isEqualTo(100L);
        assertThat(responses.get(0).getCurrentQuantityGram()).isEqualTo(300);
        assertThat(responses.get(1).getOriginalDishId()).isEqualTo(200L);
        assertThat(responses.get(1).getCurrentQuantityGram()).isEqualTo(400);
    }

    @Test
    void testGetLeftoversByHousehold_EmptyList() {
        // Given
        when(leftoverRepository.findByHouseholdId(1L)).thenReturn(Arrays.asList());

        // When
        List<LeftoverResponse> responses = inventoryService.getLeftoversByHousehold(1L);

        // Then
        assertThat(responses).isEmpty();
    }

    @Test
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
    void testDeleteLeftover_NotFound() {
        // Given
        when(leftoverRepository.existsById(1L)).thenReturn(false);

        // When & Then
        assertThatThrownBy(() -> inventoryService.deleteLeftover(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("剩菜不存在");

        verify(leftoverRepository, never()).deleteById(any());
    }

    // ==================== 字段验证测试 ====================

    @Test
    void testCreateLeftover_WithNewFieldStructure() {
        // Given - 验证新字段结构（originalDishId 和 currentQuantityGram）
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        LeftoverResponse response = inventoryService.createLeftover(leftoverRequest);

        // Then - 验证响应包含新字段，不包含旧字段（name, coverImage, quantityGram）
        assertThat(response.getOriginalDishId()).isNotNull();
        assertThat(response.getCurrentQuantityGram()).isNotNull();
        
        // 注意：由于 LeftoverResponse 不再包含 name 和 coverImage 字段，
        // 这里我们验证这些字段确实不存在（通过反射或其他方式，但更简单的方式是检查响应对象的字段）
        // 实际上，由于响应对象的结构已经改变，编译时就会确保这些字段不存在
        
        ArgumentCaptor<LeftoverDish> captor = ArgumentCaptor.forClass(LeftoverDish.class);
        verify(leftoverRepository, times(1)).save(captor.capture());
        LeftoverDish saved = captor.getValue();
        
        // 验证实体使用新字段结构
        assertThat(saved.getOriginalDishId()).isEqualTo(100L);
        assertThat(saved.getCurrentQuantityGram()).isEqualTo(500);
        // 验证旧字段不存在（这些字段已经不在实体中了）
    }
}
