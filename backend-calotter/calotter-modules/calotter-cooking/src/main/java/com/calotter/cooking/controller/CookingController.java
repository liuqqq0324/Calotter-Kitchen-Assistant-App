package com.calotter.cooking.controller;

import com.calotter.common.core.Result;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.controller.dto.FinishCookingRequest;
import com.calotter.cooking.controller.dto.StartCookingRequest;
import com.calotter.cooking.service.CookingWorkflowService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 烹饪控制器
 */
@RestController
@RequestMapping("/api/cooking")
@RequiredArgsConstructor
public class CookingController {

    private final CookingWorkflowService cookingWorkflowService;

    /**
     * 开始烹饪：创建 Session，返回 sessionId
     */
    @PostMapping("/start")
    public Result<Long> startCooking(@Valid @RequestBody StartCookingRequest request) {
        return Result.success(cookingWorkflowService.startCooking(request));
    }

    /**
     * 完成烹饪：保存快照，扣减库存，创建剩菜记录
     * 取代旧版 /complete（已移除）：支持部分完成和用餐者信息
     */
    @PostMapping("/finish")
    public Result<CookingSession> finishCooking(@Valid @RequestBody FinishCookingRequest request) {
        return Result.success(cookingWorkflowService.finishCooking(request));
    }
}
