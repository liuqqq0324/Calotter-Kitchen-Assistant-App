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
import com.calotter.recipe.domain.vo.IngredientVo;
import com.calotter.recipe.domain.bo.IngredientBo;
import com.calotter.recipe.service.IIngredientService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * rms_ingredient;Stores all ingredients could be used in a recipe.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/recipe/ingredient")
public class IngredientController extends BaseController {

    private final IIngredientService ingredientService;

    /**
     * Query rms_ingredient;Stores all ingredients could be used in a recipe. list
     */
    // @SaCheckPermission("recipe:ingredient:list")
    @GetMapping("/list")
    public TableDataInfo<IngredientVo> list(IngredientBo bo, PageQuery pageQuery) {
        return ingredientService.queryPageList(bo, pageQuery);
    }

    /**
     * Export rms_ingredient;Stores all ingredients could be used in a recipe. list
     */
    // @SaCheckPermission("recipe:ingredient:export")
    @Log(title = "rms_ingredient;Stores all ingredients could be used in a recipe.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(IngredientBo bo, HttpServletResponse response) {
        List<IngredientVo> list = ingredientService.queryList(bo);
        ExcelUtil.exportExcel(list, "rms_ingredient;Stores all ingredients could be used in a recipe.", IngredientVo.class, response);
    }

    /**
     * Query rms_ingredient;Stores all ingredients could be used in a recipe. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("recipe:ingredient:query")
    @GetMapping("/{id}")
    public R<IngredientVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(ingredientService.queryById(id));
    }

    /**
     * Add rms_ingredient;Stores all ingredients could be used in a recipe.
     */
    // @SaCheckPermission("recipe:ingredient:add")
    @Log(title = "rms_ingredient;Stores all ingredients could be used in a recipe.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody IngredientBo bo) {
        return toAjax(ingredientService.insertByBo(bo));
    }

    /**
     * Modify rms_ingredient;Stores all ingredients could be used in a recipe.
     */
    // @SaCheckPermission("recipe:ingredient:edit")
    @Log(title = "rms_ingredient;Stores all ingredients could be used in a recipe.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody IngredientBo bo) {
        return toAjax(ingredientService.updateByBo(bo));
    }

    /**
     * Delete rms_ingredient;Stores all ingredients could be used in a recipe.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("recipe:ingredient:remove")
    @Log(title = "rms_ingredient;Stores all ingredients could be used in a recipe.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(ingredientService.deleteWithValidByIds(List.of(ids), true));
    }
}
