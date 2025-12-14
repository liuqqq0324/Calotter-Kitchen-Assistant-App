package com.calotter.cooking.controller;

import com.calotter.common.core.Result;
import com.calotter.cooking.controller.dto.CookingGenerationRequest;
import com.calotter.cooking.service.CookingContextBuilderService;
import com.calotter.cooking.service.dto.AiCookingContext;
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

    /**
     * 生成烹饪上下文
     */
    @PostMapping("/generate-context")
    public Result<AiCookingContext> generateContext(@RequestBody CookingGenerationRequest request) {
        AiCookingContext context = cookingContextBuilderService.buildContext(request);
        return Result.success(context);
    }
}
