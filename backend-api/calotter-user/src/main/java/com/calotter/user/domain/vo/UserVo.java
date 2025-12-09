package com.calotter.user.domain.vo;

import java.util.Date;

import cn.hutool.core.date.DateTime;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.calotter.user.domain.User;
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
 * ums_user;This table is the master user table, storing the basic information of all users. view object ums_user
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = User.class)
public class UserVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * User id;User ID (PK)
     */
    @ExcelProperty(value = "User id;User ID (PK)")
    private Long id;

    /**
     * User name;Username (for login function)
     */
    @ExcelProperty(value = "User name;Username (for login function)")
    private String username;

    /**
     * User email;Registration email (for login, receiving notifications, and retrieving password)
     */
    @ExcelProperty(value = "User email;Registration email (for login, receiving notifications, and retrieving password)")
    private String email;

    /**
     * Encrypted password;The hash value of user password, avoid saving plain text
     */
    @ExcelProperty(value = "Encrypted password;The hash value of user password, avoid saving plain text")
    private String passwordHash;

    /**
     * Name for display;Display name (e.g., Cooker Allen)
     */
    @ExcelProperty(value = "Name for display;Display name (e.g., Cooker Allen)")
    private String displayName;

    /**
     * URL of avatar;Avatar (optional)
     */
    @ExcelProperty(value = "URL of avatar;Avatar (optional)")
    private String avatarUrl;

    /**
     * User last login time;Last login time
     */
    @ExcelProperty(value = "User last login time;Last login time")
    private DateTime lastLoginAt;

    /**
     * The status of user account;Account status: [0 - Disable, 1 - Enable]
     */
    @ExcelProperty(value = "The status of user account;Account status: [0 - Disable, 1 - Enable]")
    private Short status;


}
