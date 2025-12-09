package com.calotter.user.domain.vo;

import com.calotter.user.domain.Preference;
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
 * ums_preference;The global dietary preference of dining roles view object ums_preference
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = Preference.class)
public class PreferenceVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Preference id;Preference ID (PK)
     */
    @ExcelProperty(value = "Preference id;Preference ID (PK)")
    private Long id;

    /**
     * Preference name;Preference name
     */
    @ExcelProperty(value = "Preference name;Preference name")
    private String name;

    /**
     * Preference description;Preference description
     */
    @ExcelProperty(value = "Preference description;Preference description")
    private String description;

    /**
     * Whether is shown by default;Whether the Preference is shown by default
     */
    @ExcelProperty(value = "Whether is shown by default;Whether the Preference is shown by default")
    private Boolean defaultShown;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    @ExcelProperty(value = "Sort priority;Sort the priority of the display sequence")
    private Short sort;


}
