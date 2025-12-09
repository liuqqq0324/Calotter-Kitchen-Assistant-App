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
import com.calotter.cook.domain.bo.SessionBo;
import com.calotter.cook.domain.vo.SessionVo;
import com.calotter.cook.domain.Session;
import com.calotter.cook.mapper.SessionMapper;
import com.calotter.cook.service.ISessionService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class SessionServiceImpl implements ISessionService {

    private final SessionMapper baseMapper;

    /**
     * Query cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     *
     * @param id primary key
     * @return cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     */
    @Override
    public SessionVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. paged list
     */
    @Override
    public TableDataInfo<SessionVo> queryPageList(SessionBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<Session> lqw = buildQueryWrapper(bo);
        Page<SessionVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. items
     *
     * @param bo query condition
     * @return cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. list
     */
    @Override
    public List<SessionVo> queryList(SessionBo bo) {
        LambdaQueryWrapper<Session> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<Session> buildQueryWrapper(SessionBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<Session> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(Session::getId);
        lqw.eq(bo.getUserId() != null, Session::getUserId, bo.getUserId());
        lqw.eq(bo.getStartTime() != null, Session::getStartTime, bo.getStartTime());
        lqw.eq(bo.getEndTime() != null, Session::getEndTime, bo.getEndTime());
        lqw.eq(bo.getMealType() != null, Session::getMealType, bo.getMealType());
        lqw.eq(StringUtils.isNotBlank(bo.getNote()), Session::getNote, bo.getNote());
        return lqw;
    }

    /**
     * Add cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     *
     * @param bo cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(SessionBo bo) {
        Session add = MapstructUtils.convert(bo, Session.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     *
     * @param bo cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(SessionBo bo) {
        Session update = MapstructUtils.convert(bo, Session.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(Session entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. information
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
