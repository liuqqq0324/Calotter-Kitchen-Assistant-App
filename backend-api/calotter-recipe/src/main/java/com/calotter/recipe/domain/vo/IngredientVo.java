package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.Ingredient;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import com.calotter.common.excel.annotation.ExcelDictFormat;
import com.calotter.common.excel.convert.ExcelDictConvert;
import com.fasterxml.jackson.databind.JsonNode;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;



/**
 * rms_ingredient;Stores all ingredients could be used in a recipe. view object rms_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = Ingredient.class)
public class IngredientVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Ingredient id;Ingredient ID (PK)
     */
    @ExcelProperty(value = "Ingredient id;Ingredient ID (PK)")
    private Long id;

    /**
     * Ingredient name;Ingredient name (e.g., tomato)
     */
    @ExcelProperty(value = "Ingredient name;Ingredient name (e.g., tomato)")
    private String name;

    /**
     * Category;Ingredient category (e.g., vegetable)
     */
    @ExcelProperty(value = "Category;Ingredient category (e.g., vegetable)")
    private String category;

    /**
     * Standard unit;Standard unit (e.g., g)
     */
    @ExcelProperty(value = "Standard unit;Standard unit (e.g., g)")
    private String standardUnit;

    /**
     * Nutrition information;Nutrition value
     */
    @ExcelProperty(value = "Nutrition information;Nutrition value")
    private JsonNode nutritionInfo;

    /**
     * Advice for the ingredient storage;Storage advice (for AI assistant prompt, e.g., Store in the refrigerator or in a cool, dark place)
     */
    @ExcelProperty(value = "Advice for the ingredient storage;Storage advice (for AI assistant prompt, e.g., Store in the refrigerator or in a cool, dark place)")
    private String storageAdvice;

    /**
     * Standard image;Standard image URL for ingredient image
     */
    @ExcelProperty(value = "Standard image;Standard image URL for ingredient image")
    private String imageUrl;


}
