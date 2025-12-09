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
import com.calotter.user.domain.bo.RoleCuisineBo;
import com.calotter.user.domain.vo.RoleCuisineVo;
import com.calotter.user.domain.RoleCuisine;
import com.calotter.user.mapper.RoleCuisineMapper;
import com.calotter.user.service.IRoleCuisineService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * ums_role_cuisine;The association table of dining role and cuisine service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class RoleCuisineServiceImpl implements IRoleCuisineService {

    private final RoleCuisineMapper baseMapper;

    /**
     * Query ums_role_cuisine;The association table of dining role and cuisine
     *
     * @param id primary key
     * @return ums_role_cuisine;The association table of dining role and cuisine
     */
    @Override
    public RoleCuisineVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query ums_role_cuisine;The association table of dining role and cuisine list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return ums_role_cuisine;The association table of dining role and cuisine paged list
     */
    @Override
    public TableDataInfo<RoleCuisineVo> queryPageList(RoleCuisineBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<RoleCuisine> lqw = buildQueryWrapper(bo);
        Page<RoleCuisineVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible ums_role_cuisine;The association table of dining role and cuisine items
     *
     * @param bo query condition
     * @return ums_role_cuisine;The association table of dining role and cuisine list
     */
    @Override
    public List<RoleCuisineVo> queryList(RoleCuisineBo bo) {
        LambdaQueryWrapper<RoleCuisine> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<RoleCuisine> buildQueryWrapper(RoleCuisineBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<RoleCuisine> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(RoleCuisine::getId);
        lqw.eq(bo.getRoleId() != null, RoleCuisine::getRoleId, bo.getRoleId());
        lqw.eq(bo.getCuisineId() != null, RoleCuisine::getCuisineId, bo.getCuisineId());
        lqw.eq(bo.getType() != null, RoleCuisine::getType, bo.getType());
        lqw.eq(StringUtils.isNotBlank(bo.getDescription()), RoleCuisine::getDescription, bo.getDescription());
        return lqw;
    }

    /**
     * Add ums_role_cuisine;The association table of dining role and cuisine
     *
     * @param bo ums_role_cuisine;The association table of dining role and cuisine
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(RoleCuisineBo bo) {
        RoleCuisine add = MapstructUtils.convert(bo, RoleCuisine.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify ums_role_cuisine;The association table of dining role and cuisine
     *
     * @param bo ums_role_cuisine;The association table of dining role and cuisine
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(RoleCuisineBo bo) {
        RoleCuisine update = MapstructUtils.convert(bo, RoleCuisine.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(RoleCuisine entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete ums_role_cuisine;The association table of dining role and cuisine information
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
