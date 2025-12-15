package com.calotter.health.service.listener;

import com.calotter.cooking.service.event.CookingSessionCompletedEvent;
import com.calotter.health.service.NutritionLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * 烹饪会话完成事件监听器
 * 监听来自cooking模块的CookingSessionCompletedEvent
 * 创建NutritionLog记录
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CookingSessionCompletedEventListener {
    
    private final NutritionLogService nutritionLogService;
    
    /**
     * 监听烹饪会话完成事件
     * 创建营养日志记录
     */
    @EventListener
    @Async
    @Transactional
    public void handleCookingSessionCompleted(CookingSessionCompletedEvent event) {
        try {
            log.info("收到烹饪会话完成事件，Dish ID: {}, 用餐者数量: {}", 
                    event.getDishId(), event.getDiners() != null ? event.getDiners().size() : 0);
            
            // 调用NutritionLogService创建日志
            nutritionLogService.createFromEvent(event);
            
            log.info("成功创建营养日志，Dish ID: {}", event.getDishId());
        } catch (Exception e) {
            log.error("处理烹饪会话完成事件失败，Dish ID: {}", event.getDishId(), e);
            // 注意：这里可以选择是否抛出异常，如果抛出异常，事务会回滚
            // 但考虑到这是异步处理，可能需要记录错误但不影响主流程
        }
    }
}

