package com.calotter.user.domain.bo;

import com.calotter.user.domain.Restriction;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * ums_restriction;The global dietary restrictions of dining roles business object ums_restriction
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = Restriction.class, reverseConvertGenerate = false)
public class RestrictionBo extends BaseEntity {

    /**
     * Restriction id;Restriction ID (PK)
     */
    @NotNull(message = "Restriction id;Restriction ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Restriction name;Restriction name
     */
    @NotBlank(message = "Restriction name;Restriction name can not be empty", groups = { AddGroup.class, EditGroup.class })
    private String name;

    /**
     * Restriction description;The description of the restriction
     */
    private String description;

    /**
     * Whether is default shown;Whether the dietary restriction is shown by default
     */
    private Boolean defaultShown;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    private Short sort;


}
