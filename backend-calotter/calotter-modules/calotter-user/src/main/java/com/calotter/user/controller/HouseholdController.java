package com.calotter.user.controller;

import com.calotter.common.core.Result;
import com.calotter.user.controller.dto.HouseholdRequest;
import com.calotter.user.controller.dto.HouseholdResponse;
import com.calotter.user.service.HouseholdService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 家庭控制器
 */
@RestController
@RequestMapping("/api/household")
@RequiredArgsConstructor
public class HouseholdController {

    private final HouseholdService householdService;

    /**
     * 创建家庭
     * POST /api/household
     */
    @PostMapping
    public Result<HouseholdResponse> createHousehold(@Valid @RequestBody HouseholdRequest request) {
        try {
            HouseholdResponse response = householdService.createHousehold(request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新家庭信息
     * PUT /api/household/{id}
     */
    @PutMapping("/{id}")
    public Result<HouseholdResponse> updateHousehold(
            @PathVariable Long id,
            @Valid @RequestBody HouseholdRequest request) {
        try {
            HouseholdResponse response = householdService.updateHousehold(id, request);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取家庭详情
     * GET /api/household/{id}
     */
    @GetMapping("/{id}")
    public Result<HouseholdResponse> getHousehold(@PathVariable Long id) {
        try {
            HouseholdResponse response = householdService.getHousehold(id);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 通过邀请码获取家庭
     * GET /api/household/invite/{inviteCode}
     */
    @GetMapping("/invite/{inviteCode}")
    public Result<HouseholdResponse> getHouseholdByInviteCode(@PathVariable String inviteCode) {
        try {
            HouseholdResponse response = householdService.getHouseholdByInviteCode(inviteCode);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取用户的所有家庭
     * GET /api/household/owner/{ownerId}
     */
    @GetMapping("/owner/{ownerId}")
    public Result<List<HouseholdResponse>> getHouseholdsByOwner(@PathVariable Long ownerId) {
        try {
            List<HouseholdResponse> responses = householdService.getHouseholdsByOwner(ownerId);
            return Result.success(responses);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取用户的当前活跃家庭
     * GET /api/household/current?userId={userId}
     */
    @GetMapping("/current")
    public Result<HouseholdResponse> getCurrentHousehold(@RequestParam Long userId) {
        try {
            HouseholdResponse response = householdService.getCurrentHousehold(userId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除家庭
     * DELETE /api/household/{id}?ownerId={ownerId}
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteHousehold(
            @PathVariable Long id,
            @RequestParam("ownerId") Long ownerId) {
        try {
            householdService.deleteHousehold(id, ownerId);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 邀请用户加入厨房
     * POST /api/household/{householdId}/invite?usernameOrEmail={usernameOrEmail}&inviterId={inviterId}
     */
    @PostMapping("/{householdId}/invite")
    public Result<Void> inviteUser(
            @PathVariable Long householdId,
            @RequestParam String usernameOrEmail,
            @RequestParam Long inviterId) {
        try {
            householdService.inviteUserToHousehold(householdId, usernameOrEmail, inviterId);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 通过邀请码加入厨房
     * POST /api/household/join?inviteCode={inviteCode}&userId={userId}
     */
    @PostMapping("/join")
    public Result<HouseholdResponse> joinHousehold(
            @RequestParam String inviteCode,
            @RequestParam Long userId) {
        try {
            HouseholdResponse response = householdService.joinHouseholdByInviteCode(inviteCode, userId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户退出厨房
     * DELETE /api/household/{householdId}/leave?userId={userId}
     */
    @DeleteMapping("/{householdId}/leave")
    public Result<Void> leaveHousehold(
            @PathVariable Long householdId,
            @RequestParam Long userId) {
        try {
            householdService.leaveHousehold(householdId, userId);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * owner踢出成员
     * DELETE /api/household/{householdId}/members/{memberId}?ownerId={ownerId}
     */
    @DeleteMapping("/{householdId}/members/{memberId}")
    public Result<Void> removeMember(
            @PathVariable Long householdId,
            @PathVariable Long memberId,
            @RequestParam Long ownerId) {
        try {
            householdService.removeMemberFromHousehold(householdId, memberId, ownerId);
            return Result.success(null);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 切换当前使用的厨房
     * PUT /api/household/{householdId}/switch?userId={userId}
     */
    @PutMapping("/{householdId}/switch")
    public Result<HouseholdResponse> switchCurrentHousehold(
            @PathVariable Long householdId,
            @RequestParam Long userId) {
        try {
            HouseholdResponse response = householdService.switchCurrentHousehold(householdId, userId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取用户加入的所有厨房列表
     * GET /api/household/user/{userId}/joined
     */
    @GetMapping("/user/{userId}/joined")
    public Result<List<HouseholdResponse>> getJoinedHouseholds(@PathVariable Long userId) {
        try {
            List<HouseholdResponse> responses = householdService.getJoinedHouseholds(userId);
            return Result.success(responses);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 重新生成邀请码
     * PUT /api/household/{householdId}/regenerate-invite-code?ownerId={ownerId}
     */
    @PutMapping("/{householdId}/regenerate-invite-code")
    public Result<HouseholdResponse> regenerateInviteCode(
            @PathVariable Long householdId,
            @RequestParam Long ownerId) {
        try {
            HouseholdResponse response = householdService.regenerateInviteCode(householdId, ownerId);
            return Result.success(response);
        } catch (IllegalArgumentException e) {
            return Result.error(e.getMessage());
        }
    }
}
