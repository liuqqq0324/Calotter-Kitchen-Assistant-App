package com.calotter.recipe.service.impl;

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
import com.calotter.recipe.domain.bo.IngredientBo;
import com.calotter.recipe.domain.vo.IngredientVo;
import com.calotter.recipe.domain.Ingredient;
import com.calotter.recipe.mapper.IngredientMapper;
import com.calotter.recipe.service.IIngredientService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * rms_ingredient;Stores all ingredients could be used in a recipe. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class IngredientServiceImpl implements IIngredientService {

    private final IngredientMapper baseMapper;

    /**
     * Query rms_ingredient;Stores all ingredients could be used in a recipe.
     *
     * @param id primary key
     * @return rms_ingredient;Stores all ingredients could be used in a recipe.
     */
    @Override
    public IngredientVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query rms_ingredient;Stores all ingredients could be used in a recipe. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_ingredient;Stores all ingredients could be used in a recipe. paged list
     */
    @Override
    public TableDataInfo<IngredientVo> queryPageList(IngredientBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<Ingredient> lqw = buildQueryWrapper(bo);
        Page<IngredientVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible rms_ingredient;Stores all ingredients could be used in a recipe. items
     *
     * @param bo query condition
     * @return rms_ingredient;Stores all ingredients could be used in a recipe. list
     */
    @Override
    public List<IngredientVo> queryList(IngredientBo bo) {
        LambdaQueryWrapper<Ingredient> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<Ingredient> buildQueryWrapper(IngredientBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<Ingredient> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(Ingredient::getId);
        lqw.like(StringUtils.isNotBlank(bo.getName()), Ingredient::getName, bo.getName());
        lqw.eq(StringUtils.isNotBlank(bo.getCategory()), Ingredient::getCategory, bo.getCategory());
        lqw.eq(StringUtils.isNotBlank(bo.getStandardUnit()), Ingredient::getStandardUnit, bo.getStandardUnit());
        lqw.eq(StringUtils.isNotBlank(bo.getStorageAdvice()), Ingredient::getStorageAdvice, bo.getStorageAdvice());
        lqw.eq(StringUtils.isNotBlank(bo.getImageUrl()), Ingredient::getImageUrl, bo.getImageUrl());
        return lqw;
    }

    /**
     * Add rms_ingredient;Stores all ingredients could be used in a recipe.
     *
     * @param bo rms_ingredient;Stores all ingredients could be used in a recipe.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(IngredientBo bo) {
        Ingredient add = MapstructUtils.convert(bo, Ingredient.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify rms_ingredient;Stores all ingredients could be used in a recipe.
     *
     * @param bo rms_ingredient;Stores all ingredients could be used in a recipe.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(IngredientBo bo) {
        Ingredient update = MapstructUtils.convert(bo, Ingredient.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(Ingredient entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete rms_ingredient;Stores all ingredients could be used in a recipe. information
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
