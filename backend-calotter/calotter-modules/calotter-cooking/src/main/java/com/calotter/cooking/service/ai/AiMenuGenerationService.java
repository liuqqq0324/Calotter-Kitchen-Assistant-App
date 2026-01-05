package com.calotter.cooking.service.ai;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;

import java.util.List;

/**
 * AI 菜单生成服务接口
 */
public interface AiMenuGenerationService {
    /**
     * 生成菜单列表
     * @param filter 生成过滤器
     * @return 菜单列表
     */
    List<MenuDTO> generateMenus(RecipeGenerationFilter filter);
}

