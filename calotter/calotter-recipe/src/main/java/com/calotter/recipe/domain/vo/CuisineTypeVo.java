package com.calotter.recipe.domain.vo;

import com.calotter.recipe.domain.CuisineType;
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
 * rms_cuisine_type;The cuisine types of recipes view object rms_cuisine_type
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = CuisineType.class)
public class CuisineTypeVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Cuisine id;Cuisine ID (PK)
     */
    @ExcelProperty(value = "Cuisine id;Cuisine ID (PK)")
    private Long id;

    /**
     * Cuisine name;Cuisine name
     */
    @ExcelProperty(value = "Cuisine name;Cuisine name")
    private String name;

    /**
     * Cuisine icon url;Icon URL of the cuisine
     */
    @ExcelProperty(value = "Cuisine icon url;Icon URL of the cuisine")
    private String iconUrl;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    @ExcelProperty(value = "Sort priority;Sort the priority of the display sequence")
    private Short sort;


}
