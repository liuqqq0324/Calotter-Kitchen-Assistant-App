package com.calotter.health.service.listener;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.service.NutritionAggregateService;
import com.calotter.health.service.event.NutritionLogCreatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * 营养日志创建事件监听器
 * 监听NutritionLogCreatedEvent，异步更新DailyNutrientAggregate
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class NutritionLogEventListener {
    
    private final NutritionAggregateService aggregateService;
    
    /**
     * 监听营养日志创建事件
     * 异步更新日聚合表
     */
    @EventListener
    @Async
    @Transactional
    public void handleNutritionLogCreated(NutritionLogCreatedEvent event) {
        try {
            log.info("收到营养日志创建事件，日志数量: {}", 
                    event.getLogs() != null ? event.getLogs().size() : 0);
            
            // 为每条日志更新聚合表
            if (event.getLogs() != null) {
                for (NutritionLog log : event.getLogs()) {
                    aggregateService.updateAggregate(log);
                }
            }
            
            log.info("成功更新日聚合表，日志数量: {}", 
                    event.getLogs() != null ? event.getLogs().size() : 0);
        } catch (Exception e) {
            log.error("处理营养日志创建事件失败", e);
            // 注意：这里可以选择是否抛出异常
            // 如果抛出异常，事务会回滚，但考虑到这是异步处理，可能需要记录错误但不影响主流程
        }
    }
}

