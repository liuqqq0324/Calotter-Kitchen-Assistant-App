package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "generated_recipe_options")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GeneratedRecipeOption {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "ai_generation_session_id", nullable = false)
    private Integer aiGenerationSessionId;
    
    @Column(name = "menu_id", nullable = false)
    private Integer menuId;
    
    @Column(name = "title", nullable = false)
    private String title;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "total_calories", nullable = false)
    private Double totalCalories;
    
    @Column(name = "cooking_time", nullable = false)
    private Integer cookingTime;
    
    @Column(name = "difficulty", nullable = false)
    private String difficulty;
    
    @Column(name = "ingredients_json", columnDefinition = "TEXT")
    private String ingredientsJson = "[]";
    
    @Column(name = "steps_json", columnDefinition = "TEXT")
    private String stepsJson = "[]";
    
    @Column(name = "servings", nullable = false)
    private Integer servings;
    
    @Column(name = "used_cookwares_json", columnDefinition = "TEXT")
    private String usedCookwaresJson = "[]";
    
    @Column(name = "is_selected", nullable = false)
    private Boolean isSelected = false;
    
    @Column(name = "is_saved", nullable = false)
    private Boolean isSaved = false;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ai_generation_session_id", insertable = false, updatable = false)
    private AiGenerationSession aiGenerationSession;
}


