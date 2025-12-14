package com.calotter.user.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.List;

/**
 * 家庭组实体
 * 
 * 注意：为了避免模块间的循环依赖，这里不直接引用 inventory 模块的实体。
 * Inventory 实体（Ingredient, LeftoverDish, HouseholdUtensil, HouseholdSpice）
 * 通过 @ManyToOne 关系引用 Household，JPA 会自动维护双向关系。
 * 级联删除通过数据库外键约束实现。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "households")
public class Household extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String inviteCode;

    @Column(nullable = false)
    private Long ownerId;

    // --- 级联管理 ---
    
    @OneToMany(mappedBy = "household", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<FamilyMember> members = new ArrayList<>();
}
