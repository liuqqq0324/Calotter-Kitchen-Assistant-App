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

    /**
     * Override BaseEntity fields to exclude audit fields that don't exist in database table.
     * Only create_time and update_time are needed for this personal application.
     * These fields are hidden from MyBatis-Plus by using @TableField(exist = false).
     */
    @TableField(exist = false)
    private Long createDept;

    @TableField(exist = false)
    private Long createBy;

    @TableField(exist = false)
    private Long updateBy;

}
