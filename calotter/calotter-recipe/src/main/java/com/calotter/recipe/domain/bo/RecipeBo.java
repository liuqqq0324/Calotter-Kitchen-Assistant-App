package com.calotter.recipe.domain.bo;

import cn.hutool.core.date.DateTime;
import com.calotter.recipe.domain.Recipe;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import com.fasterxml.jackson.databind.JsonNode;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * rms_recipe;Stores all recipes and the corresponding ingredients. business object rms_recipe
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = Recipe.class, reverseConvertGenerate = false)
public class RecipeBo extends BaseEntity {

    /**
     * Recipe id;Recipe ID (PK)
     */
    @NotNull(message = "Recipe id;Recipe ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Recipe name;Recipe name
     */
    @NotBlank(message = "Recipe name;Recipe name can not be empty", groups = { AddGroup.class, EditGroup.class })
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
