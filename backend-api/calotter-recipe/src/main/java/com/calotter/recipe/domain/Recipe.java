package com.calotter.recipe.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * rms_recipe;Stores all recipes and the corresponding ingredients. object rms_recipe
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rms_recipe")
public class Recipe extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Recipe id;Recipe ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Recipe name;Recipe name
     */
    private String name;

    /**
     * A brief description of recipe;Recipe description (e.g., scrambled eggs with tomatoes)
     */
    private String description;

    /**
     * Finish product image url;URL of finished product image
     */
    private String imageUrl;

    /**
     * The cuisine type of recipe;Cuisine type (e.g., Sichuan dishes, Italian noodles)
     */
    private String cuisineType;

    /**
     * The difficulty level;Difficulty of cooking: [1 - EZ, 2 - Medium, 3 - Hard]
     */
    private Short difficultyLevel;

    /**
     * The standard serving size;Standard serving size (e.g., for 2 people)
     */
    private Short servingSize;

    /**
     * The time cost for preparation;The time cost of preparation process
     */
    private Short prepTimeMinutes;

    /**
     * The time cost for cooking;The time cost of cooking process
     */
    private Short cookTimeMinutes;

    /**
     * The time cost in total;The time cost in total
     */
    private Short totalTimeMinutes;

    /**
     * The estimated calories per one serving size;The estimated calories per one serving size
     */
    private Short caloriesPerServing;

    /**
     * The tags of recipe;Tags of recipe
     */
    private JsonNode tags;

    /**
     * The detailed steps for cooking;Cooking steps
     */
    private JsonNode instructions;

}
