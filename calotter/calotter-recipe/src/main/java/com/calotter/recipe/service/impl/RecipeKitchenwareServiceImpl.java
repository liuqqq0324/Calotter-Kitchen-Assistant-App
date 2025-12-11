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
import com.calotter.recipe.domain.bo.RecipeKitchenwareBo;
import com.calotter.recipe.domain.vo.RecipeKitchenwareVo;
import com.calotter.recipe.domain.RecipeKitchenware;
import com.calotter.recipe.mapper.RecipeKitchenwareMapper;
import com.calotter.recipe.service.IRecipeKitchenwareService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RecipeKitchenwareServiceImpl implements IRecipeKitchenwareService {

    private final RecipeKitchenwareMapper baseMapper;

    /**
     * Query rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     *
     * @param id primary key
     * @return rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     */
    @Override
    public RecipeKitchenwareVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. paged list
     */
    @Override
    public TableDataInfo<RecipeKitchenwareVo> queryPageList(RecipeKitchenwareBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<RecipeKitchenware> lqw = buildQueryWrapper(bo);
        Page<RecipeKitchenwareVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. items
     *
     * @param bo query condition
     * @return rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. list
     */
    @Override
    public List<RecipeKitchenwareVo> queryList(RecipeKitchenwareBo bo) {
        LambdaQueryWrapper<RecipeKitchenware> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<RecipeKitchenware> buildQueryWrapper(RecipeKitchenwareBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<RecipeKitchenware> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(RecipeKitchenware::getId);
        lqw.eq(bo.getRecipeId() != null, RecipeKitchenware::getRecipeId, bo.getRecipeId());
        lqw.eq(bo.getKitchenwareId() != null, RecipeKitchenware::getKitchenwareId, bo.getKitchenwareId());
        lqw.eq(StringUtils.isNotBlank(bo.getNote()), RecipeKitchenware::getNote, bo.getNote());
        return lqw;
    }

    /**
     * Add rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     *
     * @param bo rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RecipeKitchenwareBo bo) {
        RecipeKitchenware add = MapstructUtils.convert(bo, RecipeKitchenware.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     *
     * @param bo rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RecipeKitchenwareBo bo) {
        RecipeKitchenware update = MapstructUtils.convert(bo, RecipeKitchenware.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(RecipeKitchenware entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. information
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
