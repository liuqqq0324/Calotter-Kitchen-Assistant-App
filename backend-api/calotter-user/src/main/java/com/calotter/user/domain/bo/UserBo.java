package com.calotter.user.domain.bo;

import cn.hutool.core.date.DateTime;
import com.calotter.user.domain.User;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * ums_user;This table is the master user table, storing the basic information of all users. business object ums_user
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = User.class, reverseConvertGenerate = false)
public class UserBo extends BaseEntity {

    /**
     * User id;User ID (PK)
     */
    @NotNull(message = "User id;User ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Username;Username (for login function)
     */
    @NotBlank(message = "User name;Username (for login function) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private String username;

    /**
     * User email;Registration email (for login, receiving notifications, and retrieving password)
     */
    @NotBlank(message = "User email;Registration email (for login, receiving notifications, and retrieving password) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private String email;

    /**
     * Encrypted password;The hash value of user password, avoid saving plain text
     */
    @NotBlank(message = "Encrypted password;The hash value of user password, avoid saving plain text can not be empty", groups = { AddGroup.class, EditGroup.class })
    private String passwordHash;

    /**
     * Name for display;Display name (e.g., Cooker Allen)
     */
    private String displayName;

    /**
     * URL of avatar;Avatar (optional)
     */
    private String avatarUrl;

    /**
     * User last login time;Last login time
     */
    private DateTime lastLoginAt;

    /**
     * The status of user account;Account status: [0 - Disable, 1 - Enable]
     */
    private Short status;


}
