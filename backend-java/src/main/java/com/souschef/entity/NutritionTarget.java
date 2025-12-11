package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "hp_nutrition_target", schema = "sous_chef_hp")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NutritionTarget {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Column(name = "week_start", nullable = false)
    private LocalDate weekStart;
    
    @Column(name = "week_end", nullable = false)
    private LocalDate weekEnd;
    
    @Column(name = "weekly_target_energy", nullable = false, precision = 10, scale = 2)
    private BigDecimal weeklyTargetEnergy;
    
    @Column(name = "weekly_target_fat", nullable = false, precision = 10, scale = 2)
    private BigDecimal weeklyTargetFat;
    
    @Column(name = "weekly_target_carbohydrates", nullable = false, precision = 10, scale = 2)
    private BigDecimal weeklyTargetCarbohydrates;
    
    @Column(name = "weekly_target_protein", nullable = false, precision = 10, scale = 2)
    private BigDecimal weeklyTargetProtein;
    
    @Column(name = "bmi", precision = 5, scale = 2)
    private BigDecimal bmi;
    
    @Column(name = "goal_type", length = 50)
    private String goalType;
    
    @Column(name = "calculation_model", length = 50)
    private String calculationModel;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
