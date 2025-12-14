package com.calotter.inventory.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.common.core.domain.entity.StandardUtensil;
import com.calotter.user.domain.entity.Household;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 家庭厨具实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "household_utensils")
public class HouseholdUtensil extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private Household household;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "standard_utensil_id", nullable = false)
    private StandardUtensil metadata;

    @Column(nullable = false, columnDefinition = "boolean default true")
    private Boolean isAvailable;

    private String remark;
}
