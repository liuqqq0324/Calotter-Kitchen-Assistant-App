package com.calotter.cooking.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * Household Favorite Dish relation (favorites are a relationship, not a Dish field).
 *
 * - One household can favorite many dishes.
 * - A dish can be favorited by at most one household in practice because Dish already belongs to a household,
 *   but we still store householdId explicitly to keep the relation clear and future-proof.
 *
 * Important: Cooking creates Dish snapshots per cook, while favorites point to "template" dishes.
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(
        name = "household_favorite_dishes",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_household_dish", columnNames = {"household_id", "dish_id"})
        },
        indexes = {
                @Index(name = "idx_fav_household", columnList = "household_id"),
                @Index(name = "idx_fav_dish", columnList = "dish_id")
        }
)
public class HouseholdFavoriteDish extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "household_id", nullable = false)
    private Long householdId;

    @Column(name = "dish_id", nullable = false)
    private Long dishId;
}


