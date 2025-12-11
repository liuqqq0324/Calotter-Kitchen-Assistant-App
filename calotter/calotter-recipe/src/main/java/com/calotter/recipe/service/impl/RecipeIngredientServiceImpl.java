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
import com.calotter.recipe.domain.bo.RecipeIngredientBo;
import com.calotter.recipe.domain.vo.RecipeIngredientVo;
import com.calotter.recipe.domain.RecipeIngredient;
import com.calotter.recipe.mapper.RecipeIngredientMapper;
import com.calotter.recipe.service.IRecipeIngredientService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * rms_recipe_ingredient;Store the ingredient compositions of recipes. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RecipeIngredientServiceImpl implements IRecipeIngredientService {

    private final RecipeIngredientMapper baseMapper;

    /**
     * Query rms_recipe_ingredient;Store the ingredient compositions of recipes.
     *
     * @param id primary key
     * @return rms_recipe_ingredient;Store the ingredient compositions of recipes.
     */
    @Override
    public RecipeIngredientVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query rms_recipe_ingredient;Store the ingredient compositions of recipes. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_recipe_ingredient;Store the ingredient compositions of recipes. paged list
     */
    @Override
    public TableDataInfo<RecipeIngredientVo> queryPageList(RecipeIngredientBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<RecipeIngredient> lqw = buildQueryWrapper(bo);
        Page<RecipeIngredientVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible rms_recipe_ingredient;Store the ingredient compositions of recipes. items
     *
     * @param bo query condition
     * @return rms_recipe_ingredient;Store the ingredient compositions of recipes. list
     */
    @Override
    public List<RecipeIngredientVo> queryList(RecipeIngredientBo bo) {
        LambdaQueryWrapper<RecipeIngredient> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<RecipeIngredient> buildQueryWrapper(RecipeIngredientBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<RecipeIngredient> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(RecipeIngredient::getId);
        lqw.eq(bo.getRecipeId() != null, RecipeIngredient::getRecipeId, bo.getRecipeId());
        lqw.eq(bo.getIngredientId() != null, RecipeIngredient::getIngredientId, bo.getIngredientId());
        lqw.eq(bo.getQuantity() != null, RecipeIngredient::getQuantity, bo.getQuantity());
        lqw.eq(StringUtils.isNotBlank(bo.getUnit()), RecipeIngredient::getUnit, bo.getUnit());
        lqw.eq(StringUtils.isNotBlank(bo.getProcessingNote()), RecipeIngredient::getProcessingNote, bo.getProcessingNote());
        lqw.eq(bo.getOptional() != null, RecipeIngredient::getOptional, bo.getOptional());
        lqw.eq(bo.getGarnish() != null, RecipeIngredient::getGarnish, bo.getGarnish());
        lqw.eq(bo.getSort() != null, RecipeIngredient::getSort, bo.getSort());
        return lqw;
    }

    /**
     * Add rms_recipe_ingredient;Store the ingredient compositions of recipes.
     *
     * @param bo rms_recipe_ingredient;Store the ingredient compositions of recipes.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RecipeIngredientBo bo) {
        RecipeIngredient add = MapstructUtils.convert(bo, RecipeIngredient.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify rms_recipe_ingredient;Store the ingredient compositions of recipes.
     *
     * @param bo rms_recipe_ingredient;Store the ingredient compositions of recipes.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RecipeIngredientBo bo) {
        RecipeIngredient update = MapstructUtils.convert(bo, RecipeIngredient.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(RecipeIngredient entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete rms_recipe_ingredient;Store the ingredient compositions of recipes. information
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
