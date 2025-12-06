package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "kitchens")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Kitchen {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;
    
    @OneToMany(mappedBy = "kitchen", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<InventoryItem> inventoryItems = new ArrayList<>();
    
    @OneToMany(mappedBy = "kitchen", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MyCookware> myCookwares = new ArrayList<>();
    
    @OneToMany(mappedBy = "kitchen", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MySeasoning> mySeasonings = new ArrayList<>();
}


