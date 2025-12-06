package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "generated_recipes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GeneratedRecipe {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "title", nullable = false)
    private String title;
    
    @Column(name = "short_description", columnDefinition = "TEXT")
    private String shortDescription;
    
    @Column(name = "servings", nullable = false)
    private Integer servings;
    
    @Column(name = "cooking_time_min", nullable = false)
    private Integer cookingTimeMin;
    
    @Column(name = "difficulty", nullable = false)
    private String difficulty;
    
    @Column(name = "total_calories_estimate", nullable = false)
    private Double totalCaloriesEstimate;
    
    @Column(name = "used_cookwares_json", columnDefinition = "TEXT")
    private String usedCookwaresJson = "[]";
    
    @Column(name = "steps_json", columnDefinition = "TEXT")
    private String stepsJson = "[]";
    
    @Column(name = "ingredients_json", columnDefinition = "TEXT")
    private String ingredientsJson = "[]";
    
    @Column(name = "generated_at", nullable = false)
    private LocalDateTime generatedAt = LocalDateTime.now();
}


