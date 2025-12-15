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
import java.util.List;
import java.util.Map;

/**
 * 家庭成员实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "family_members", indexes = {
    @Index(name = "idx_member_household_id", columnList = "household_id"),
    @Index(name = "idx_member_user_id", columnList = "user_id")
})
public class FamilyMember extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private Household household;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id") // 允许为空 (影子成员)
    private User user;

    @Column(nullable = false, columnDefinition = "Boolean default false")
    private Boolean isAdmin;

    @Column(nullable = false)
    private String name; 
    
    private String avatar;
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
     * 需要在代码层面约定好 Key 的名字即可，不需要改数据库结构。
     * 我们约定以下三个 Key：
     * 1. "TASTE"：口味 (e.g., "Sour", "Spicy", "Light")
     * 2. "CUISINE"：菜系 (e.g., "Sichuan", "Italian")
     * 3. "DISLIKE"：不喜欢的食材 (e.g., "Cilantro", "Carrot", "Lamb")
     */

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "member_allergies",
        joinColumns = @JoinColumn(name = "member_id"),
        inverseJoinColumns = @JoinColumn(name = "allergen_id")
    )
    private List<RefAllergen> allergies;
}
