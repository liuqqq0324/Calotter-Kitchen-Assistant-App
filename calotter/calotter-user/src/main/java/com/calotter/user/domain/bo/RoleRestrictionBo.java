package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleRestriction;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * ums_role_restriction;The dietary restrictions of specific dining role business object ums_role_restriction
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = RoleRestriction.class, reverseConvertGenerate = false)
public class RoleRestrictionBo extends BaseEntity {

    /**
     * Role restriction id;Role restriction ID (PK)
     */
    @NotNull(message = "Role restriction id;Role restriction ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Role id;Role id (FK, role_id -> user_role.id)
     */
    @NotNull(message = "Role id;Role id (FK, role_id -> user_role.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long roleId;

    /**
     * Restriction id;Restriction id (FK, restriction_id -> restriction.id)
     */
    @NotNull(message = "Restriction id;Restriction id (FK, restriction_id -> restriction.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long restrictionId;

    /**
     * Restriction type;Restriction type: [1-allergic, 2-taboo]
     */
    private Short type;


}
