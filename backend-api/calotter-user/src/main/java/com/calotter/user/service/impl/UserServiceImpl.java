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
import com.calotter.user.domain.bo.UserBo;
import com.calotter.user.domain.vo.UserVo;
import com.calotter.user.domain.User;
import com.calotter.user.mapper.UserMapper;
import com.calotter.user.service.IUserService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ums_user;This table is the master user table, storing the basic information of all users. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class UserServiceImpl implements IUserService {

    private final UserMapper baseMapper;

    /**
     * Query ums_user;This table is the master user table, storing the basic information of all users.
     *
     * @param id primary key
     * @return ums_user;This table is the master user table, storing the basic information of all users.
     */
    @Override
    public UserVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ums_user;This table is the master user table, storing the basic information of all users. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_user;This table is the master user table, storing the basic information of all users. paged list
     */
    @Override
    public TableDataInfo<UserVo> queryPageList(UserBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<User> lqw = buildQueryWrapper(bo);
        Page<UserVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ums_user;This table is the master user table, storing the basic information of all users. items
     *
     * @param bo query condition
     * @return ums_user;This table is the master user table, storing the basic information of all users. list
     */
    @Override
    public List<UserVo> queryList(UserBo bo) {
        LambdaQueryWrapper<User> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<User> buildQueryWrapper(UserBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<User> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(User::getId);
        lqw.like(StringUtils.isNotBlank(bo.getUsername()), User::getUsername, bo.getUsername());
        lqw.eq(StringUtils.isNotBlank(bo.getEmail()), User::getEmail, bo.getEmail());
        lqw.eq(StringUtils.isNotBlank(bo.getPasswordHash()), User::getPasswordHash, bo.getPasswordHash());
        lqw.like(StringUtils.isNotBlank(bo.getDisplayName()), User::getDisplayName, bo.getDisplayName());
        lqw.eq(StringUtils.isNotBlank(bo.getAvatarUrl()), User::getAvatarUrl, bo.getAvatarUrl());
        lqw.eq(bo.getLastLoginAt() != null, User::getLastLoginAt, bo.getLastLoginAt());
        lqw.eq(bo.getStatus() != null, User::getStatus, bo.getStatus());
        return lqw;
    }

    /**
     * Add ums_user;This table is the master user table, storing the basic information of all users.
     *
     * @param bo ums_user;This table is the master user table, storing the basic information of all users.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(UserBo bo) {
        User add = MapstructUtils.convert(bo, User.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ums_user;This table is the master user table, storing the basic information of all users.
     *
     * @param bo ums_user;This table is the master user table, storing the basic information of all users.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(UserBo bo) {
        User update = MapstructUtils.convert(bo, User.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(User entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ums_user;This table is the master user table, storing the basic information of all users. information
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
