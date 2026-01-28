package com.calotter.health.service.listener;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.service.NutritionAggregateService;
import com.calotter.health.service.event.NutritionLogCreatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.context.event.EventListener;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionalEventListener;

/**
 * 营养日志创建事件监听器
 * 监听NutritionLogCreatedEvent，异步更新DailyNutrientAggregate
 * 
 * 修复说明：
 * - 使用 @TransactionalEventListener(phase = AFTER_COMMIT) 确保在主事务提交后才执行
 * - 避免测试环境 @Transactional 回滚导致外键约束失败
 * - 在测试环境禁用（@Profile("!test")），避免测试回滚与异步处理冲突
 */
@Slf4j
@Component
@Profile("!test") // 测试环境禁用，避免 @Transactional 回滚导致外键约束失败
@RequiredArgsConstructor
public class NutritionLogEventListener {
    
    private final NutritionAggregateService aggregateService;
    
    /**
     * 监听营养日志创建事件
     * 在主事务提交后异步更新日聚合表
     * 
     * 使用 AFTER_COMMIT 确保：
     * 1. 主事务已提交，数据已持久化
     * 2. 避免测试环境 @Transactional 回滚导致外键约束失败
     */
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
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
            // 注意：这里不抛出异常，避免影响主流程
            // 异步处理失败只记录日志，不影响 NutritionLog 的创建
        }
    }
}

