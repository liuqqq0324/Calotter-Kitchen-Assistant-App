package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.SessionRecipe;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;


/**
 * cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. view object cms_session_recipe
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = SessionRecipe.class)
public class SessionRecipeVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Session recipe id;Cooking session recipe ID (PK)
     */
    @ExcelProperty(value = "Session recipe id;Cooking session recipe ID (PK)")
    private Long id;

    /**
     * Session id;Cooking history ID (FK, session_id -> session.id)
     */
    @ExcelProperty(value = "Session id;Cooking history ID (FK, session_id -> session.id)")
    private Long sessionId;

    /**
     * Recipe id;Cooking recipe ID (FK, recipe_id -> recipe.id)
     */
    @ExcelProperty(value = "Recipe id;Cooking recipe ID (FK, recipe_id -> recipe.id)")
    private Long recipeId;

    /**
     * Number of roles served;Number of people that is able to serve
     */
    @ExcelProperty(value = "Number of roles served;Number of people that is able to serve")
    private Short servings;

    /**
     * Time spend on this dish;The actual time spend on this dish
     */
    @ExcelProperty(value = "Time spend on this dish;The actual time spend on this dish")
    private Short actualDurationMinutes;

    /**
     * The success level rating;The success level rating (level: [1 ~ 5])
     */
    @ExcelProperty(value = "The success level rating;The success level rating (level: [1 ~ 5])")
    private Short successRating;


}
