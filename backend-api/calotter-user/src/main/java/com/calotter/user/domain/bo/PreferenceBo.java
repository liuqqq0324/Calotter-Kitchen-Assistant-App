package com.calotter.user.domain.bo;

import com.calotter.user.domain.Preference;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * ums_preference;The global dietary preference of dining roles business object ums_preference
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = Preference.class, reverseConvertGenerate = false)
public class PreferenceBo extends BaseEntity {

    /**
     * Preference id;Preference ID (PK)
     */
    @NotNull(message = "Preference id;Preference ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Preference name;Preference name
     */
    @NotBlank(message = "Preference name;Preference name can not be empty", groups = { AddGroup.class, EditGroup.class })
    private String name;

    /**
     * Preference description;Preference description
     */
    private String description;

    /**
     * Whether is shown by default;Whether the Preference is shown by default
     */
    private Boolean defaultShown;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    private Short sort;


}
