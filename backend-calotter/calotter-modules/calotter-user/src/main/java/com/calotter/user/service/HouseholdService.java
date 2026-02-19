package com.calotter.user.service;

import com.calotter.user.controller.dto.HouseholdRequest;
import com.calotter.user.controller.dto.HouseholdResponse;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 家庭服务
 */
@Service
@RequiredArgsConstructor
public class HouseholdService {

    private final HouseholdRepository householdRepository;
    private final UserRepository userRepository;

    /**
     * 创建家庭
     */
    @Transactional
    public HouseholdResponse createHousehold(HouseholdRequest request) {
        // 验证用户是否存在
        userRepository.findById(request.getOwnerId())
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        // 生成唯一的邀请码
        String inviteCode = generateInviteCode();

        // 创建家庭
        Household household = new Household();
        household.setName(request.getName());
        household.setOwnerId(request.getOwnerId());
        household.setInviteCode(inviteCode);

        household = householdRepository.save(household);
        return toHouseholdResponse(household);
    }

    /**
     * 更新家庭信息
     */
    @Transactional
    public HouseholdResponse updateHousehold(Long id, HouseholdRequest request) {
        Household household = householdRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        // 验证是否为所有者
        if (!household.getOwnerId().equals(request.getOwnerId())) {
            throw new IllegalArgumentException("只有所有者可以修改家庭信息");
        }

        if (request.getName() != null) {
            household.setName(request.getName());
        }

        household = householdRepository.save(household);
        return toHouseholdResponse(household);
    }

    /**
     * 获取家庭详情
     */
    public HouseholdResponse getHousehold(Long id) {
        Household household = householdRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        return toHouseholdResponse(household);
    }

