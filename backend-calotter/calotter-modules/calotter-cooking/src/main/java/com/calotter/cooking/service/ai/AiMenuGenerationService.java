package com.calotter.cooking.service.ai;

import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.dto.MenuDTO;
import reactor.core.publisher.Flux;

import java.util.List;

/**
 * AI 菜单生成服务接口
 */
public interface AiMenuGenerationService {
    /**
     * 生成菜单列表（批量，一次性返回）
     */
    List<MenuDTO> generateMenus(RecipeGenerationFilter filter);

    /**
     * 流式生成菜单（SSE）：每次生成 1 个，逐个推送。
     * @param filter 生成过滤器
     * @return 菜单流
     */
    Flux<MenuDTO> generateMenuStream(RecipeGenerationFilter filter);
}

