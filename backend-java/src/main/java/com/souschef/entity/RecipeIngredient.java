package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "rms_recipe_ingredient", schema = "sous_chef_rms")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeIngredient {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ingredient_id", nullable = false)
    private StandardIngredient ingredient;
    
    @Column(name = "quantity", nullable = false, precision = 10, scale = 2)
    private java.math.BigDecimal quantity;
    
    @Column(name = "unit", nullable = false, length = 20)
    private String unit;
    
    @Column(name = "processing_note", length = 50)
    private String processingNote;
    
    @Column(name = "optional")
    private Boolean optional = false;
    
    @Column(name = "garnish")
    private Boolean garnish = false;
    
    @Column(name = "sort")
    private Integer sort;
}

