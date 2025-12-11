package com.calotter.recipe.controller;

import java.util.List;

import lombok.RequiredArgsConstructor;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.*;
import cn.dev33.satoken.annotation.SaCheckPermission;
import org.springframework.web.bind.annotation.*;
import org.springframework.validation.annotation.Validated;
import com.calotter.common.idempotent.annotation.RepeatSubmit;
import com.calotter.common.log.annotation.Log;
import com.calotter.common.web.core.BaseController;
import com.calotter.common.mybatis.core.page.PageQuery;
import com.calotter.common.core.domain.R;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import com.calotter.common.log.enums.BusinessType;
import com.calotter.common.excel.utils.ExcelUtil;
import com.calotter.recipe.domain.vo.CuisineTypeVo;
import com.calotter.recipe.domain.bo.CuisineTypeBo;
import com.calotter.recipe.service.ICuisineTypeService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * rms_cuisine_type;The cuisine types of recipes
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/recipe/cuisineType")
public class CuisineTypeController extends BaseController {

    private final ICuisineTypeService cuisineTypeService;

    /**
     * Query rms_cuisine_type;The cuisine types of recipes list
     */
    // @SaCheckPermission("recipe:cuisineType:list")
    @GetMapping("/list")
    public TableDataInfo<CuisineTypeVo> list(CuisineTypeBo bo, PageQuery pageQuery) {
        return cuisineTypeService.queryPageList(bo, pageQuery);
    }

    /**
     * Export rms_cuisine_type;The cuisine types of recipes list
     */
    // @SaCheckPermission("recipe:cuisineType:export")
    @Log(title = "rms_cuisine_type;The cuisine types of recipes", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(CuisineTypeBo bo, HttpServletResponse response) {
        List<CuisineTypeVo> list = cuisineTypeService.queryList(bo);
        ExcelUtil.exportExcel(list, "rms_cuisine_type;The cuisine types of recipes", CuisineTypeVo.class, response);
    }

    /**
     * Query rms_cuisine_type;The cuisine types of recipes details
     *
     * @param id primary key
     */
    // @SaCheckPermission("recipe:cuisineType:query")
    @GetMapping("/{id}")
    public R<CuisineTypeVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(cuisineTypeService.queryById(id));
    }

    /**
     * Add rms_cuisine_type;The cuisine types of recipes
     */
    // @SaCheckPermission("recipe:cuisineType:add")
    @Log(title = "rms_cuisine_type;The cuisine types of recipes", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody CuisineTypeBo bo) {
        return toAjax(cuisineTypeService.insertByBo(bo));
    }

    /**
     * Modify rms_cuisine_type;The cuisine types of recipes
     */
    // @SaCheckPermission("recipe:cuisineType:edit")
    @Log(title = "rms_cuisine_type;The cuisine types of recipes", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody CuisineTypeBo bo) {
        return toAjax(cuisineTypeService.updateByBo(bo));
    }

    /**
     * Delete rms_cuisine_type;The cuisine types of recipes
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("recipe:cuisineType:remove")
    @Log(title = "rms_cuisine_type;The cuisine types of recipes", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(cuisineTypeService.deleteWithValidByIds(List.of(ids), true));
    }
}
