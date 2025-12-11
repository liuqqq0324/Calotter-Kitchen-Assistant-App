package com.calotter.inventory.domain.bo;

import com.calotter.inventory.domain.UserIngredient;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. business object ims_user_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = UserIngredient.class, reverseConvertGenerate = false)
public class UserIngredientBo extends BaseEntity {

    /**
     * Pantry id;Pantry ID (PK)
     */
    @NotNull(message = "Pantry id;Pantry ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * User id;Whose pantry (FK, user_id -> user.id)
     */
    @NotNull(message = "User id;Whose pantry (FK, user_id -> user.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long userId;

    /**
     * Ingredient id;The associated ingredient (FK, ingredient_id -> ingredient.id)
     */
    @NotNull(message = "Ingredient id;The associated ingredient (FK, ingredient_id -> ingredient.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long ingredientId;

    /**
     * Quantity;Quantity of the ingredient
     */
    private Double quantity;

    /**
     * Current unit;Current unit of the ingredient (e.g., g, ml, ea...)
     */
    private String currentUnit;

    /**
     * Date of expiration;When the ingredient expires (for expiration display and reminder function)
     */
    private Date expirationDate;

    /**
     * Location of storage;Where the ingredient stores (e.g., refrigerator, cabinetry)
     */
    private String storageLocation;

    /**
     * Type of category;Redundant field or enumeration (e.g., INGREDIENT or CONDIMENT)
     */
    private String categoryType;


}
