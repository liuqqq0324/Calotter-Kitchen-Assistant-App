package com.calotter.user.service.impl;

import com.calotter.common.core.utils.MapstructUtils;
import com.calotter.common.core.utils.StringUtils;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.mybatis.core.page.PageQuery;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.calotter.user.domain.bo.UserRoleBo;
import com.calotter.user.domain.vo.UserRoleVo;
import com.calotter.user.domain.UserRole;
import com.calotter.user.mapper.UserRoleMapper;
import com.calotter.user.service.IUserRoleService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class UserRoleServiceImpl implements IUserRoleService {

    private final UserRoleMapper baseMapper;

    /**
     * Query ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     *
     * @param id primary key
     * @return ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     */
    @Override
    public UserRoleVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. paged list
     */
    @Override
    public TableDataInfo<UserRoleVo> queryPageList(UserRoleBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<UserRole> lqw = buildQueryWrapper(bo);
        Page<UserRoleVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. items
     *
     * @param bo query condition
     * @return ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. list
     */
    @Override
    public List<UserRoleVo> queryList(UserRoleBo bo) {
        LambdaQueryWrapper<UserRole> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<UserRole> buildQueryWrapper(UserRoleBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<UserRole> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(UserRole::getId);
        lqw.eq(bo.getUserId() != null, UserRole::getUserId, bo.getUserId());
        lqw.like(StringUtils.isNotBlank(bo.getName()), UserRole::getName, bo.getName());
        lqw.eq(bo.getAccountOwner() != null, UserRole::getAccountOwner, bo.getAccountOwner());
        lqw.eq(bo.getGender() != null, UserRole::getGender, bo.getGender());
        lqw.eq(bo.getBirthdate() != null, UserRole::getBirthdate, bo.getBirthdate());
        return lqw;
    }

    /**
     * Add ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     *
     * @param bo ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(UserRoleBo bo) {
        UserRole add = MapstructUtils.convert(bo, UserRole.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     *
     * @param bo ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(UserRoleBo bo) {
        UserRole update = MapstructUtils.convert(bo, UserRole.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(UserRole entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. information
     *
     * @param ids     primary keys to be deleted
     * @param isValid whether to conduct a validation of effectiveness
     * @return if the delete operation is successful
     */
    @Override
    public Boolean deleteWithValidByIds(Collection<Long> ids, Boolean isValid) {
        if(isValid){
            //TODO Perform certain business validations to determine whether validation is required
        }
        return baseMapper.deleteByIds(ids) > 0;
    }
}
