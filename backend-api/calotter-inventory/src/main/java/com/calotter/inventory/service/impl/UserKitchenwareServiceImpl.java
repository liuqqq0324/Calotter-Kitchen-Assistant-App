package com.calotter.inventory.service.impl;

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
import com.calotter.inventory.domain.bo.UserKitchenwareBo;
import com.calotter.inventory.domain.vo.UserKitchenwareVo;
import com.calotter.inventory.domain.UserKitchenware;
import com.calotter.inventory.mapper.UserKitchenwareMapper;
import com.calotter.inventory.service.IUserKitchenwareService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class UserKitchenwareServiceImpl implements IUserKitchenwareService {

    private final UserKitchenwareMapper baseMapper;

    /**
     * Query ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     *
     * @param id primary key
     * @return ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     */
    @Override
    public UserKitchenwareVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. paged list
     */
    @Override
    public TableDataInfo<UserKitchenwareVo> queryPageList(UserKitchenwareBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<UserKitchenware> lqw = buildQueryWrapper(bo);
        Page<UserKitchenwareVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. items
     *
     * @param bo query condition
     * @return ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. list
     */
    @Override
    public List<UserKitchenwareVo> queryList(UserKitchenwareBo bo) {
        LambdaQueryWrapper<UserKitchenware> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<UserKitchenware> buildQueryWrapper(UserKitchenwareBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<UserKitchenware> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(UserKitchenware::getId);
        lqw.eq(bo.getUserId() != null, UserKitchenware::getUserId, bo.getUserId());
        lqw.eq(bo.getKitchenwareId() != null, UserKitchenware::getKitchenwareId, bo.getKitchenwareId());
        lqw.like(StringUtils.isNotBlank(bo.getNickname()), UserKitchenware::getNickname, bo.getNickname());
        lqw.eq(StringUtils.isNotBlank(bo.getPurchaseDate()), UserKitchenware::getPurchaseDate, bo.getPurchaseDate());
        lqw.eq(StringUtils.isNotBlank(bo.getConditionStatus()), UserKitchenware::getConditionStatus, bo.getConditionStatus());
        return lqw;
    }

    /**
     * Add ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     *
     * @param bo ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(UserKitchenwareBo bo) {
        UserKitchenware add = MapstructUtils.convert(bo, UserKitchenware.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     *
     * @param bo ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(UserKitchenwareBo bo) {
        UserKitchenware update = MapstructUtils.convert(bo, UserKitchenware.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(UserKitchenware entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. information
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
