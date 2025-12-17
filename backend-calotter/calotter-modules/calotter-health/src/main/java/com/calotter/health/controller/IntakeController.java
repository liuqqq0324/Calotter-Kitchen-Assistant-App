package com.calotter.health.controller;

import com.calotter.common.core.Result;
import com.calotter.health.service.IIntakeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Intake Controller
 * 摄入记录相关API控制器（从旧版 homepage 迁移并适配当前 Result 结构）
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/api/intake")
public class IntakeController {

    private final IIntakeService intakeService;

    /**
     * Get Today Intakes
     * GET /api/intake/today?source=recipe|manual&userId={userId}
     */
    @GetMapping("/today")
    public Result<IIntakeService.TodayIntakesResponse> getTodayIntakes(
            @RequestParam(required = false, defaultValue = "all") String source,
            @RequestParam("userId") Long userId) {
        try {
            if (!"all".equals(source) && !"recipe".equals(source) && !"manual".equals(source)) {
                return Result.error("Invalid source parameter. Must be 'recipe', 'manual', or 'all'");
            }

            IIntakeService.TodayIntakesResponse response = intakeService.getTodayIntakes(userId, source);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error("Failed to get today intakes: " + e.getMessage());
        }
    }

    /**
     * Update Intake Percentage
     * PATCH /api/intake/{intake_id}?userId={userId}
     */
    @PatchMapping("/{intake_id}")
    public Result<IIntakeService.UpdateIntakeResponse> updateIntakePercentage(
            @PathVariable("intake_id") Long intakeId,
            @RequestParam("userId") Long userId,
            @RequestBody UpdateIntakeRequest request) {
        try {
            if (request.consumedPercentage == null) {
                return Result.error("consumed_percentage is required");
            }

            if (request.consumedPercentage.compareTo(BigDecimal.ZERO) < 0 ||
                    request.consumedPercentage.compareTo(BigDecimal.valueOf(100)) > 0) {
                return Result.error("consumed_percentage must be between 0 and 100");
            }

            IIntakeService.UpdateIntakeResponse response = intakeService.updateIntakePercentage(
                    userId, intakeId, request.consumedPercentage);
            return Result.success(response);
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("not found")) {
                return Result.error(404, e.getMessage());
            } else if (e.getMessage() != null && e.getMessage().contains("Unauthorized")) {
                return Result.error(403, e.getMessage());
            }
            return Result.error("Failed to update intake: " + e.getMessage());
        } catch (Exception e) {
            return Result.error("Failed to update intake: " + e.getMessage());
        }
    }

    /**
     * Add Manual Intake
     * POST /api/intake/manual?userId={userId}
     */
    @PostMapping("/manual")
    public Result<IIntakeService.AddManualIntakeResponse> addManualIntake(
            @RequestParam("userId") Long userId,
            @RequestBody AddManualIntakeRequest request) {
        try {
            if (request.foodName == null || request.foodName.trim().isEmpty()) {
                return Result.error("food_name is required");
            }

            IIntakeService.AddManualIntakeResponse response = intakeService.addManualIntake(
                    userId, request.date, request.foodName, request.portionDescription);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error("Failed to add manual intake: " + e.getMessage());
        }
    }

    /**
     * Delete Intake Record
     * DELETE /api/intake/{intake_id}?userId={userId}
     */
    @DeleteMapping("/{intake_id}")
    public Result<IIntakeService.DeleteIntakeResponse> deleteIntake(
            @PathVariable("intake_id") Long intakeId,
            @RequestParam("userId") Long userId) {
        try {
            IIntakeService.DeleteIntakeResponse response = intakeService.deleteIntake(userId, intakeId);
            return Result.success(response);
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("not found")) {
                return Result.error(404, e.getMessage());
            } else if (e.getMessage() != null && e.getMessage().contains("Unauthorized")) {
                return Result.error(403, e.getMessage());
            }
            return Result.error("Failed to delete intake: " + e.getMessage());
        } catch (Exception e) {
            return Result.error("Failed to delete intake: " + e.getMessage());
        }
    }

    /**
     * Update Intake Request
     */
    public static class UpdateIntakeRequest {
        public BigDecimal consumedPercentage;
    }

    /**
     * Add Manual Intake Request
     */
    public static class AddManualIntakeRequest {
        public LocalDate date;
        public String foodName;
        public String portionDescription;
    }
}

