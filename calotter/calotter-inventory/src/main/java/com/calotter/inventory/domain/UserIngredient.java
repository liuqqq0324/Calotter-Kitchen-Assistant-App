package com.calotter.inventory.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.io.Serial;

/**
 * ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. object ims_user_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ims_user_ingredient")
public class UserIngredient extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Pantry id;Pantry ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * User id;Whose pantry (FK, user_id -> user.id)
     */
    private Long userId;

    /**
     * Ingredient id;The associated ingredient (FK, ingredient_id -> ingredient.id)
     */
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
