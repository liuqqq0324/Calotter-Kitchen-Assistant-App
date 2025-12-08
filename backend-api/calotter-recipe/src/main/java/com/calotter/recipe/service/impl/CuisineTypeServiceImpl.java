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
import com.calotter.recipe.domain.bo.CuisineTypeBo;
import com.calotter.recipe.domain.vo.CuisineTypeVo;
import com.calotter.recipe.domain.CuisineType;
import com.calotter.recipe.mapper.CuisineTypeMapper;
import com.calotter.recipe.service.ICuisineTypeService;

import java.util.List;
import java.util.Map;
import java.util.Collection;

/**
 * rms_cuisine_type;The cuisine types of recipes service business layer handling
 *
 * @author Ruoyu Ji
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class CuisineTypeServiceImpl implements ICuisineTypeService {

    private final CuisineTypeMapper baseMapper;

    /**
     * Query rms_cuisine_type;The cuisine types of recipes
     *
     * @param id primary key
     * @return rms_cuisine_type;The cuisine types of recipes
     */
    @Override
    public CuisineTypeVo queryById(Long id){
        return baseMapper.selectVoById(id);
    }

    /**
     * Pagination query rms_cuisine_type;The cuisine types of recipes list
     *
     * @param bo        query condition
     * @param pageQuery pagination parameters
     * @return rms_cuisine_type;The cuisine types of recipes paged list
     */
    @Override
    public TableDataInfo<CuisineTypeVo> queryPageList(CuisineTypeBo bo, PageQuery pageQuery) {
        LambdaQueryWrapper<CuisineType> lqw = buildQueryWrapper(bo);
        Page<CuisineTypeVo> result = baseMapper.selectVoPage(pageQuery.build(), lqw);
        return TableDataInfo.build(result);
    }

    /**
     * Query the list of eligible rms_cuisine_type;The cuisine types of recipes items
     *
     * @param bo query condition
     * @return rms_cuisine_type;The cuisine types of recipes list
     */
    @Override
    public List<CuisineTypeVo> queryList(CuisineTypeBo bo) {
        LambdaQueryWrapper<CuisineType> lqw = buildQueryWrapper(bo);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<CuisineType> buildQueryWrapper(CuisineTypeBo bo) {
        Map<String, Object> params = bo.getParams();
        LambdaQueryWrapper<CuisineType> lqw = Wrappers.lambdaQuery();
        lqw.orderByAsc(CuisineType::getId);
        lqw.like(StringUtils.isNotBlank(bo.getName()), CuisineType::getName, bo.getName());
        lqw.eq(StringUtils.isNotBlank(bo.getIconUrl()), CuisineType::getIconUrl, bo.getIconUrl());
        lqw.eq(bo.getSort() != null, CuisineType::getSort, bo.getSort());
        return lqw;
    }

    /**
     * Add rms_cuisine_type;The cuisine types of recipes
     *
     * @param bo rms_cuisine_type;The cuisine types of recipes
     * @return if the add operation is successful
     */
    @Override
    public Boolean insertByBo(CuisineTypeBo bo) {
        CuisineType add = MapstructUtils.convert(bo, CuisineType.class);
        validEntityBeforeSave(add);
        boolean flag = baseMapper.insert(add) > 0;
        if (flag) {
            bo.setId(add.getId());
        }
        return flag;
    }

    /**
     * Modify rms_cuisine_type;The cuisine types of recipes
     *
     * @param bo rms_cuisine_type;The cuisine types of recipes
     * @return if the modification is successful
     */
    @Override
    public Boolean updateByBo(CuisineTypeBo bo) {
        CuisineType update = MapstructUtils.convert(bo, CuisineType.class);
        validEntityBeforeSave(update);
        return baseMapper.updateById(update) > 0;
    }

    /**
     * Data validation prior to saving
     */
    private void validEntityBeforeSave(CuisineType entity){
        //TODO Perform some data validation, such as unique constraints
    }

    /**
     * Verify and batch delete rms_cuisine_type;The cuisine types of recipes information
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
