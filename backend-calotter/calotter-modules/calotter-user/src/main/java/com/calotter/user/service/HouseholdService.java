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
        User owner = userRepository.findById(request.getOwnerId())
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
