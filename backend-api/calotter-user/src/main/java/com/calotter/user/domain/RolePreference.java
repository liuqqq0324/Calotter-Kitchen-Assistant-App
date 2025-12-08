package com.calotter.user.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * ums_role_preference;The dietary preference of specific dining role object ums_role_preference
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_role_preference")
public class RolePreference extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role preference id;Role preference ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Role id;Role id (FK, role_id -> user_role.id)
     */
    private Long roleId;

    /**
     * Preference id;Preference id (FK, preference_id -> preference.id)
     */
    private Long preferenceId;

    /**
     * Preference level;Preference level: [1-like, 2-favorite]
     */
    private Short level;


}
