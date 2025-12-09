package com.calotter.recipe.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * rms_ingredient;Stores all ingredients could be used in a recipe. object rms_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rms_ingredient")
public class Ingredient extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Ingredient id;Ingredient ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Ingredient name;Ingredient name (e.g., tomato)
     */
    private String name;

    /**
     * Category;Ingredient category (e.g., vegetable)
     */
    private String category;

    /**
     * Standard unit;Standard unit (e.g., g)
     */
    private String standardUnit;

    /**
     * Nutrition information;Nutrition value
     */
    private JsonNode nutritionInfo;

    /**
     * Advice for the ingredient storage;Storage advice (for AI assistant prompt, e.g., Store in the refrigerator or in a cool, dark place)
     */
    private String storageAdvice;

    /**
     * Standard image;Standard image URL for ingredient image
     */
    private String imageUrl;


}
