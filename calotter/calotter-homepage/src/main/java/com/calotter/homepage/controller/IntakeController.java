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
     * GET /api/intake/today?source=recipe|manual
     */
    @GetMapping("/today")
    public R<IIntakeService.TodayIntakesResponse> getTodayIntakes(
            @RequestParam(required = false, defaultValue = "all") String source,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            Long userId = extractUserIdFromToken(authHeader);
            if (userId == null) {
                return R.fail("Unauthorized: Invalid or missing token");
            }

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
     * PATCH /api/intake/{intake_id}
     */
    @PatchMapping("/{intake_id}")
    public R<IIntakeService.UpdateIntakeResponse> updateIntakePercentage(
            @PathVariable("intake_id") Long intakeId,
            @RequestBody UpdateIntakeRequest request,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            Long userId = extractUserIdFromToken(authHeader);
            if (userId == null) {
                return R.fail("Unauthorized: Invalid or missing token");
            }

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
     * POST /api/intake/manual
     */
    @PostMapping("/manual")
    public R<IIntakeService.AddManualIntakeResponse> addManualIntake(
            @RequestBody AddManualIntakeRequest request,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        try {
            Long userId = extractUserIdFromToken(authHeader);
            if (userId == null) {
                return R.fail("Unauthorized: Invalid or missing token");
            }

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
     * Extract user ID from JWT token
     * TODO: 实现JWT token解析逻辑
     */
    private Long extractUserIdFromToken(String authHeader) {
        // TODO: 实现JWT解析
        // 临时返回1用于测试
        return 1L;
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
