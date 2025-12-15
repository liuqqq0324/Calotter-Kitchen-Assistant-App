package com.calotter.user.service;

import com.calotter.user.controller.dto.HouseholdRequest;
import com.calotter.user.controller.dto.HouseholdResponse;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * HouseholdService 单元测试
 */
@ExtendWith(MockitoExtension.class)
class HouseholdServiceTest {

    @Mock
    private HouseholdRepository householdRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private HouseholdService householdService;

    private HouseholdRequest householdRequest;
    private User owner;
    private Household household;

    @BeforeEach
    void setUp() {
        owner = new User();
        owner.setId(1L);
        owner.setUsername("owner");

        householdRequest = new HouseholdRequest();
        householdRequest.setName("测试家庭");
        householdRequest.setOwnerId(1L);

        household = new Household();
        household.setId(1L);
        household.setName("测试家庭");
        household.setOwnerId(1L);
        household.setInviteCode("ABC123");
    }

    // ==================== 创建家庭测试 ====================

    @Test
    void testCreateHousehold_Success() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        when(householdRepository.findByInviteCode(anyString())).thenReturn(Optional.empty());
        when(householdRepository.save(any(Household.class))).thenAnswer(invocation -> {
            Household saved = invocation.getArgument(0);
            saved.setId(1L);
            saved.setInviteCode("ABC123");
            return saved;
        });

        // When
        HouseholdResponse response = householdService.createHousehold(householdRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getName()).isEqualTo("测试家庭");
        assertThat(response.getOwnerId()).isEqualTo(1L);
        assertThat(response.getInviteCode()).isNotNull();
        assertThat(response.getInviteCode()).hasSize(6);

        verify(userRepository, times(1)).findById(1L);
        verify(householdRepository, times(1)).save(any(Household.class));
    }

    @Test
    void testCreateHousehold_UserNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.createHousehold(householdRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");

        verify(householdRepository, never()).save(any());
    }

    @Test
    void testCreateHousehold_InviteCodeGenerated() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        when(householdRepository.findByInviteCode(anyString())).thenReturn(Optional.empty());
        when(householdRepository.save(any(Household.class))).thenAnswer(invocation -> {
            Household saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        HouseholdResponse response = householdService.createHousehold(householdRequest);

        // Then - 验证邀请码被生成
        ArgumentCaptor<Household> captor = ArgumentCaptor.forClass(Household.class);
        verify(householdRepository, times(1)).save(captor.capture());
        Household saved = captor.getValue();
        assertThat(saved.getInviteCode()).isNotNull();
        assertThat(saved.getInviteCode().length()).isGreaterThanOrEqualTo(6);
    }

    // ==================== 更新家庭测试 ====================

    @Test
    void testUpdateHousehold_Success() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(householdRepository.save(any(Household.class))).thenReturn(household);

        HouseholdRequest updateRequest = new HouseholdRequest();
        updateRequest.setName("更新后的家庭名称");
        updateRequest.setOwnerId(1L);

        // When
        HouseholdResponse response = householdService.updateHousehold(1L, updateRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getName()).isEqualTo("更新后的家庭名称");
        assertThat(household.getName()).isEqualTo("更新后的家庭名称");

        verify(householdRepository, times(1)).save(household);
    }

    @Test
    void testUpdateHousehold_NotOwner() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        HouseholdRequest updateRequest = new HouseholdRequest();
        updateRequest.setName("更新后的家庭名称");
        updateRequest.setOwnerId(2L); // 不同的所有者ID

        // When & Then
        assertThatThrownBy(() -> householdService.updateHousehold(1L, updateRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("只有所有者可以修改家庭信息");

        verify(householdRepository, never()).save(any());
    }

    @Test
    void testUpdateHousehold_HouseholdNotFound() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.updateHousehold(1L, householdRequest))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(householdRepository, never()).save(any());
    }

    @Test
    void testUpdateHousehold_PartialUpdate() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(householdRepository.save(any(Household.class))).thenReturn(household);

        HouseholdRequest updateRequest = new HouseholdRequest();
        updateRequest.setName(null); // name 为 null，不应更新
        updateRequest.setOwnerId(1L);

        // When
        HouseholdResponse response = householdService.updateHousehold(1L, updateRequest);

        // Then - name 应该保持原值
        assertThat(household.getName()).isEqualTo("测试家庭");
    }

    // ==================== 查询家庭测试 ====================

    @Test
    void testGetHousehold_Success() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        // When
        HouseholdResponse response = householdService.getHousehold(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getName()).isEqualTo("测试家庭");
        assertThat(response.getOwnerId()).isEqualTo(1L);
        assertThat(response.getInviteCode()).isEqualTo("ABC123");
    }

    @Test
    void testGetHousehold_NotFound() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.getHousehold(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");
    }

    @Test
    void testGetHouseholdByInviteCode_Success() {
        // Given
        when(householdRepository.findByInviteCode("ABC123")).thenReturn(Optional.of(household));

        // When
        HouseholdResponse response = householdService.getHouseholdByInviteCode("ABC123");

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getInviteCode()).isEqualTo("ABC123");
    }

    @Test
    void testGetHouseholdByInviteCode_InvalidCode() {
        // Given
        when(householdRepository.findByInviteCode("INVALID")).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.getHouseholdByInviteCode("INVALID"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("邀请码无效");
    }

    @Test
    void testGetHouseholdsByOwner_Success() {
        // Given
        Household household2 = new Household();
        household2.setId(2L);
        household2.setName("另一个家庭");
        household2.setOwnerId(1L);
        household2.setInviteCode("XYZ789");

        Household otherHousehold = new Household();
        otherHousehold.setId(3L);
        otherHousehold.setOwnerId(2L); // 不同的所有者

        when(householdRepository.findAll()).thenReturn(Arrays.asList(household, household2, otherHousehold));

        // When
        List<HouseholdResponse> responses = householdService.getHouseholdsByOwner(1L);

        // Then
        assertThat(responses).hasSize(2);
        assertThat(responses).extracting("id").containsExactly(1L, 2L);
        assertThat(responses).extracting("ownerId").containsOnly(1L);
    }

    @Test
    void testGetHouseholdsByOwner_Empty() {
        // Given
        when(householdRepository.findAll()).thenReturn(Arrays.asList());

        // When
        List<HouseholdResponse> responses = householdService.getHouseholdsByOwner(1L);

        // Then
        assertThat(responses).isEmpty();
    }

    // ==================== 删除家庭测试 ====================

    @Test
    void testDeleteHousehold_Success() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        doNothing().when(householdRepository).deleteById(1L);

        // When
        householdService.deleteHousehold(1L, 1L);

        // Then
        verify(householdRepository, times(1)).deleteById(1L);
    }

    @Test
    void testDeleteHousehold_NotOwner() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        // When & Then
        assertThatThrownBy(() -> householdService.deleteHousehold(1L, 2L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("只有所有者可以删除家庭");

        verify(householdRepository, never()).deleteById(any());
    }

    @Test
    void testDeleteHousehold_NotFound() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.deleteHousehold(1L, 1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(householdRepository, never()).deleteById(any());
    }
}
