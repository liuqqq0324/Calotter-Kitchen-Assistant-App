package com.calotter.health.service.event;

import com.calotter.health.domain.entity.NutritionLog;
import lombok.Data;
import org.springframework.context.ApplicationEvent;

import java.util.List;

/**
 * 营养日志创建事件
 * 用于触发DailyNutrientAggregate的异步更新
 */
@Data
public class NutritionLogCreatedEvent extends ApplicationEvent {
    
    private List<NutritionLog> logs;
    
    public NutritionLogCreatedEvent(Object source, List<NutritionLog> logs) {
        super(source);
        this.logs = logs;
    }
}

