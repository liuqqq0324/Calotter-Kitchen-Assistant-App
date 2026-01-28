package com.calotter.cooking.service.ai;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;

import java.util.List;

/**
 * AI 菜单生成服务接口
 */
public interface AiMenuGenerationService {
    /**
     * 生成菜单列表（批量，一次性返回）
     */
    List<MenuDTO> generateMenus(RecipeGenerationFilter filter);
}

