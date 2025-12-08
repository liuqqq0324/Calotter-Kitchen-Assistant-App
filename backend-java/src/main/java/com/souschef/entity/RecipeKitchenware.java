package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "rms_recipe_kitchenware", schema = "sous_chef_rms")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeKitchenware {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kitchenware_id", nullable = false)
    private StandardCookware kitchenware;
    
    @Column(name = "note", length = 50)
    private String note;
}

