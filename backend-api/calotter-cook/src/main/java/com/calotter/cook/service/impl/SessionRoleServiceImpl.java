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
import com.calotter.cook.domain.bo.SessionRoleBo;
import com.calotter.cook.domain.vo.SessionRoleVo;
import com.calotter.cook.domain.SessionRole;
import com.calotter.cook.mapper.SessionRoleMapper;
import com.calotter.cook.service.ISessionRoleService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class SessionRoleServiceImpl implements ISessionRoleService {

    private final SessionRoleMapper baseMapper;

    /**
     * Query cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     *
     * @param id primary key
     * @return cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     */
    @Override
    public SessionRoleVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. paged list
     */
    @Override
    public TableDataInfo<SessionRoleVo> queryPageList(SessionRoleBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<SessionRole> lqw = buildQueryWrapper(bo);
        Page<SessionRoleVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. items
     *
     * @param bo query condition
     * @return cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. list
     */
    @Override
    public List<SessionRoleVo> queryList(SessionRoleBo bo) {
        LambdaQueryWrapper<SessionRole> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<SessionRole> buildQueryWrapper(SessionRoleBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<SessionRole> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(SessionRole::getId);
        lqw.eq(bo.getSessionId() != null, SessionRole::getSessionId, bo.getSessionId());
        lqw.eq(bo.getRoleId() != null, SessionRole::getRoleId, bo.getRoleId());
        lqw.eq(bo.getFeedbackScore() != null, SessionRole::getFeedbackScore, bo.getFeedbackScore());
        lqw.eq(StringUtils.isNotBlank(bo.getFeedbackDesc()), SessionRole::getFeedbackDesc, bo.getFeedbackDesc());
        return lqw;
    }

    /**
     * Add cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     *
     * @param bo cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(SessionRoleBo bo) {
        SessionRole add = MapstructUtils.convert(bo, SessionRole.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     *
     * @param bo cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(SessionRoleBo bo) {
        SessionRole update = MapstructUtils.convert(bo, SessionRole.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(SessionRole entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. information
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
