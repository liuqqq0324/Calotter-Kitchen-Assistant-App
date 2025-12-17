package com.calotter.health.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.user.domain.entity.User;
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
           @Index(name = "idx_aggregate_user_date", columnList = "user_id, date", unique = true)
       })
public class DailyNutrientAggregate extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ✅ 使用JPA关联，而不是Long类型
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate date; // 哪一天

    // --- 累计数值 ---
    @Column(name = "total_energy", nullable = false, columnDefinition = "int default 0")
    private Integer totalEnergy = 0;
    
    @Column(name = "total_protein", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalProtein = 0.0;
    
    @Column(name = "total_fat", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalFat = 0.0;
    
    @Column(name = "total_carbohydrates", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalCarbohydrates = 0.0;
    
    @Column(name = "total_fiber", nullable = false, columnDefinition = "double precision default 0.0")
    private Double totalFiber = 0.0;

    // --- 目标快照 (可选) ---
    // 记录当天的目标值，这样即使未来改了HealthGoal，也能回溯历史达标率
    @Column(name = "goal_energy_snapshot")
    private Integer goalEnergySnapshot;
    
    @Column(name = "goal_protein_snapshot")
    private Integer goalProteinSnapshot;
    
    @Column(name = "goal_fat_snapshot")
    private Integer goalFatSnapshot;
    
    @Column(name = "goal_carbohydrates_snapshot")
    private Integer goalCarbohydratesSnapshot;
    
    @Column(name = "goal_fiber_snapshot")
    private Integer goalFiberSnapshot;
    
    // 乐观锁版本号，防止并发写入导致统计错误
    @Version
    private Integer version;
}

