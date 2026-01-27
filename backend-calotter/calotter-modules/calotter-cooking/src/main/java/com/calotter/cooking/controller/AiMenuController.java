package com.calotter.cooking.controller;

import com.calotter.common.core.Result;
import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.AiMenuService;
import com.calotter.cooking.service.dto.MenuDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

import java.util.List;

/**
 * AI 菜单生成接口
 */
@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiMenuController {

    private final AiMenuService aiMenuService;

    @PostMapping("/generate-menus")
    public Result<List<MenuDTO>> generateMenus(
            @Valid @RequestBody RecipeGenerationFilter filter,
            @RequestParam(value = "householdId", required = false) Long householdId) {
        return Result.success(aiMenuService.generateMenus(filter, householdId));
    }

    @PostMapping(value = "/generate-menus/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<MenuDTO> generateMenusStream(
            @Valid @RequestBody RecipeGenerationFilter filter,
            @RequestParam(value = "householdId", required = false) Long householdId) {
        return aiMenuService.generateMenuStream(filter, householdId);
    }
}
