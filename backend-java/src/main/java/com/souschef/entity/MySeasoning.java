package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "my_seasonings")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MySeasoning {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "kitchen_id", nullable = false)
    private Integer kitchenId;
    
    @Column(name = "standard_seasoning_id", nullable = false)
    private Integer standardSeasoningId;
    
    @Column(name = "is_available", nullable = false)
    private Boolean isAvailable = true;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kitchen_id", insertable = false, updatable = false)
    private Kitchen kitchen;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "standard_seasoning_id", insertable = false, updatable = false)
    private StandardSeasoning standardSeasoning;
}

