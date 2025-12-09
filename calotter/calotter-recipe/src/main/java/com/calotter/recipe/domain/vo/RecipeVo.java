package com.calotter.recipe.domain.vo;

import java.util.Date;

import cn.hutool.core.date.DateTime;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.calotter.recipe.domain.Recipe;
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
 * rms_recipe;Stores all recipes and the corresponding ingredients. view object rms_recipe
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = Recipe.class)
public class RecipeVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Recipe id;Recipe ID (PK)
     */
    @ExcelProperty(value = "Recipe id;Recipe ID (PK)")
    private Long id;

    /**
     * Recipe name;Recipe name
     */
    @ExcelProperty(value = "Recipe name;Recipe name")
    private String name;

    /**
     * A brief description of recipe;Recipe description (e.g., scrambled eggs with tomatoes)
     */
    @ExcelProperty(value = "A brief description of recipe;Recipe description (e.g., scrambled eggs with tomatoes)")
    private String description;

    /**
     * Finish product image url;URL of finished product image
     */
    @ExcelProperty(value = "Finish product image url;URL of finished product image")
    private String imageUrl;

    /**
     * The cuisine type of recipe;Cuisine type (e.g., Sichuan dishes, Italian noodles)
     */
    @ExcelProperty(value = "The cuisine type of recipe;Cuisine type (e.g., Sichuan dishes, Italian noodles)")
    private String cuisineType;

    /**
     * The difficulty level;Difficulty of cooking: [1 - EZ, 2 - Medium, 3 - Hard]
     */
    @ExcelProperty(value = "The difficulty level;Difficulty of cooking: [1 - EZ, 2 - Medium, 3 - Hard]")
    private Short difficultyLevel;

    /**
     * The standard serving size;Standard serving size (e.g., for 2 people)
     */
    @ExcelProperty(value = "The standard serving size;Standard serving size (e.g., for 2 people)")
    private Short servingSize;

    /**
     * The time cost for preparation;The time cost of preparation process
     */
    @ExcelProperty(value = "The time cost for preparation;The time cost of preparation process")
    private Short prepTimeMinutes;

    /**
     * The time cost for cooking;The time cost of cooking process
     */
    @ExcelProperty(value = "The time cost for cooking;The time cost of cooking process")
    private Short cookTimeMinutes;

    /**
     * The time cost in total;The time cost in total
     */
    @ExcelProperty(value = "The time cost in total;The time cost in total")
    private Short totalTimeMinutes;

    /**
     * The estimated calories per one serving size;The estimated calories per one serving size
     */
    @ExcelProperty(value = "The estimated calories per one serving size;The estimated calories per one serving size")
    private Short caloriesPerServing;

    /**
     * The tags of recipe;Tags of recipe
     */
    @ExcelProperty(value = "The tags of recipe;Tags of recipe")
    private JsonNode tags;

    /**
     * The detailed steps for cooking;Cooking steps
     */
    @ExcelProperty(value = "The detailed steps for cooking;Cooking steps")
    private JsonNode instructions;

}
