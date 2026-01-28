package com.calotter.user.service;

import com.calotter.user.controller.dto.HouseholdRequest;
import com.calotter.user.controller.dto.HouseholdResponse;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * HouseholdService 完整单元测试
 * 覆盖所有功能：创建、更新、查询、删除家庭，以及获取当前活跃家庭
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("家庭服务测试")
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
        owner.setJoinedHouseholds(new java.util.ArrayList<>());

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
    @DisplayName("创建家庭 - 成功")
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
    @DisplayName("创建家庭 - 用户不存在")
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
    @DisplayName("创建家庭 - 邀请码生成")
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

    @Test
    @DisplayName("创建家庭 - 邀请码唯一性")
    void testCreateHousehold_InviteCodeUniqueness() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        // 第一次生成的邀请码已存在，第二次生成新的
        when(householdRepository.findByInviteCode(anyString()))
                .thenReturn(Optional.of(new Household())) // 第一次返回已存在
                .thenReturn(Optional.empty()); // 第二次返回不存在
        when(householdRepository.save(any(Household.class))).thenAnswer(invocation -> {
            Household saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        // When
        HouseholdResponse response = householdService.createHousehold(householdRequest);

        // Then - 应该尝试生成唯一的邀请码
        verify(householdRepository, atLeastOnce()).findByInviteCode(anyString());
    }

    // ==================== 更新家庭测试 ====================

    @Test
    @DisplayName("更新家庭 - 成功")
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
    @DisplayName("更新家庭 - 非所有者")
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
    @DisplayName("更新家庭 - 家庭不存在")
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
    @DisplayName("更新家庭 - 部分更新")
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
        verify(householdRepository, times(1)).save(household);
    }

    // ==================== 查询家庭测试 ====================

    @Test
    @DisplayName("获取家庭详情 - 成功")
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
    @DisplayName("获取家庭详情 - 不存在")
    void testGetHousehold_NotFound() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.getHousehold(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");
    }

    @Test
    @DisplayName("通过邀请码获取家庭 - 成功")
    void testGetHouseholdByInviteCode_Success() {
        // Given
        when(householdRepository.findByInviteCode("ABC123")).thenReturn(Optional.of(household));

        // When
        HouseholdResponse response = householdService.getHouseholdByInviteCode("ABC123");

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getInviteCode()).isEqualTo("ABC123");
        assertThat(response.getId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("通过邀请码获取家庭 - 无效邀请码")
    void testGetHouseholdByInviteCode_InvalidCode() {
        // Given
        when(householdRepository.findByInviteCode("INVALID")).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.getHouseholdByInviteCode("INVALID"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("邀请码无效");
    }

    @Test
    @DisplayName("获取用户的所有家庭 - 成功")
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
    @DisplayName("获取用户的所有家庭 - 空列表")
    void testGetHouseholdsByOwner_Empty() {
        // Given
        when(householdRepository.findAll()).thenReturn(Collections.emptyList());

        // When
        List<HouseholdResponse> responses = householdService.getHouseholdsByOwner(1L);

        // Then
        assertThat(responses).isEmpty();
    }

    @Test
    @DisplayName("获取当前活跃家庭 - 使用currentHouseholdId")
    void testGetCurrentHousehold_WithCurrentHouseholdId() {
        // Given
        owner.setCurrentHouseholdId(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        // When
        HouseholdResponse response = householdService.getCurrentHousehold(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        verify(householdRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("获取当前活跃家庭 - 从拥有的家庭获取")
    void testGetCurrentHousehold_FromOwnedHouseholds() {
        // Given
        owner.setCurrentHouseholdId(null);
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        when(householdRepository.findAll()).thenReturn(Arrays.asList(household));

        // When
        HouseholdResponse response = householdService.getCurrentHousehold(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("获取当前活跃家庭 - 从加入的家庭获取")
    void testGetCurrentHousehold_FromJoinedHouseholds() {
        // Given
        owner.setCurrentHouseholdId(null);
        Household joinedHousehold = new Household();
        joinedHousehold.setId(2L);
        joinedHousehold.setName("加入的家庭");
        joinedHousehold.setOwnerId(2L);
        owner.setJoinedHouseholds(Arrays.asList(joinedHousehold));
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        when(householdRepository.findAll()).thenReturn(Collections.emptyList());

        // When
        HouseholdResponse response = householdService.getCurrentHousehold(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(2L);
    }

    @Test
    @DisplayName("获取当前活跃家庭 - 用户不存在")
    void testGetCurrentHousehold_UserNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.getCurrentHousehold(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
    @DisplayName("获取当前活跃家庭 - 没有关联的家庭")
    void testGetCurrentHousehold_NoHousehold() {
        // Given
        owner.setCurrentHouseholdId(null);
        owner.setJoinedHouseholds(Collections.emptyList());
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        when(householdRepository.findAll()).thenReturn(Collections.emptyList());

        // When & Then
        assertThatThrownBy(() -> householdService.getCurrentHousehold(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户没有关联的家庭");
    }

    @Test
    @DisplayName("获取当前活跃家庭 - currentHouseholdId无效时回退")
    void testGetCurrentHousehold_InvalidCurrentHouseholdId() {
        // Given
        owner.setCurrentHouseholdId(999L); // 不存在的家庭ID
        Household ownedHousehold = new Household();
        ownedHousehold.setId(1L);
        ownedHousehold.setOwnerId(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));
        when(householdRepository.findById(999L)).thenReturn(Optional.empty());
        when(householdRepository.findAll()).thenReturn(Arrays.asList(ownedHousehold));

        // When
        HouseholdResponse response = householdService.getCurrentHousehold(1L);

        // Then - 应该回退到拥有的家庭
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
    }

    // ==================== 删除家庭测试 ====================

    @Test
    @DisplayName("删除家庭 - 成功")
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
    @DisplayName("删除家庭 - 非所有者")
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
    @DisplayName("删除家庭 - 家庭不存在")
    void testDeleteHousehold_NotFound() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.deleteHousehold(1L, 1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("家庭不存在");

        verify(householdRepository, never()).deleteById(any());
    }

    // ==================== 邀请用户测试 ====================

    @Test
    @DisplayName("邀请用户加入厨房 - 成功（owner邀请）")
    void testInviteUserToHousehold_Success_AsOwner() {
        // Given
        User inviter = new User();
        inviter.setId(1L);
        inviter.setJoinedHouseholds(new ArrayList<>());
        
        User invitedUser = new User();
        invitedUser.setId(2L);
        invitedUser.setUsername("inviteduser");
        invitedUser.setJoinedHouseholds(new ArrayList<>());

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findById(1L)).thenReturn(Optional.of(inviter));
        when(userRepository.findByUsername("inviteduser")).thenReturn(Optional.of(invitedUser));
        when(userRepository.findById(2L)).thenReturn(Optional.of(invitedUser));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        householdService.inviteUserToHousehold(1L, "inviteduser", 1L);

        // Then
        verify(userRepository, times(1)).save(any(User.class));
        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(captor.capture());
        assertThat(captor.getValue().getJoinedHouseholds()).contains(household);
    }

    @Test
    @DisplayName("邀请用户加入厨房 - 用户已加入")
    void testInviteUserToHousehold_UserAlreadyJoined() {
        // Given
        User inviter = new User();
        inviter.setId(1L);
        inviter.setJoinedHouseholds(Arrays.asList(household));
        
        User invitedUser = new User();
        invitedUser.setId(2L);
        invitedUser.setUsername("inviteduser");
        invitedUser.setJoinedHouseholds(new ArrayList<>(Arrays.asList(household)));

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findById(1L)).thenReturn(Optional.of(inviter));
        when(userRepository.findByUsername("inviteduser")).thenReturn(Optional.of(invitedUser));
        when(userRepository.findById(2L)).thenReturn(Optional.of(invitedUser));

        // When & Then
        assertThatThrownBy(() -> householdService.inviteUserToHousehold(1L, "inviteduser", 1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户已加入该厨房");
    }

    // ==================== 通过邀请码加入测试 ====================

    @Test
    @DisplayName("通过邀请码加入厨房 - 成功")
    void testJoinHouseholdByInviteCode_Success() {
        // Given
        User user = new User();
        user.setId(2L);
        user.setJoinedHouseholds(new ArrayList<>());
        user.setCurrentHouseholdId(null);

        when(householdRepository.findByInviteCode("ABC123")).thenReturn(Optional.of(household));
        when(userRepository.findById(2L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        HouseholdResponse response = householdService.joinHouseholdByInviteCode("ABC123", 2L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("通过邀请码加入厨房 - 无效邀请码")
    void testJoinHouseholdByInviteCode_InvalidCode() {
        // Given
        when(householdRepository.findByInviteCode("INVALID")).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> householdService.joinHouseholdByInviteCode("INVALID", 2L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("邀请码无效");
    }

    // ==================== 退出厨房测试 ====================

    @Test
    @DisplayName("退出厨房 - 成功")
    void testLeaveHousehold_Success() {
        // Given
        User user = new User();
        user.setId(2L);
        user.setJoinedHouseholds(new ArrayList<>(Arrays.asList(household)));
        user.setCurrentHouseholdId(1L);

        Household otherHousehold = new Household();
        otherHousehold.setId(3L);
        user.getJoinedHouseholds().add(otherHousehold);

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findById(2L)).thenReturn(Optional.of(user));
        when(householdRepository.findAll()).thenReturn(Collections.emptyList());
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        householdService.leaveHousehold(1L, 2L);

        // Then
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("退出厨房 - owner不能退出")
    void testLeaveHousehold_OwnerCannotLeave() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));

        // When & Then
        assertThatThrownBy(() -> householdService.leaveHousehold(1L, 1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("厨房所有者不能退出");
    }

    // ==================== 切换当前厨房测试 ====================

    @Test
    @DisplayName("切换当前厨房 - 成功")
    void testSwitchCurrentHousehold_Success() {
        // Given
        User user = new User();
        user.setId(2L);
        user.setJoinedHouseholds(new ArrayList<>(Arrays.asList(household)));

        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findById(2L)).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        HouseholdResponse response = householdService.switchCurrentHousehold(1L, 2L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(1L);
        verify(userRepository, times(1)).save(any(User.class));
    }

    // ==================== 重新生成邀请码测试 ====================

    @Test
    @DisplayName("重新生成邀请码 - 成功")
    void testRegenerateInviteCode_Success() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(householdRepository.findByInviteCode(anyString())).thenReturn(Optional.empty());
        when(householdRepository.save(any(Household.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // When
        HouseholdResponse response = householdService.regenerateInviteCode(1L, 1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getInviteCode()).isNotNull();
        assertThat(response.getInviteCode()).isNotEqualTo("ABC123"); // 应该是新的邀请码
        verify(householdRepository, times(1)).save(any(Household.class));
    }

    @Test
    @DisplayName("重新生成邀请码 - 非owner")
    void testRegenerateInviteCode_NotOwner() {
        // Given
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        // When & Then
        assertThatThrownBy(() -> householdService.regenerateInviteCode(1L, 2L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("只有厨房所有者可以重新生成邀请码");
    }
}
