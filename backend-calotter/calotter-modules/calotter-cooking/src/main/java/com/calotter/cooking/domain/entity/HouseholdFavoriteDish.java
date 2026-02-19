package com.calotter.cooking.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * Household Favorite Recipe relation (收藏关系表)
 *
 * - One household can favorite many recipes (UserRecipe).
 * - Favorites now point to UserRecipe (not Dish), achieving physical isolation.
 * - 收藏与烹饪记录完全隔离，删除收藏不影响历史 Dish 记录。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(
        name = "household_favorite_dishes",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_household_recipe", columnNames = {"household_id", "recipe_id"})
        },
        indexes = {
                @Index(name = "idx_fav_household", columnList = "household_id"),
                @Index(name = "idx_fav_recipe", columnList = "recipe_id")
        }
)
public class HouseholdFavoriteDish extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "household_id", nullable = false)
    private Long householdId;

    /**
     * 收藏的菜谱ID（指向 UserRecipe）
     * 注意：字段名从 dish_id 改为 recipe_id，但表名保持不变以兼容现有数据
     */
    @Column(name = "recipe_id", nullable = false)
    private Long recipeId;
}


