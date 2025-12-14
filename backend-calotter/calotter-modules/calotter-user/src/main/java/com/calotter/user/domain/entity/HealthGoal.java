package com.calotter.user.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/**
 * 健康目标实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "health_goals", indexes = {
    @Index(name = "idx_goal_member_status", columnList = "member_id, status")
})
public class HealthGoal extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private FamilyMember familyMember;

    @Column(nullable = false, columnDefinition = "int default 1")
    private Integer status; // 1: ACTIVE, 0: ARCHIVED

    // 初始快照
    @Column(precision = 5, scale = 2)
    private BigDecimal startWeight;
    private Integer height;
    private Integer age;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private GoalType goalType; // LOSE_FAT, MUSCLE_GAIN

    @Column(nullable = false)
    private Double activityLevel;

    // 计算结果
    private Integer dailyCalories;
    private Integer protein;
    private Integer fat;
    private Integer carb;
    private Integer fiber;

    public enum GoalType {
        LOSE_FAT, MUSCLE_GAIN, MAINTENANCE
    }
}
