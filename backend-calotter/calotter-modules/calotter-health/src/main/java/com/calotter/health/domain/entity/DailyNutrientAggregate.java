package com.calotter.health.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.user.domain.entity.FamilyMember;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

/**
 * 日营养聚合实体
 * 用于"缓存"每日的进度，是前端首页"今日摄入环形图"和"周健康报告"的数据源
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "daily_nutrient_aggregates", 
       indexes = {
           @Index(name = "idx_aggregate_member_date", columnList = "family_member_id, date", unique = true)
       })
public class DailyNutrientAggregate extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ✅ 使用JPA关联，而不是Long类型
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "family_member_id", nullable = false)
    private FamilyMember familyMember;

    @Column(nullable = false)
    private LocalDate date; // 哪一天

    // --- 累计数值 ---
    @Column(name = "total_calories", nullable = false, columnDefinition = "int default 0")
    private Integer totalCalories = 0;
    
    @Column(name = "total_protein", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalProtein = 0.0;
    
    @Column(name = "total_fat", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalFat = 0.0;
    
    @Column(name = "total_carb", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalCarb = 0.0;
    
    @Column(name = "total_fiber", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalFiber = 0.0;

    // --- 目标快照 (可选) ---
    // 记录当天的目标值，这样即使未来改了HealthGoal，也能回溯历史达标率
    @Column(name = "goal_calories_snapshot")
    private Integer goalCaloriesSnapshot;
    
    @Column(name = "goal_protein_snapshot")
    private Integer goalProteinSnapshot;
    
    @Column(name = "goal_fat_snapshot")
    private Integer goalFatSnapshot;
    
    @Column(name = "goal_carb_snapshot")
    private Integer goalCarbSnapshot;
    
    @Column(name = "goal_fiber_snapshot")
    private Integer goalFiberSnapshot;
    
    // 乐观锁版本号，防止并发写入导致统计错误
    @Version
    private Integer version;
}

