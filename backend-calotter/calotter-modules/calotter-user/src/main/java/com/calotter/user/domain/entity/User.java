package com.calotter.user.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.Map;

/**
 * 用户实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "users")
public class User extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false, length = 20)
    private String role; // "ROLE_USER", "ROLE_ADMIN"

    private String avatar;
    private String displayname;

    @Column(nullable = false, columnDefinition = "int default 0")
    private Integer status; // 0:未激活, 1:可用, 2:封禁

    @Column(nullable = false, columnDefinition = "Boolean default false")
    private Boolean isOnboarded;

    // PostgreSQL 推荐使用 jsonb
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb") 
    private Map<String, Object> settings;
}
