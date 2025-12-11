package com.calotter.homepage.controller;

import com.calotter.common.core.domain.R;
import com.calotter.common.web.core.BaseController;
import com.calotter.homepage.service.IIntakeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Intake Controller
 * 摄入记录相关API控制器
 *
 * @author Auto Generated
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/api/intake")
public class IntakeController extends BaseController {

    private final IIntakeService intakeService;

    /**
     * Get Today Intakes
     * GET /api/intake/today?source=recipe|manual&userId={userId}
     */
    @GetMapping("/today")
    public R<IIntakeService.TodayIntakesResponse> getTodayIntakes(
            @RequestParam(required = false, defaultValue = "all") String source,
            @RequestParam("userId") Long userId) {
        try {
            if (!"all".equals(source) && !"recipe".equals(source) && !"manual".equals(source)) {
                return R.fail("Invalid source parameter. Must be 'recipe', 'manual', or 'all'");
            }

            IIntakeService.TodayIntakesResponse response = intakeService.getTodayIntakes(userId, source);
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Failed to get today intakes: " + e.getMessage());
        }
    }

    /**
     * Update Intake Percentage
     * PATCH /api/intake/{intake_id}?userId={userId}
     */
    @PatchMapping("/{intake_id}")
    public R<IIntakeService.UpdateIntakeResponse> updateIntakePercentage(
            @PathVariable("intake_id") Long intakeId,
            @RequestParam("userId") Long userId,
            @RequestBody UpdateIntakeRequest request) {
        try {
            if (request.consumedPercentage == null) {
                return R.fail("consumed_percentage is required");
            }

            if (request.consumedPercentage.compareTo(BigDecimal.ZERO) < 0 ||
                request.consumedPercentage.compareTo(BigDecimal.valueOf(100)) > 0) {
                return R.fail("consumed_percentage must be between 0 and 100");
            }

            IIntakeService.UpdateIntakeResponse response = intakeService.updateIntakePercentage(
                    userId, intakeId, request.consumedPercentage);
            return R.ok(response);
        } catch (RuntimeException e) {
            if (e.getMessage().contains("not found")) {
                return R.fail(404, e.getMessage());
            } else if (e.getMessage().contains("Unauthorized")) {
                return R.fail(403, e.getMessage());
            }
            return R.fail("Failed to update intake: " + e.getMessage());
        } catch (Exception e) {
            return R.fail("Failed to update intake: " + e.getMessage());
        }
    }

    /**
     * Add Manual Intake
     * POST /api/intake/manual?userId={userId}
     */
    @PostMapping("/manual")
    public R<IIntakeService.AddManualIntakeResponse> addManualIntake(
            @RequestParam("userId") Long userId,
            @RequestBody AddManualIntakeRequest request) {
        try {
            if (request.foodName == null || request.foodName.trim().isEmpty()) {
                return R.fail("food_name is required");
            }

            IIntakeService.AddManualIntakeResponse response = intakeService.addManualIntake(
                    userId, request.date, request.foodName, request.portionDescription);
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Failed to add manual intake: " + e.getMessage());
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
