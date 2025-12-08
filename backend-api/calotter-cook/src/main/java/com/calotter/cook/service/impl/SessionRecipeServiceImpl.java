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
import com.calotter.cook.domain.bo.SessionRecipeBo;
import com.calotter.cook.domain.vo.SessionRecipeVo;
import com.calotter.cook.domain.SessionRecipe;
import com.calotter.cook.mapper.SessionRecipeMapper;
import com.calotter.cook.service.ISessionRecipeService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class SessionRecipeServiceImpl implements ISessionRecipeService {

    private final SessionRecipeMapper baseMapper;

    /**
     * Query cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     *
     * @param id primary key
     * @return cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     */
    @Override
    public SessionRecipeVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. paged list
     */
    @Override
    public TableDataInfo<SessionRecipeVo> queryPageList(SessionRecipeBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<SessionRecipe> lqw = buildQueryWrapper(bo);
        Page<SessionRecipeVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. items
     *
     * @param bo query condition
     * @return cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. list
     */
    @Override
    public List<SessionRecipeVo> queryList(SessionRecipeBo bo) {
        LambdaQueryWrapper<SessionRecipe> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<SessionRecipe> buildQueryWrapper(SessionRecipeBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<SessionRecipe> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(SessionRecipe::getId);
        lqw.eq(bo.getSessionId() != null, SessionRecipe::getSessionId, bo.getSessionId());
        lqw.eq(bo.getRecipeId() != null, SessionRecipe::getRecipeId, bo.getRecipeId());
        lqw.eq(bo.getServings() != null, SessionRecipe::getServings, bo.getServings());
        lqw.eq(bo.getActualDurationMinutes() != null, SessionRecipe::getActualDurationMinutes, bo.getActualDurationMinutes());
        lqw.eq(bo.getSuccessRating() != null, SessionRecipe::getSuccessRating, bo.getSuccessRating());
        return lqw;
    }

    /**
     * Add cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     *
     * @param bo cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(SessionRecipeBo bo) {
        SessionRecipe add = MapstructUtils.convert(bo, SessionRecipe.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     *
     * @param bo cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(SessionRecipeBo bo) {
        SessionRecipe update = MapstructUtils.convert(bo, SessionRecipe.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(SessionRecipe entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. information
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
