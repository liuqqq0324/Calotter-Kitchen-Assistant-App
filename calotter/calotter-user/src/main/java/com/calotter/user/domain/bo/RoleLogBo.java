package com.calotter.user.domain.bo;

import com.calotter.user.domain.RoleLog;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;
import java.util.Date;

/**
 * ums_role_log;Stores body metrics of user roles. business object ums_role_log
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = RoleLog.class, reverseConvertGenerate = false)
public class RoleLogBo extends BaseEntity {

    /**
     * Record id;Record ID (PK)
     */
    @NotNull(message = "Record id;Record ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    @NotNull(message = "Role id;Role ID (FK, role_id -> user_role.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
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
