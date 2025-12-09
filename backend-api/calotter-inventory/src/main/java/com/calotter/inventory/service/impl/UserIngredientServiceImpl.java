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
import com.calotter.inventory.domain.bo.UserIngredientBo;
import com.calotter.inventory.domain.vo.UserIngredientVo;
import com.calotter.inventory.domain.UserIngredient;
import com.calotter.inventory.mapper.UserIngredientMapper;
import com.calotter.inventory.service.IUserIngredientService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class UserIngredientServiceImpl implements IUserIngredientService {

    private final UserIngredientMapper baseMapper;

    /**
     * Query ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     *
     * @param id primary key
     * @return ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     */
    @Override
    public UserIngredientVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. paged list
     */
    @Override
    public TableDataInfo<UserIngredientVo> queryPageList(UserIngredientBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<UserIngredient> lqw = buildQueryWrapper(bo);
        Page<UserIngredientVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. items
     *
     * @param bo query condition
     * @return ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. list
     */
    @Override
    public List<UserIngredientVo> queryList(UserIngredientBo bo) {
        LambdaQueryWrapper<UserIngredient> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<UserIngredient> buildQueryWrapper(UserIngredientBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<UserIngredient> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(UserIngredient::getId);
        lqw.eq(bo.getUserId() != null, UserIngredient::getUserId, bo.getUserId());
        lqw.eq(bo.getIngredientId() != null, UserIngredient::getIngredientId, bo.getIngredientId());
        lqw.eq(bo.getQuantity() != null, UserIngredient::getQuantity, bo.getQuantity());
        lqw.eq(StringUtils.isNotBlank(bo.getCurrentUnit()), UserIngredient::getCurrentUnit, bo.getCurrentUnit());
        lqw.eq(bo.getExpirationDate() != null, UserIngredient::getExpirationDate, bo.getExpirationDate());
        lqw.eq(StringUtils.isNotBlank(bo.getStorageLocation()), UserIngredient::getStorageLocation, bo.getStorageLocation());
        lqw.eq(StringUtils.isNotBlank(bo.getCategoryType()), UserIngredient::getCategoryType, bo.getCategoryType());
        return lqw;
    }

    /**
     * Add ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     *
     * @param bo ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(UserIngredientBo bo) {
        UserIngredient add = MapstructUtils.convert(bo, UserIngredient.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     *
     * @param bo ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(UserIngredientBo bo) {
        UserIngredient update = MapstructUtils.convert(bo, UserIngredient.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(UserIngredient entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. information
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
