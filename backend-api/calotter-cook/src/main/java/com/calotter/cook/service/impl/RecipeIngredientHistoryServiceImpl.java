package com.calotter.cook.service.impl;

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
import com.calotter.cook.domain.bo.RecipeIngredientHistoryBo;
import com.calotter.cook.domain.vo.RecipeIngredientHistoryVo;
import com.calotter.cook.domain.RecipeIngredientHistory;
import com.calotter.cook.mapper.RecipeIngredientHistoryMapper;
import com.calotter.cook.service.IRecipeIngredientHistoryService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RecipeIngredientHistoryServiceImpl implements IRecipeIngredientHistoryService {

    private final RecipeIngredientHistoryMapper baseMapper;

    /**
     * Query cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     *
     * @param id primary key
     * @return cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     */
    @Override
    public RecipeIngredientHistoryVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. paged list
     */
    @Override
    public TableDataInfo<RecipeIngredientHistoryVo> queryPageList(RecipeIngredientHistoryBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<RecipeIngredientHistory> lqw = buildQueryWrapper(bo);
        Page<RecipeIngredientHistoryVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. items
     *
     * @param bo query condition
     * @return cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. list
     */
    @Override
    public List<RecipeIngredientHistoryVo> queryList(RecipeIngredientHistoryBo bo) {
        LambdaQueryWrapper<RecipeIngredientHistory> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<RecipeIngredientHistory> buildQueryWrapper(RecipeIngredientHistoryBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<RecipeIngredientHistory> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(RecipeIngredientHistory::getId);
        lqw.eq(bo.getRecipeId() != null, RecipeIngredientHistory::getRecipeId, bo.getRecipeId());
        lqw.eq(bo.getIngredientId() != null, RecipeIngredientHistory::getIngredientId, bo.getIngredientId());
        lqw.eq(bo.getQuantityUsed() != null, RecipeIngredientHistory::getQuantityUsed, bo.getQuantityUsed());
        lqw.eq(StringUtils.isNotBlank(bo.getUnit()), RecipeIngredientHistory::getUnit, bo.getUnit());
        lqw.eq(bo.getSubstitution() != null, RecipeIngredientHistory::getSubstitution, bo.getSubstitution());
        return lqw;
    }

    /**
     * Add cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     *
     * @param bo cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RecipeIngredientHistoryBo bo) {
        RecipeIngredientHistory add = MapstructUtils.convert(bo, RecipeIngredientHistory.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     *
     * @param bo cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RecipeIngredientHistoryBo bo) {
        RecipeIngredientHistory update = MapstructUtils.convert(bo, RecipeIngredientHistory.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(RecipeIngredientHistory entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. information
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
