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
}
