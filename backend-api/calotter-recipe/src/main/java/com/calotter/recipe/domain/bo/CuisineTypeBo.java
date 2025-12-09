package com.calotter.recipe.domain.bo;

import com.calotter.recipe.domain.CuisineType;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * rms_cuisine_type;The cuisine types of recipes business object rms_cuisine_type
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = CuisineType.class, reverseConvertGenerate = false)
public class CuisineTypeBo extends BaseEntity {

    /**
     * Cuisine id;Cuisine ID (PK)
     */
    @NotNull(message = "Cuisine id;Cuisine ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Cuisine name;Cuisine name
     */
    @NotBlank(message = "Cuisine name;Cuisine name can not be empty", groups = { AddGroup.class, EditGroup.class })
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
