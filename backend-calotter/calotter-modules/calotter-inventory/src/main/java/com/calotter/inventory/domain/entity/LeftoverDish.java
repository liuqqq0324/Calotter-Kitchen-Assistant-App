package com.calotter.inventory.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.user.domain.entity.Household;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 剩菜实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "household_leftovers")
public class LeftoverDish extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private Household household;

    @Column(nullable = false)
    private String name;
    
    private String coverImage;
    
    private Double quantityGram;
    
    @Column(nullable = false)
    private LocalDateTime producedTime;
}
