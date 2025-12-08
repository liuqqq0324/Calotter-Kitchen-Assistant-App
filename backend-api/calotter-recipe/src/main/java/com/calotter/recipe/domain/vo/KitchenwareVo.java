package com.calotter.recipe.domain.vo;

import java.util.Date;

import cn.hutool.core.date.DateTime;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.calotter.recipe.domain.Kitchenware;
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
 * rms_kitchenware;Global kitchenware table view object rms_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = Kitchenware.class)
public class KitchenwareVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Kitchenware id;Kitchenware ID (PK)
     */
    @ExcelProperty(value = "Kitchenware id;Kitchenware ID (PK)")
    private Long id;

    /**
     * Kitchenware name;Name of the kitchenware
     */
    @ExcelProperty(value = "Kitchenware name;Name of the kitchenware")
    private String name;

    /**
     * Kitchenware description;Description of the kitchenware
     */
    @ExcelProperty(value = "Kitchenware description;Description of the kitchenware")
    private String description;

    /**
     * Kitchenware image url;Image URL of the kitchenware
     */
    @ExcelProperty(value = "Kitchenware image url;Image URL of the kitchenware")
    private String imageUrl;

    /**
     * Kitchenware category;Category of the kitchenware
     */
    @ExcelProperty(value = "Kitchenware category;Category of the kitchenware")
    private String category;

    /**
     * Whether is electronic;Whether the kitchenware is electronic
     */
    @ExcelProperty(value = "Whether is electronic;Whether the kitchenware is electronic")
    private Boolean electronic;

    /**
     * Whether is shown by default;Whether the kitchenware is shown by default
     */
    @ExcelProperty(value = "Whether is shown by default;Whether the kitchenware is shown by default")
    private Boolean defaultShown;


}
