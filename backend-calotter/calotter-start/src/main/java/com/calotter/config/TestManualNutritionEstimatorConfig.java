package com.calotter.config;

import com.calotter.health.service.ai.ManualNutritionEstimator;
import com.calotter.health.service.ai.NutritionEstimate;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import java.math.BigDecimal;

/**
 * 测试环境下的手动营养估算器（避免真实网络调用）。
 *
 * <p>IntakeController -> IntakeServiceImpl.addManualIntake 依赖 ManualNutritionEstimator。
 * 集成测试环境不应依赖外部 LLM/网络，因此在 test profile 下提供一个稳定的实现。</p>
 */
@Configuration
@Profile("test")
public class TestManualNutritionEstimatorConfig {

    @Bean
    @Primary
    public ManualNutritionEstimator manualNutritionEstimator() {
        return (foodName, portionDescription) -> new NutritionEstimate(
                BigDecimal.valueOf(650),   // energy kcal
                BigDecimal.valueOf(20),    // fat g
                BigDecimal.valueOf(80),    // carbohydrates g
                BigDecimal.valueOf(25),    // protein g
                "test"
        );
    }
}

