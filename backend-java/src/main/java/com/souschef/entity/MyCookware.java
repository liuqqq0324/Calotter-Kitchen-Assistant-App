package com.souschef.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "my_cookwares")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MyCookware {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    
    @Column(name = "kitchen_id", nullable = false)
    private Integer kitchenId;
    
    @Column(name = "standard_cookware_id", nullable = false)
    private Integer standardCookwareId;
    
    @Column(name = "is_available", nullable = false)
    private Boolean isAvailable = true;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kitchen_id", insertable = false, updatable = false)
    private Kitchen kitchen;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "standard_cookware_id", insertable = false, updatable = false)
    private StandardCookware standardCookware;
}


