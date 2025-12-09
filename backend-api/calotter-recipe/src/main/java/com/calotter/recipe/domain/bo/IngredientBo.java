package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.Ingredient;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import com.fasterxml.jackson.databind.JsonNode;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * rms_ingredient;Stores all ingredients could be used in a recipe. business object rms_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = Ingredient.class, reverseConvertGenerate = false)
public class IngredientBo extends BaseEntity {

    /**
     * Ingredient id;Ingredient ID (PK)
     */
    @NotNull(message = "Ingredient id;Ingredient ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Ingredient name;Ingredient name (e.g., tomato)
     */
    @NotBlank(message = "Ingredient name;Ingredient name (e.g., tomato) can not be empty", groups = { AddGroup.class, EditGroup.class })
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
