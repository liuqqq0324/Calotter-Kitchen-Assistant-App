package com.calotter.user.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.common.core.domain.entity.RefAllergen;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 用户实体
 * 用户现在直接代表一个人，包含健康数据和饮食偏好
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

    // --- 从 FamilyMember 迁移的健康数据字段 ---
    
    private Integer gender;
    private LocalDate birthdate;
    private Integer currentHeight;
    private BigDecimal currentWeight;

    // --- 饮食画像 (PostgreSQL JSONB) ---
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<String> dietaryStyles;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, List<String>> preferences;

    /**
     * 饮食偏好 Map
     * 
     * <p>Key 使用 {@link com.calotter.common.core.domain.PreferenceStandardLibrary} 中定义的常量：
     * <ul>
     *   <li>{@link com.calotter.common.core.domain.PreferenceStandardLibrary#PREF_KEY_TASTE PREF_KEY_TASTE} - 口味偏好</li>
     *   <li>{@link com.calotter.common.core.domain.PreferenceStandardLibrary#PREF_KEY_CUISINE PREF_KEY_CUISINE} - 菜系偏好</li>
     * </ul>
     * 
     * <p>注意：厨具（cookers/equipment）不是用户偏好，应该从家庭厨具表（HouseholdUtensil）获取。
     * 
     * <p>预设值请参考 {@link com.calotter.common.core.domain.PreferenceStandardLibrary} 中的常量列表：
     * <ul>
     *   <li>口味选项：{@link com.calotter.common.core.domain.PreferenceStandardLibrary#TASTE_OPTIONS TASTE_OPTIONS}</li>
     *   <li>菜系选项：{@link com.calotter.common.core.domain.PreferenceStandardLibrary#CUISINE_OPTIONS CUISINE_OPTIONS}</li>
     * </ul>
     * 
     * <p>与 RecipeGenerationFilter.DietPreferences 的转换请使用 
     * {@link com.calotter.cooking.service.PreferenceConverter PreferenceConverter} 工具类。
     */

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "user_allergies",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "allergen_id")
    )
    private List<RefAllergen> allergies = new ArrayList<>();

    // --- 家庭关系 (ManyToMany) ---
    
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "users_households",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "household_id")
    )
    private List<Household> joinedHouseholds = new ArrayList<>();

    // --- 当前活跃的家庭上下文 ---
    
    @Column(name = "current_household_id")
    private Long currentHouseholdId;
}
