package com.calotter.recipe.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * rms_cuisine_type;The cuisine types of recipes object rms_cuisine_type
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rms_cuisine_type")
public class CuisineType extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Cuisine id;Cuisine ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Cuisine name;Cuisine name
     */
    private String name;

    /**
     * Cuisine icon url;Icon URL of the cuisine
     */
    private String iconUrl;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    private Short sort;


}
