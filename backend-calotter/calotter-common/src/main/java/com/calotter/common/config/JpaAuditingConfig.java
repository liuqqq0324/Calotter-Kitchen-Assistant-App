package com.calotter.common.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.util.Optional;

/**
 * JPA Auditing 配置
 * 用于自动填充 @CreatedBy 和 @LastModifiedBy
 */
@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class JpaAuditingConfig {

    @Bean
    public AuditorAware<Long> auditorProvider() {
        // TODO: 从 SecurityContext 获取当前用户ID
        // 目前返回固定值，后续需要集成 Spring Security
        return () -> Optional.of(1L);
    }
}
