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
import com.calotter.user.domain.bo.PreferenceBo;
import com.calotter.user.domain.vo.PreferenceVo;
import com.calotter.user.domain.Preference;
import com.calotter.user.mapper.PreferenceMapper;
import com.calotter.user.service.IPreferenceService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ums_preference;The global dietary preference of dining roles service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class PreferenceServiceImpl implements IPreferenceService {

    private final PreferenceMapper baseMapper;

    /**
     * Query ums_preference;The global dietary preference of dining roles
     *
     * @param id primary key
     * @return ums_preference;The global dietary preference of dining roles
     */
    @Override
    public PreferenceVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ums_preference;The global dietary preference of dining roles list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_preference;The global dietary preference of dining roles paged list
     */
    @Override
    public TableDataInfo<PreferenceVo> queryPageList(PreferenceBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<Preference> lqw = buildQueryWrapper(bo);
        Page<PreferenceVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ums_preference;The global dietary preference of dining roles items
     *
     * @param bo query condition
     * @return ums_preference;The global dietary preference of dining roles list
     */
    @Override
    public List<PreferenceVo> queryList(PreferenceBo bo) {
        LambdaQueryWrapper<Preference> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<Preference> buildQueryWrapper(PreferenceBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<Preference> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(Preference::getId);
        lqw.like(StringUtils.isNotBlank(bo.getName()), Preference::getName, bo.getName());
        lqw.eq(StringUtils.isNotBlank(bo.getDescription()), Preference::getDescription, bo.getDescription());
        lqw.eq(bo.getDefaultShown() != null, Preference::getDefaultShown, bo.getDefaultShown());
        lqw.eq(bo.getSort() != null, Preference::getSort, bo.getSort());
        return lqw;
    }

    /**
     * Add ums_preference;The global dietary preference of dining roles
     *
     * @param bo ums_preference;The global dietary preference of dining roles
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(PreferenceBo bo) {
        Preference add = MapstructUtils.convert(bo, Preference.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ums_preference;The global dietary preference of dining roles
     *
     * @param bo ums_preference;The global dietary preference of dining roles
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(PreferenceBo bo) {
        Preference update = MapstructUtils.convert(bo, Preference.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(Preference entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ums_preference;The global dietary preference of dining roles information
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
