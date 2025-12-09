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
import com.calotter.user.domain.bo.RoleLogBo;
import com.calotter.user.domain.vo.RoleLogVo;
import com.calotter.user.domain.RoleLog;
import com.calotter.user.mapper.RoleLogMapper;
import com.calotter.user.service.IRoleLogService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ums_role_log;Stores body metrics of user roles. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RoleLogServiceImpl implements IRoleLogService {

    private final RoleLogMapper baseMapper;

    /**
     * Query ums_role_log;Stores body metrics of user roles.
     *
     * @param id primary key
     * @return ums_role_log;Stores body metrics of user roles.
     */
    @Override
    public RoleLogVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ums_role_log;Stores body metrics of user roles. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_role_log;Stores body metrics of user roles. paged list
     */
    @Override
    public TableDataInfo<RoleLogVo> queryPageList(RoleLogBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<RoleLog> lqw = buildQueryWrapper(bo);
        Page<RoleLogVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ums_role_log;Stores body metrics of user roles. items
     *
     * @param bo query condition
     * @return ums_role_log;Stores body metrics of user roles. list
     */
    @Override
    public List<RoleLogVo> queryList(RoleLogBo bo) {
        LambdaQueryWrapper<RoleLog> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<RoleLog> buildQueryWrapper(RoleLogBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<RoleLog> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(RoleLog::getId);
        lqw.eq(bo.getRoleId() != null, RoleLog::getRoleId, bo.getRoleId());
        lqw.eq(bo.getRecordAt() != null, RoleLog::getRecordAt, bo.getRecordAt());
        lqw.eq(bo.getWeightKg() != null, RoleLog::getWeightKg, bo.getWeightKg());
        lqw.eq(bo.getHeightCm() != null, RoleLog::getHeightCm, bo.getHeightCm());
        lqw.eq(StringUtils.isNotBlank(bo.getNotes()), RoleLog::getNotes, bo.getNotes());
        return lqw;
    }

    /**
     * Add ums_role_log;Stores body metrics of user roles.
     *
     * @param bo ums_role_log;Stores body metrics of user roles.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RoleLogBo bo) {
        RoleLog add = MapstructUtils.convert(bo, RoleLog.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ums_role_log;Stores body metrics of user roles.
     *
     * @param bo ums_role_log;Stores body metrics of user roles.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RoleLogBo bo) {
        RoleLog update = MapstructUtils.convert(bo, RoleLog.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(RoleLog entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ums_role_log;Stores body metrics of user roles. information
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
