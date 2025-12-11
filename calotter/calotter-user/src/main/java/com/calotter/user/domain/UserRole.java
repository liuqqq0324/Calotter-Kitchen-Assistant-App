package com.calotter.user.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.util.Date;

import java.io.Serial;

/**
 * ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. object ums_user_role
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_user_role")
public class UserRole extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role id;Role ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * User id;User ID (FK, user_id -> user.id)
     */
    private Long userId;

    /**
     * Role name;Role name (e.g., grandpa, daughter, friend A)
     */
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
