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
import com.calotter.recipe.domain.bo.RecipeBo;
import com.calotter.recipe.domain.vo.RecipeVo;
import com.calotter.recipe.domain.Recipe;
import com.calotter.recipe.mapper.RecipeMapper;
import com.calotter.recipe.service.IRecipeService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * rms_recipe;Stores all recipes and the corresponding ingredients. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RecipeServiceImpl implements IRecipeService {

    private final RecipeMapper baseMapper;

    /**
     * Query rms_recipe;Stores all recipes and the corresponding ingredients.
     *
     * @param id primary key
     * @return rms_recipe;Stores all recipes and the corresponding ingredients.
     */
    @Override
    public RecipeVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query rms_recipe;Stores all recipes and the corresponding ingredients. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_recipe;Stores all recipes and the corresponding ingredients. paged list
     */
    @Override
    public TableDataInfo<RecipeVo> queryPageList(RecipeBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<Recipe> lqw = buildQueryWrapper(bo);
        Page<RecipeVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible rms_recipe;Stores all recipes and the corresponding ingredients. items
     *
     * @param bo query condition
     * @return rms_recipe;Stores all recipes and the corresponding ingredients. list
     */
    @Override
    public List<RecipeVo> queryList(RecipeBo bo) {
        LambdaQueryWrapper<Recipe> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<Recipe> buildQueryWrapper(RecipeBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<Recipe> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(Recipe::getId);
        lqw.like(StringUtils.isNotBlank(bo.getName()), Recipe::getName, bo.getName());
        lqw.eq(StringUtils.isNotBlank(bo.getDescription()), Recipe::getDescription, bo.getDescription());
        lqw.eq(StringUtils.isNotBlank(bo.getImageUrl()), Recipe::getImageUrl, bo.getImageUrl());
        lqw.eq(StringUtils.isNotBlank(bo.getCuisineType()), Recipe::getCuisineType, bo.getCuisineType());
        lqw.eq(bo.getDifficultyLevel() != null, Recipe::getDifficultyLevel, bo.getDifficultyLevel());
        lqw.eq(bo.getServingSize() != null, Recipe::getServingSize, bo.getServingSize());
        lqw.eq(bo.getPrepTimeMinutes() != null, Recipe::getPrepTimeMinutes, bo.getPrepTimeMinutes());
        lqw.eq(bo.getCookTimeMinutes() != null, Recipe::getCookTimeMinutes, bo.getCookTimeMinutes());
        lqw.eq(bo.getTotalTimeMinutes() != null, Recipe::getTotalTimeMinutes, bo.getTotalTimeMinutes());
        lqw.eq(bo.getCaloriesPerServing() != null, Recipe::getCaloriesPerServing, bo.getCaloriesPerServing());
        return lqw;
    }

    /**
     * Add rms_recipe;Stores all recipes and the corresponding ingredients.
     *
     * @param bo rms_recipe;Stores all recipes and the corresponding ingredients.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RecipeBo bo) {
        Recipe add = MapstructUtils.convert(bo, Recipe.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify rms_recipe;Stores all recipes and the corresponding ingredients.
     *
     * @param bo rms_recipe;Stores all recipes and the corresponding ingredients.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RecipeBo bo) {
        Recipe update = MapstructUtils.convert(bo, Recipe.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(Recipe entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete rms_recipe;Stores all recipes and the corresponding ingredients. information
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
