package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "rms_recipe", schema = "sous_chef_rms")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Recipe {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "name", nullable = false, length = 100)
    private String name;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "image_url", length = 255)
    private String imageUrl;
    
    @Column(name = "cuisine_type", length = 50)
    private String cuisineType;
    
    @Column(name = "difficulty_level")
    private Integer difficultyLevel; // 1 - Easy, 2 - Medium, 3 - Hard
    
    @Column(name = "serving_size")
    private Integer servingSize;
    
    @Column(name = "prep_time_minutes")
    private Integer prepTimeMinutes;
    
    @Column(name = "cook_time_minutes")
    private Integer cookTimeMinutes;
    
    @Column(name = "total_time_minutes")
    private Integer totalTimeMinutes;
    
    @Column(name = "calories_per_serving")
    private Integer caloriesPerServing;
    
    @Column(name = "tags", columnDefinition = "jsonb")
    private String tags; // JSON string
    
    @Column(name = "instructions", columnDefinition = "jsonb")
    private String instructions; // JSON string
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeIngredient> ingredients = new ArrayList<>();
    
    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeKitchenware> kitchenwares = new ArrayList<>();
    
    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}

