package com.calotter.user.domain.vo;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.calotter.user.domain.UserRole;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import com.calotter.common.excel.annotation.ExcelDictFormat;
import com.calotter.common.excel.convert.ExcelDictConvert;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;



/**
 * ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. view object ums_user_role
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = UserRole.class)
public class UserRoleVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role id;Role ID (PK)
     */
    @ExcelProperty(value = "Role id;Role ID (PK)")
    private Long id;

    /**
     * User id;User ID (FK, user_id -> user.id)
     */
    @ExcelProperty(value = "User id;User ID (FK, user_id -> user.id)")
    private Long userId;

    /**
     * Role name;Role name (e.g., grandpa, daughter, friend A)
     */
    @ExcelProperty(value = "Role name;Role name (e.g., grandpa, daughter, friend A)")
    private String name;

    /**
     * Account owner;Whether this role is the account owner
     */
    @ExcelProperty(value = "Account owner;Whether this role is the account owner")
    private Boolean accountOwner;

    /**
     * Gender;Role gender: [0 - Unknown, 1 - Male, 2 - Female]
     */
    @ExcelProperty(value = "Gender;Role gender: [0 - Unknown, 1 - Male, 2 - Female]")
    private Short gender;

    /**
     * Birthdate;The birthdate of user role
     */
    @ExcelProperty(value = "Birthdate;The birthdate of user role")
    private Date birthdate;


}
