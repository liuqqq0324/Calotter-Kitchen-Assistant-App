package com.calotter.user.mapper;

import com.calotter.user.domain.UserRole;
import com.calotter.user.domain.vo.UserRoleVo;
import com.calotter.common.mybatis.core.mapper.BaseMapperPlus;

/**
 * ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. mapper interface
 *
 * @author Ruoyu Ji
 */
public interface UserRoleMapper extends BaseMapperPlus<UserRole, UserRoleVo> {

}
