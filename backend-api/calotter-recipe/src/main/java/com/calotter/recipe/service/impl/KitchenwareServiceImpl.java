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
import com.calotter.recipe.domain.bo.KitchenwareBo;
import com.calotter.recipe.domain.vo.KitchenwareVo;
import com.calotter.recipe.domain.Kitchenware;
import com.calotter.recipe.mapper.KitchenwareMapper;
import com.calotter.recipe.service.IKitchenwareService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * rms_kitchenware;Global kitchenware table service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class KitchenwareServiceImpl implements IKitchenwareService {

    private final KitchenwareMapper baseMapper;

    /**
     * Query rms_kitchenware;Global kitchenware table
     *
     * @param id primary key
     * @return rms_kitchenware;Global kitchenware table
     */
    @Override
    public KitchenwareVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query rms_kitchenware;Global kitchenware table list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_kitchenware;Global kitchenware table paged list
     */
    @Override
    public TableDataInfo<KitchenwareVo> queryPageList(KitchenwareBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<Kitchenware> lqw = buildQueryWrapper(bo);
        Page<KitchenwareVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible rms_kitchenware;Global kitchenware table items
     *
     * @param bo query condition
     * @return rms_kitchenware;Global kitchenware table list
     */
    @Override
    public List<KitchenwareVo> queryList(KitchenwareBo bo) {
        LambdaQueryWrapper<Kitchenware> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<Kitchenware> buildQueryWrapper(KitchenwareBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<Kitchenware> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(Kitchenware::getId);
        lqw.like(StringUtils.isNotBlank(bo.getName()), Kitchenware::getName, bo.getName());
        lqw.eq(StringUtils.isNotBlank(bo.getDescription()), Kitchenware::getDescription, bo.getDescription());
        lqw.eq(StringUtils.isNotBlank(bo.getImageUrl()), Kitchenware::getImageUrl, bo.getImageUrl());
        lqw.eq(StringUtils.isNotBlank(bo.getCategory()), Kitchenware::getCategory, bo.getCategory());
        lqw.eq(bo.getElectronic() != null, Kitchenware::getElectronic, bo.getElectronic());
        lqw.eq(bo.getDefaultShown() != null, Kitchenware::getDefaultShown, bo.getDefaultShown());
        return lqw;
    }

    /**
     * Add rms_kitchenware;Global kitchenware table
     *
     * @param bo rms_kitchenware;Global kitchenware table
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(KitchenwareBo bo) {
        Kitchenware add = MapstructUtils.convert(bo, Kitchenware.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify rms_kitchenware;Global kitchenware table
     *
     * @param bo rms_kitchenware;Global kitchenware table
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(KitchenwareBo bo) {
        Kitchenware update = MapstructUtils.convert(bo, Kitchenware.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(Kitchenware entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete rms_kitchenware;Global kitchenware table information
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
