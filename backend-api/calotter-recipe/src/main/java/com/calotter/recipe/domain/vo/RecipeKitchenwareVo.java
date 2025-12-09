package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.RecipeKitchenware;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import com.calotter.common.excel.annotation.ExcelDictFormat;
import com.calotter.common.excel.convert.ExcelDictConvert;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;



/**
 * rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. view object rms_recipe_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = RecipeKitchenware.class)
public class RecipeKitchenwareVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Recipe kitchenware id;Recipe kitchenware ID (PK)
     */
    @ExcelProperty(value = "Recipe kitchenware id;Recipe kitchenware ID (PK)")
    private Long id;

    /**
     * Recipe id;Recipe ID (FK, recipe_id -> recipe.id)
     */
    @ExcelProperty(value = "Recipe id;Recipe ID (FK, recipe_id -> recipe.id)")
    private Long recipeId;

    /**
     * Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id)
     */
    @ExcelProperty(value = "Kitchenware id;Kitchenware ID (FK, kitchenware_id -> kitchenware.id)")
    private Long kitchenwareId;

    /**
     * Note;Note (e.g., pre-heat to 200 degrees centigrade)
     */
    @ExcelProperty(value = "Note;Note (e.g., pre-heat to 200 degrees centigrade)")
    private String note;


}
