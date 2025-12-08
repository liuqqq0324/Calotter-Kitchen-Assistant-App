package com.calotter.recipe.domain.bo;

import cn.hutool.core.date.DateTime;
import com.calotter.recipe.domain.Kitchenware;
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
 * rms_kitchenware;Global kitchenware table business object rms_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = Kitchenware.class, reverseConvertGenerate = false)
public class KitchenwareBo extends BaseEntity {

    /**
     * Kitchenware id;Kitchenware ID (PK)
     */
    @NotNull(message = "Kitchenware id;Kitchenware ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Kitchenware name;Name of the kitchenware
     */
    @NotBlank(message = "Kitchenware name;Name of the kitchenware can not be empty", groups = { AddGroup.class, EditGroup.class })
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
