package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "standard_ingredients")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StandardIngredient {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "name", nullable = false, unique = true)
    private String name;
    
    @Column(name = "category", nullable = false)
    private String category;
    
    @Column(name = "base_unit", nullable = false)
    private String baseUnit = "g";
    
    @Column(name = "image_url")
    private String imageUrl = "";
}


