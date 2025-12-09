package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.SessionRecipe;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. business object cms_session_recipe
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = SessionRecipe.class, reverseConvertGenerate = false)
public class SessionRecipeBo extends BaseEntity {

    /**
     * Session recipe id;Cooking session recipe ID (PK)
     */
    @NotNull(message = "Session recipe id;Cooking session recipe ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Session id;Cooking history ID (FK, session_id -> session.id)
     */
    @NotNull(message = "Session id;Cooking history ID (FK, session_id -> session.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long sessionId;

    /**
     * Recipe id;Cooking recipe ID (FK, recipe_id -> recipe.id)
     */
    @NotNull(message = "Recipe id;Cooking recipe ID (FK, recipe_id -> recipe.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
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
