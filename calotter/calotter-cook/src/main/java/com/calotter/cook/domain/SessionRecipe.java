package com.calotter.cook.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. object cms_session_recipe
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cms_session_recipe")
public class SessionRecipe extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Session recipe id;Cooking session recipe ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Session id;Cooking history ID (FK, session_id -> session.id)
     */
    private Long sessionId;

    /**
     * Recipe id;Cooking recipe ID (FK, recipe_id -> recipe.id)
     */
    private Long recipeId;

    /**
     * Number of roles served;Number of people that is able to serve
     */
    private Short servings;

    /**
     * Time spend on this dish;The actual time spend on this dish
     */
    private Short actualDurationMinutes;

    /**
     * The success level rating;The success level rating (level: [1 ~ 5])
     */
    private Short successRating;


}
