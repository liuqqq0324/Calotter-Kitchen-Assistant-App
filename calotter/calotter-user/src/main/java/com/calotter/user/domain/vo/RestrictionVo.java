package com.calotter.user.domain.vo;

import com.calotter.user.domain.Restriction;
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
 * ums_restriction;The global dietary restrictions of dining roles view object ums_restriction
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = Restriction.class)
public class RestrictionVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Restriction id;Restriction ID (PK)
     */
    @ExcelProperty(value = "Restriction id;Restriction ID (PK)")
    private Long id;

    /**
     * Restriction name;Restriction name
     */
    @ExcelProperty(value = "Restriction name;Restriction name")
    private String name;

    /**
     * Restriction description;The description of the restriction
     */
    @ExcelProperty(value = "Restriction description;The description of the restriction")
    private String description;

    /**
     * Whether is default shown;Whether the dietary restriction is shown by default
     */
    @ExcelProperty(value = "Whether is default shown;Whether the dietary restriction is shown by default")
    private Boolean defaultShown;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    @ExcelProperty(value = "Sort priority;Sort the priority of the display sequence")
    private Short sort;


}
