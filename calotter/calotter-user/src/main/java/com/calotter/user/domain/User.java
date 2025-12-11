package com.calotter.user.domain;

import cn.hutool.core.date.DateTime;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * ums_user;This table is the master user table, storing the basic information of all users. object ums_user
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_user")
public class User extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * User id;User ID (PK)
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * Username;Username (for login function)
     */
    private String username;

    /**
     * User email;Registration email (for login, receiving notifications, and retrieving password)
     */
    private String email;

    /**
     * Encrypted password;The hash value of user password, avoid saving plain text
     */
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
     * User age;User age in years
     */
    private Integer age;

    /**
     * User height;User height in cm
     */
    private Integer height;

    /**
     * User weight;User weight in kg
     */
    private Integer weight;

    /**
     * User gender;User gender (e.g., male, female, other)
     */
    private String gender;

    /**
     * User last login time;Last login time
     */
    private DateTime lastLoginAt;

    /**
     * The status of user account;Account status: [0 - Disable, 1 - Enable]
     */
    private Short status;


}
