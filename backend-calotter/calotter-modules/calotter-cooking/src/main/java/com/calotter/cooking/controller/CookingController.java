package com.calotter.cooking.controller;

import com.calotter.common.core.Result;
import com.calotter.cooking.controller.dto.CookingCompletionRequest;
import com.calotter.cooking.controller.dto.CookingCompletionResponse;
import com.calotter.cooking.controller.dto.CookingGenerationRequest;
import com.calotter.cooking.service.CookingContextBuilderService;
import com.calotter.cooking.service.CookingSessionService;
import com.calotter.cooking.service.dto.AiCookingContext;
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

    private final CookingContextBuilderService cookingContextBuilderService;
    private final CookingSessionService cookingSessionService;

    /**
     * 生成烹饪上下文
     */
    @PostMapping("/generate-context")
    public Result<AiCookingContext> generateContext(@RequestBody CookingGenerationRequest request) {
        AiCookingContext context = cookingContextBuilderService.buildContext(request);
        return Result.success(context);
    }
    
    /**
     * 完成烹饪会话
     * 记录家庭成员摄入量，并自动处理剩菜
     */
    @PostMapping("/complete")
    public Result<CookingCompletionResponse> completeSession(
            @Valid @RequestBody CookingCompletionRequest request) {
        CookingCompletionResponse response = cookingSessionService.completeSession(request);
        return Result.success(response);
    }
}
