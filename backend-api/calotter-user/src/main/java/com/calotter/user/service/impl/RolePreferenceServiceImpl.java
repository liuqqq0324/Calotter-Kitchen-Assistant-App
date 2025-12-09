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
import com.calotter.user.domain.bo.RolePreferenceBo;
import com.calotter.user.domain.vo.RolePreferenceVo;
import com.calotter.user.domain.RolePreference;
import com.calotter.user.mapper.RolePreferenceMapper;
import com.calotter.user.service.IRolePreferenceService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ums_role_preference;The dietary preference of specific dining role service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RolePreferenceServiceImpl implements IRolePreferenceService {

    private final RolePreferenceMapper baseMapper;

    /**
     * Query ums_role_preference;The dietary preference of specific dining role
     *
     * @param id primary key
     * @return ums_role_preference;The dietary preference of specific dining role
     */
    @Override
    public RolePreferenceVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ums_role_preference;The dietary preference of specific dining role list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_role_preference;The dietary preference of specific dining role paged list
     */
    @Override
    public TableDataInfo<RolePreferenceVo> queryPageList(RolePreferenceBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<RolePreference> lqw = buildQueryWrapper(bo);
        Page<RolePreferenceVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ums_role_preference;The dietary preference of specific dining role items
     *
     * @param bo query condition
     * @return ums_role_preference;The dietary preference of specific dining role list
     */
    @Override
    public List<RolePreferenceVo> queryList(RolePreferenceBo bo) {
        LambdaQueryWrapper<RolePreference> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<RolePreference> buildQueryWrapper(RolePreferenceBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<RolePreference> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(RolePreference::getId);
        lqw.eq(bo.getRoleId() != null, RolePreference::getRoleId, bo.getRoleId());
        lqw.eq(bo.getPreferenceId() != null, RolePreference::getPreferenceId, bo.getPreferenceId());
        lqw.eq(bo.getLevel() != null, RolePreference::getLevel, bo.getLevel());
        return lqw;
    }

    /**
     * Add ums_role_preference;The dietary preference of specific dining role
     *
     * @param bo ums_role_preference;The dietary preference of specific dining role
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RolePreferenceBo bo) {
        RolePreference add = MapstructUtils.convert(bo, RolePreference.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ums_role_preference;The dietary preference of specific dining role
     *
     * @param bo ums_role_preference;The dietary preference of specific dining role
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RolePreferenceBo bo) {
        RolePreference update = MapstructUtils.convert(bo, RolePreference.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(RolePreference entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ums_role_preference;The dietary preference of specific dining role information
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
