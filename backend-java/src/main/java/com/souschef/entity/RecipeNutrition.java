package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "hp_recipe_nutrition", schema = "sous_chef_hp")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeNutrition {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "recipe_id", nullable = false, unique = true)
    private Integer recipeId;
    
    @Column(name = "energy", nullable = false, precision = 10, scale = 2)
    private BigDecimal energy;
    
    @Column(name = "fat", nullable = false, precision = 10, scale = 2)
    private BigDecimal fat;
    
    @Column(name = "carbohydrates", nullable = false, precision = 10, scale = 2)
    private BigDecimal carbohydrates;
    
    @Column(name = "protein", nullable = false, precision = 10, scale = 2)
    private BigDecimal protein;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
