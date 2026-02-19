package com.calotter.common.core.domain;

import jakarta.persistence.*;
import lombok.Data;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 所有实体类的基类
 * 需在启动类添加 @EnableJpaAuditing
 */
@Data
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity implements Serializable {

    @CreatedDate
    @Column(name = "create_time", updatable = false)
    private LocalDateTime createTime;

    @LastModifiedDate
    @Column(name = "update_time")
    private LocalDateTime updateTime;

    @CreatedBy
    @Column(name = "create_by", updatable = false)
    private Long createBy; // 统一使用 Long 类型存储 User ID

    @LastModifiedBy
    @Column(name = "update_by")
    private Long updateBy;
}
