package com.calotter.cooking.controller;

import com.calotter.common.core.Result;
import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.AiMenuService;
import com.calotter.cooking.service.dto.MenuDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
    public Result<List<MenuDTO>> generateMenus(@Valid @RequestBody RecipeGenerationFilter filter) {
        return Result.success(aiMenuService.generateMenus(filter));
    }
}
