package com.calotter.homepage.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * User entity for querying user information from sous_chef_ums.ums_user
 * 用于从用户表查询用户信息的实体类
 *
 * @author Auto Generated
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName(value = "ums_user", schema = "sous_chef_ums")
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
     * User email;Registration email
     */
    private String email;

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
}
