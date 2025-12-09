package com.calotter.user.domain.bo;

import com.calotter.user.domain.RolePreference;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * ums_role_preference;The dietary preference of specific dining role business object ums_role_preference
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = RolePreference.class, reverseConvertGenerate = false)
public class RolePreferenceBo extends BaseEntity {

    /**
     * Role preference id;Role preference ID (PK)
     */
    @NotNull(message = "Role preference id;Role preference ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Role id;Role id (FK, role_id -> user_role.id)
     */
    @NotNull(message = "Role id;Role id (FK, role_id -> user_role.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long roleId;

    /**
     * Preference id;Preference id (FK, preference_id -> preference.id)
     */
    @NotNull(message = "Preference id;Preference id (FK, preference_id -> preference.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long preferenceId;

    /**
     * Preference level;Preference level: [1-like, 2-favorite]
     */
    private Short level;


}
