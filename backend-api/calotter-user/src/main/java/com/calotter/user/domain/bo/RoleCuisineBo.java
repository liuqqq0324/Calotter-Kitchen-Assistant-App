package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleCuisine;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * ums_role_cuisine;The association table of dining role and cuisine business object ums_role_cuisine
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = RoleCuisine.class, reverseConvertGenerate = false)
public class RoleCuisineBo extends BaseEntity {

    /**
     * Role cuisine id;Role cuisine ID (PK)
     */
    @NotNull(message = "Role cuisine id;Role cuisine ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    @NotNull(message = "Role id;Role ID (FK, role_id -> user_role.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long roleId;

    /**
     * Cuisine id;Cuisine ID (FK, cuisine_id -> cuisine_type.id)
     */
    @NotNull(message = "Cuisine id;Cuisine ID (FK, cuisine_id -> cuisine_type.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long cuisineId;

    /**
     * Type of association;Association type: [1-like, 2-dislike]
     */
    @NotNull(message = "Type of association;Association type: [1-like, 2-dislike] can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Short type;

    /**
     * Description;Association description (e.g., like to eat Sichuan Dishes for lunch)
     */
    private String description;


}
