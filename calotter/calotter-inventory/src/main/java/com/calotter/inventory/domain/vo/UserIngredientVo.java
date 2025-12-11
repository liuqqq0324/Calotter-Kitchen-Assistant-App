package com.calotter.inventory.domain.vo;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.calotter.inventory.domain.UserIngredient;
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
 * ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. view object ims_user_ingredient
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = UserIngredient.class)
public class UserIngredientVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Pantry id;Pantry ID (PK)
     */
    @ExcelProperty(value = "Pantry id;Pantry ID (PK)")
    private Long id;

    /**
     * User id;Whose pantry (FK, user_id -> user.id)
     */
    @ExcelProperty(value = "User id;Whose pantry (FK, user_id -> user.id)")
    private Long userId;

    /**
     * Ingredient id;The associated ingredient (FK, ingredient_id -> ingredient.id)
     */
    @ExcelProperty(value = "Ingredient id;The associated ingredient (FK, ingredient_id -> ingredient.id)")
    private Long ingredientId;

    /**
     * Quantity;Quantity of the ingredient
     */
    @ExcelProperty(value = "Quantity;Quantity of the ingredient")
    private Double quantity;

    /**
     * Current unit;Current unit of the ingredient (e.g., g, ml, ea...)
     */
    @ExcelProperty(value = "Current unit;Current unit of the ingredient (e.g., g, ml, ea...)")
    private String currentUnit;

    /**
     * Date of expiration;When the ingredient expires (for expiration display and reminder function)
     */
    @ExcelProperty(value = "Date of expiration;When the ingredient expires (for expiration display and reminder function)")
    private Date expirationDate;

    /**
     * Location of storage;Where the ingredient stores (e.g., refrigerator, cabinetry)
     */
    @ExcelProperty(value = "Location of storage;Where the ingredient stores (e.g., refrigerator, cabinetry)")
    private String storageLocation;

    /**
     * Type of category;Redundant field or enumeration (e.g., INGREDIENT or CONDIMENT)
     */
    @ExcelProperty(value = "Type of category;Redundant field or enumeration (e.g., INGREDIENT or CONDIMENT)")
    private String categoryType;


}
