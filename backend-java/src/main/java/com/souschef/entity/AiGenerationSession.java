package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "ai_generation_sessions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AiGenerationSession {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "kitchen_id", nullable = false)
    private Integer kitchenId;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "servings", nullable = false)
    private Integer servings;
    
    @Column(name = "target_min_calories")
    private Integer targetMinCalories;
    
    @Column(name = "target_max_calories")
    private Integer targetMaxCalories;
    
    @Column(name = "dish_count", nullable = false)
    private Integer dishCount = 1;
    
    @Column(name = "max_cooking_time_min")
    private Integer maxCookingTimeMin;
    
    @Column(name = "difficulty_target", nullable = false)
    private String difficultyTarget = "medium";
    
    @Column(name = "inventory_snapshot_json", columnDefinition = "TEXT")
    private String inventorySnapshotJson = "";
    
    @Column(name = "preferences_snapshot_json", columnDefinition = "TEXT")
    private String preferencesSnapshotJson = "";
    
    @Column(name = "cookers_snapshot_json", columnDefinition = "TEXT")
    private String cookersSnapshotJson = "[]";
    
    @OneToMany(mappedBy = "aiGenerationSession", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<GeneratedRecipeOption> generatedOptions = new ArrayList<>();
}

