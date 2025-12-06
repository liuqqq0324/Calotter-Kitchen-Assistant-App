package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "inventory_items")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class InventoryItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "kitchen_id", nullable = false)
    private Integer kitchenId;
    
    @Column(name = "standard_ingredient_id", nullable = false)
    private Integer standardIngredientId;
    
    @Column(name = "quantity", nullable = false)
    private Double quantity;
    
    @Column(name = "unit", nullable = false)
    private String unit;
    
    @Column(name = "expiry_date", nullable = false)
    private LocalDateTime expiryDate;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kitchen_id", insertable = false, updatable = false)
    private Kitchen kitchen;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "standard_ingredient_id", insertable = false, updatable = false)
    private StandardIngredient standardIngredient;
}

