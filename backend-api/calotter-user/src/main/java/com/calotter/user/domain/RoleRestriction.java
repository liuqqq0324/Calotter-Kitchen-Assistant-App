package com.calotter.user.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * ums_role_restriction;The dietary restrictions of specific dining role object ums_role_restriction
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_role_restriction")
public class RoleRestriction extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role restriction id;Role restriction ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Role id;Role id (FK, role_id -> user_role.id)
     */
    private Long roleId;

    /**
     * Restriction id;Restriction id (FK, restriction_id -> restriction.id)
     */
    private Long restrictionId;

    /**
     * Restriction type;Restriction type: [1-allergic, 2-taboo]
     */
    private Short type;


}
