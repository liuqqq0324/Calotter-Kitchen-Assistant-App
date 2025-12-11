package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "hp_intake_record", schema = "sous_chef_hp")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class IntakeRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "user_id", nullable = false)
    private Long userId;
    
    @Column(name = "date", nullable = false)
    private LocalDate date;
    
    @Column(name = "source_type", nullable = false, length = 20)
    private String sourceType; // 'recipe' or 'manual'
    
    @Column(name = "recipe_id")
    private Integer recipeId;
    
    @Column(name = "recipe_title", length = 255)
    private String recipeTitle;
    
    @Column(name = "manual_food_name", length = 255)
    private String manualFoodName;
    
    @Column(name = "portion_description", length = 255)
    private String portionDescription;
    
    @Column(name = "consumed_percentage", precision = 5, scale = 2)
    private BigDecimal consumedPercentage = BigDecimal.valueOf(100.00);
    
    @Column(name = "base_energy", precision = 10, scale = 2)
    private BigDecimal baseEnergy;
    
    @Column(name = "base_fat", precision = 10, scale = 2)
    private BigDecimal baseFat;
    
    @Column(name = "base_carbohydrates", precision = 10, scale = 2)
    private BigDecimal baseCarbohydrates;
    
    @Column(name = "base_protein", precision = 10, scale = 2)
    private BigDecimal baseProtein;
    
    @Column(name = "effective_energy", precision = 10, scale = 2)
    private BigDecimal effectiveEnergy;
    
    @Column(name = "effective_fat", precision = 10, scale = 2)
    private BigDecimal effectiveFat;
    
    @Column(name = "effective_carbohydrates", precision = 10, scale = 2)
    private BigDecimal effectiveCarbohydrates;
    
    @Column(name = "effective_protein", precision = 10, scale = 2)
    private BigDecimal effectiveProtein;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * Calculate effective nutrition values based on consumed percentage
     */
    public void calculateEffectiveNutrition() {
        if (consumedPercentage == null || baseEnergy == null) {
            return;
        }
        
        BigDecimal percentage = consumedPercentage.divide(BigDecimal.valueOf(100), 4, java.math.RoundingMode.HALF_UP);
        
        if (baseEnergy != null) {
            this.effectiveEnergy = baseEnergy.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        if (baseFat != null) {
            this.effectiveFat = baseFat.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        if (baseCarbohydrates != null) {
            this.effectiveCarbohydrates = baseCarbohydrates.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        if (baseProtein != null) {
            this.effectiveProtein = baseProtein.multiply(percentage).setScale(2, java.math.RoundingMode.HALF_UP);
        }
    }
}
