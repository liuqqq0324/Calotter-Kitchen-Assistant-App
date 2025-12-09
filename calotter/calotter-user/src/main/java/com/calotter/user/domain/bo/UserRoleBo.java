package com.calotter.user.domain.bo;

import com.calotter.user.domain.UserRole;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;
import java.util.Date;

/**
 * ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. Business object ums_user_role
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = UserRole.class, reverseConvertGenerate = false)
public class UserRoleBo extends BaseEntity {

    /**
     * Role id;Role ID (PK)
     */
    @NotNull(message = "Role id;Role ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * User id;User ID (FK, user_id -> user.id)
     */
    @NotNull(message = "User id;User ID (FK, user_id -> user.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long userId;

    /**
     * Role name;Role name (e.g., grandpa, daughter, friend A)
     */
    @NotBlank(message = "Role name;Role name (e.g., grandpa, daughter, friend A) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private String name;

    /**
     * Account owner;Whether this role is the account owner
     */
    private Boolean accountOwner;

    /**
     * Gender;Role gender: [0 - Unknown, 1 - Male, 2 - Female]
     */
    private Short gender;

    /**
     * Birthdate;The birthdate of user role
     */
    private Date birthdate;


}
