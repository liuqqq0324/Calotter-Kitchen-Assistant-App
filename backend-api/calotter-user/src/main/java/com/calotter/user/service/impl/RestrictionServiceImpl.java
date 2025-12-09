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
import com.calotter.user.domain.bo.RestrictionBo;
import com.calotter.user.domain.vo.RestrictionVo;
import com.calotter.user.domain.Restriction;
import com.calotter.user.mapper.RestrictionMapper;
import com.calotter.user.service.IRestrictionService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ums_restriction;The global dietary restrictions of dining roles service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RestrictionServiceImpl implements IRestrictionService {

    private final RestrictionMapper baseMapper;

    /**
     * Query ums_restriction;The global dietary restrictions of dining roles
     *
     * @param id primary key
     * @return ums_restriction;The global dietary restrictions of dining roles
     */
    @Override
    public RestrictionVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ums_restriction;The global dietary restrictions of dining roles list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_restriction;The global dietary restrictions of dining roles paged list
     */
    @Override
    public TableDataInfo<RestrictionVo> queryPageList(RestrictionBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<Restriction> lqw = buildQueryWrapper(bo);
        Page<RestrictionVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ums_restriction;The global dietary restrictions of dining roles items
     *
     * @param bo query condition
     * @return ums_restriction;The global dietary restrictions of dining roles list
     */
    @Override
    public List<RestrictionVo> queryList(RestrictionBo bo) {
        LambdaQueryWrapper<Restriction> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<Restriction> buildQueryWrapper(RestrictionBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<Restriction> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(Restriction::getId);
        lqw.like(StringUtils.isNotBlank(bo.getName()), Restriction::getName, bo.getName());
        lqw.eq(StringUtils.isNotBlank(bo.getDescription()), Restriction::getDescription, bo.getDescription());
        lqw.eq(bo.getDefaultShown() != null, Restriction::getDefaultShown, bo.getDefaultShown());
        lqw.eq(bo.getSort() != null, Restriction::getSort, bo.getSort());
        return lqw;
    }

    /**
     * Add ums_restriction;The global dietary restrictions of dining roles
     *
     * @param bo ums_restriction;The global dietary restrictions of dining roles
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RestrictionBo bo) {
        Restriction add = MapstructUtils.convert(bo, Restriction.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ums_restriction;The global dietary restrictions of dining roles
     *
     * @param bo ums_restriction;The global dietary restrictions of dining roles
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RestrictionBo bo) {
        Restriction update = MapstructUtils.convert(bo, Restriction.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(Restriction entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ums_restriction;The global dietary restrictions of dining roles information
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
