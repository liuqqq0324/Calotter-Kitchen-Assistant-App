package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleCuisine;
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
 * ums_role_cuisine;The association table of dining role and cuisine view object ums_role_cuisine
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = RoleCuisine.class)
public class RoleCuisineVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role cuisine id;Role cuisine ID (PK)
     */
    @ExcelProperty(value = "Role cuisine id;Role cuisine ID (PK)")
    private Long id;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    @ExcelProperty(value = "Role id;Role ID (FK, role_id -> user_role.id)")
    private Long roleId;

    /**
     * Cuisine id;Cuisine ID (FK, cuisine_id -> cuisine_type.id)
     */
    @ExcelProperty(value = "Cuisine id;Cuisine ID (FK, cuisine_id -> cuisine_type.id)")
    private Long cuisineId;

    /**
     * Type of association;Association type: [1-like, 2-dislike]
     */
    @ExcelProperty(value = "Type of association;Association type: [1-like, 2-dislike]")
    private Short type;

    /**
     * Description;Association description (e.g., like to eat Sichuan Dishes for lunch)
     */
    @ExcelProperty(value = "Description;Association description (e.g., like to eat Sichuan Dishes for lunch)")
    private String description;


}