    /**
     * 通过邀请码获取家庭
     */
    public HouseholdResponse getHouseholdByInviteCode(String inviteCode) {
        Household household = householdRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new IllegalArgumentException("邀请码无效"));
        return toHouseholdResponse(household);
    }

    /**
     * 获取用户的所有家庭
     */
    public List<HouseholdResponse> getHouseholdsByOwner(Long ownerId) {
        List<Household> households = householdRepository.findAll().stream()
                .filter(h -> h.getOwnerId().equals(ownerId))
                .collect(Collectors.toList());
        return households.stream()
                .map(this::toHouseholdResponse)
                .collect(Collectors.toList());
    }

    /**
     * 获取用户的当前活跃家庭
     * 优先使用 currentHouseholdId，如果没有则返回第一个拥有的家庭，再没有则返回第一个加入的家庭
     */
    @Transactional(readOnly = true)
    public HouseholdResponse getCurrentHousehold(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        
        // 1. 优先使用 currentHouseholdId
        if (user.getCurrentHouseholdId() != null) {
            Household household = householdRepository.findById(user.getCurrentHouseholdId())
                    .orElse(null);
            if (household != null) {
                // 验证用户是否真的加入了这个家庭（owner 或 member）
                if (household.getOwnerId().equals(userId) || 
                    (user.getJoinedHouseholds() != null && 
                     user.getJoinedHouseholds().stream()
                         .anyMatch(h -> h.getId().equals(household.getId())))) {
                    return toHouseholdResponse(household);
                }
            }
        }
        
        // 2. 如果没有 currentHouseholdId 或无效，返回第一个拥有的家庭
        List<HouseholdResponse> ownedHouseholds = getHouseholdsByOwner(userId);
        if (!ownedHouseholds.isEmpty()) {
            return ownedHouseholds.get(0);
        }
        
        // 3. 如果没有拥有的家庭，返回第一个加入的家庭
        if (user.getJoinedHouseholds() != null && !user.getJoinedHouseholds().isEmpty()) {
            return toHouseholdResponse(user.getJoinedHouseholds().get(0));
        }
        
        throw new IllegalArgumentException("用户没有关联的家庭");
    }

    /**
     * 删除家庭
     */
    @Transactional
    public void deleteHousehold(Long id, Long ownerId) {
        Household household = householdRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        // 验证是否为所有者
        if (!household.getOwnerId().equals(ownerId)) {
            throw new IllegalArgumentException("只有所有者可以删除家庭");
        }

        householdRepository.deleteById(id);
    }

    /**
     * 通过用户名或邮箱邀请用户加入厨房
     */
    @Transactional
    public void inviteUserToHousehold(Long householdId, String usernameOrEmail, Long inviterId) {
        // 1. 验证厨房存在
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("厨房不存在"));

        // 2. 验证邀请人权限（owner 或已加入的 member）
        User inviter = userRepository.findById(inviterId)
                .orElseThrow(() -> new IllegalArgumentException("邀请人不存在"));

        // 重新加载用户以获取 joinedHouseholds
        inviter = userRepository.findById(inviterId).orElse(inviter);
        boolean isOwner = household.getOwnerId().equals(inviterId);
        boolean isMember = inviter.getJoinedHouseholds() != null &&
                inviter.getJoinedHouseholds().stream()
                        .anyMatch(h -> h.getId().equals(householdId));

        if (!isOwner && !isMember) {
            throw new IllegalArgumentException("无权限邀请用户，只有厨房成员可以邀请");
        }

        // 3. 通过用户名或邮箱查找被邀请用户
        User invitedUser = userRepository.findByUsername(usernameOrEmail)
                .orElseGet(() -> userRepository.findByEmail(usernameOrEmail)
                        .orElseThrow(() -> new IllegalArgumentException("用户不存在")));

        // 4. 检查是否已加入
        invitedUser = userRepository.findById(invitedUser.getId()).orElse(invitedUser);
        if (invitedUser.getJoinedHouseholds() != null &&
                invitedUser.getJoinedHouseholds().stream()
                        .anyMatch(h -> h.getId().equals(householdId))) {
            throw new IllegalArgumentException("用户已加入该厨房");
        }

        // 5. 添加关系
        if (invitedUser.getJoinedHouseholds() == null) {
            invitedUser.setJoinedHouseholds(new java.util.ArrayList<>());
        }
        invitedUser.getJoinedHouseholds().add(household);
        userRepository.save(invitedUser);
    }

    /**
     * 通过邀请码加入厨房（自动切换到新厨房）
     */
    @Transactional
    public HouseholdResponse joinHouseholdByInviteCode(String inviteCode, Long userId) {
        // 1. 通过邀请码查找厨房
        Household household = householdRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new IllegalArgumentException("邀请码无效"));

        // 2. 查找用户
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        // 3. 检查是否已加入
        if (user.getJoinedHouseholds() != null &&
                user.getJoinedHouseholds().stream()
                        .anyMatch(h -> h.getId().equals(household.getId()))) {
            throw new IllegalArgumentException("用户已加入该厨房");
        }

        // 4. 添加关系
        if (user.getJoinedHouseholds() == null) {
            user.setJoinedHouseholds(new java.util.ArrayList<>());
        }
        user.getJoinedHouseholds().add(household);

        // 5. 自动切换到新厨房（如果当前没有厨房或当前厨房无效）
        if (user.getCurrentHouseholdId() == null) {
            user.setCurrentHouseholdId(household.getId());
        } else {
            // 检查当前厨房是否有效
            Household currentHousehold = householdRepository.findById(user.getCurrentHouseholdId()).orElse(null);
            if (currentHousehold == null ||
                    (!currentHousehold.getOwnerId().equals(userId) &&
                     (user.getJoinedHouseholds() == null ||
                      user.getJoinedHouseholds().stream()
                              .noneMatch(h -> h.getId().equals(user.getCurrentHouseholdId()))))) {
                // 当前厨房无效，切换到新厨房
                user.setCurrentHouseholdId(household.getId());
            } else {
                // 当前厨房有效，自动切换到新加入的厨房
                user.setCurrentHouseholdId(household.getId());
            }
        }

        userRepository.save(user);
        return toHouseholdResponse(household);
    }

    /**
     * 用户主动退出厨房
     */
    @Transactional
    public void leaveHousehold(Long householdId, Long userId) {
        // 1. 验证厨房存在
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("厨房不存在"));

        // 2. 验证用户存在
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        // 3. 检查是否为owner（owner不能退出，只能删除厨房）
        if (household.getOwnerId().equals(userId)) {
            throw new IllegalArgumentException("厨房所有者不能退出，只能删除厨房");
        }

        // 4. 检查是否已加入
        user = userRepository.findById(userId).orElse(user);
        if (user.getJoinedHouseholds() == null ||
                user.getJoinedHouseholds().stream()
                        .noneMatch(h -> h.getId().equals(householdId))) {
            throw new IllegalArgumentException("用户未加入该厨房");
        }

        // 5. 移除关系
        user.getJoinedHouseholds().removeIf(h -> h.getId().equals(householdId));

        // 6. 如果退出的是当前厨房，清空或切换到其他厨房
        if (user.getCurrentHouseholdId() != null && user.getCurrentHouseholdId().equals(householdId)) {
            // 尝试切换到其他厨房
            if (user.getJoinedHouseholds() != null && !user.getJoinedHouseholds().isEmpty()) {
                user.setCurrentHouseholdId(user.getJoinedHouseholds().get(0).getId());
            } else {
                // 检查是否有拥有的厨房
                List<HouseholdResponse> ownedHouseholds = getHouseholdsByOwner(userId);
                if (!ownedHouseholds.isEmpty()) {
                    user.setCurrentHouseholdId(ownedHouseholds.get(0).getId());
                } else {
                    user.setCurrentHouseholdId(null);
                }
            }
        }

        userRepository.save(user);
    }

    /**
     * 厨房owner踢出成员
     */
    @Transactional
    public void removeMemberFromHousehold(Long householdId, Long memberId, Long ownerId) {
        // 1. 验证厨房存在
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("厨房不存在"));

        // 2. 验证是否为owner
        if (!household.getOwnerId().equals(ownerId)) {
            throw new IllegalArgumentException("只有厨房所有者可以移除成员");
        }

        // 3. 验证不能移除自己
        if (memberId.equals(ownerId)) {
            throw new IllegalArgumentException("不能移除自己，请使用删除厨房功能");
        }

        // 4. 验证成员存在
        User member = userRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("成员不存在"));

        // 5. 检查是否已加入
        member = userRepository.findById(memberId).orElse(member);
        if (member.getJoinedHouseholds() == null ||
                member.getJoinedHouseholds().stream()
                        .noneMatch(h -> h.getId().equals(householdId))) {
            throw new IllegalArgumentException("用户未加入该厨房");
        }

        // 6. 移除关系
        member.getJoinedHouseholds().removeIf(h -> h.getId().equals(householdId));

        // 7. 如果被踢出的是当前厨房，清空或切换到其他厨房
        if (member.getCurrentHouseholdId() != null && member.getCurrentHouseholdId().equals(householdId)) {
            // 尝试切换到其他厨房
            if (member.getJoinedHouseholds() != null && !member.getJoinedHouseholds().isEmpty()) {
                member.setCurrentHouseholdId(member.getJoinedHouseholds().get(0).getId());
            } else {
                // 检查是否有拥有的厨房
                List<HouseholdResponse> ownedHouseholds = getHouseholdsByOwner(memberId);
                if (!ownedHouseholds.isEmpty()) {
                    member.setCurrentHouseholdId(ownedHouseholds.get(0).getId());
                } else {
                    member.setCurrentHouseholdId(null);
                }
            }
        }

        userRepository.save(member);
    }

    /**
     * 切换当前使用的厨房
     */
    @Transactional
    public HouseholdResponse switchCurrentHousehold(Long householdId, Long userId) {
        // 1. 验证厨房存在
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("厨房不存在"));

        // 2. 验证用户存在
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        // 3. 验证用户是否属于该厨房（owner 或 member）
        user = userRepository.findById(userId).orElse(user);
        boolean isOwner = household.getOwnerId().equals(userId);
        boolean isMember = user.getJoinedHouseholds() != null &&
                user.getJoinedHouseholds().stream()
                        .anyMatch(h -> h.getId().equals(householdId));

        if (!isOwner && !isMember) {
            throw new IllegalArgumentException("用户不属于该厨房，无法切换");
        }

        // 4. 切换当前厨房
        user.setCurrentHouseholdId(householdId);
        userRepository.save(user);

        return toHouseholdResponse(household);
    }

    /**
     * 获取用户加入的所有厨房列表
     */
    @Transactional(readOnly = true)
    public List<HouseholdResponse> getJoinedHouseholds(Long userId) {
        // 1. 验证用户存在
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));

        // 2. 获取用户加入的所有厨房（包括拥有的和加入的）
        List<HouseholdResponse> result = new java.util.ArrayList<>();

        // 2.1 添加拥有的厨房
        List<HouseholdResponse> ownedHouseholds = getHouseholdsByOwner(userId);
        result.addAll(ownedHouseholds);

        // 2.2 添加加入的厨房（排除已拥有的，避免重复）
        if (user.getJoinedHouseholds() != null) {
            for (Household household : user.getJoinedHouseholds()) {
                // 只添加不是owner的厨房（owner的已经在上面添加了）
                if (!household.getOwnerId().equals(userId)) {
                    result.add(toHouseholdResponse(household));
                }
            }
        }

        return result;
    }

    /**
     * 重新生成邀请码（只有owner可以操作）
     */
    @Transactional
    public HouseholdResponse regenerateInviteCode(Long householdId, Long ownerId) {
        // 1. 验证厨房存在
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("厨房不存在"));

        // 2. 验证是否为owner
        if (!household.getOwnerId().equals(ownerId)) {
            throw new IllegalArgumentException("只有厨房所有者可以重新生成邀请码");
        }

        // 3. 生成新的邀请码
        String newInviteCode = generateInviteCode();
        household.setInviteCode(newInviteCode);
        household = householdRepository.save(household);

        return toHouseholdResponse(household);
    }

    /**
     * 生成唯一的邀请码
     */
    private String generateInviteCode() {
        String code;
        do {
            // 生成6位大写字母数字组合
            code = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        } while (householdRepository.findByInviteCode(code).isPresent());
        return code;
    }

    /**
     * 转换为响应DTO
     */
    private HouseholdResponse toHouseholdResponse(Household household) {
        return HouseholdResponse.builder()
                .id(household.getId())
                .name(household.getName())
                .inviteCode(household.getInviteCode())
                .ownerId(household.getOwnerId())
                .build();
    }
}
