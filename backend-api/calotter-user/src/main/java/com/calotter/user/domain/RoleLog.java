package com.calotter.user.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.util.Date;

import java.io.Serial;

/**
 * ums_role_log;Stores body metrics of user roles. object ums_role_log
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_role_log")
public class RoleLog extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Record id;Record ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    private Long roleId;

    /**
     * Creation date;The creation date of this record
     */
    private Date recordAt;

    /**
     * Role weight;The weight of the role (unit: kg)
     */
    private Double weightKg;

    /**
     * Role height;The height of the role (unit: cm)
     */
    private Short heightCm;

    /**
     * Note;Note of the record (e.g., on an empty stomach or after dinner)
     */
    private String notes;


}
