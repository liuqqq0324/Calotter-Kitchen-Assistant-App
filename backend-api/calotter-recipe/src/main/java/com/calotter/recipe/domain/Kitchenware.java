package com.calotter.recipe.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * rms_kitchenware;Global kitchenware table object rms_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("rms_kitchenware")
public class Kitchenware extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Kitchenware id;Kitchenware ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Kitchenware name;Name of the kitchenware
     */
    private String name;

    /**
     * Kitchenware description;Description of the kitchenware
     */
    private String description;

    /**
     * Kitchenware image url;Image URL of the kitchenware
     */
    private String imageUrl;

    /**
     * Kitchenware category;Category of the kitchenware
     */
    private String category;

    /**
     * Whether is electronic;Whether the kitchenware is electronic
     */
    private Boolean electronic;

    /**
     * Whether is shown by default;Whether the kitchenware is shown by default
     */
    private Boolean defaultShown;


}
