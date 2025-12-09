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
import com.calotter.recipe.domain.vo.RecipeVo;
import com.calotter.recipe.domain.bo.RecipeBo;
import com.calotter.recipe.service.IRecipeService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * rms_recipe;Stores all recipes and the corresponding ingredients.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/recipe/recipe")
public class RecipeController extends BaseController {

    private final IRecipeService recipeService;

    /**
     * Query rms_recipe;Stores all recipes and the corresponding ingredients. list
     */
    // @SaCheckPermission("recipe:recipe:list")
    @GetMapping("/list")
    public TableDataInfo<RecipeVo> list(RecipeBo bo, PageQuery pageQuery) {
        return recipeService.queryPageList(bo, pageQuery);
    }

    /**
     * Export rms_recipe;Stores all recipes and the corresponding ingredients. list
     */
    // @SaCheckPermission("recipe:recipe:export")
    @Log(title = "rms_recipe;Stores all recipes and the corresponding ingredients.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RecipeBo bo, HttpServletResponse response) {
        List<RecipeVo> list = recipeService.queryList(bo);
        ExcelUtil.exportExcel(list, "rms_recipe;Stores all recipes and the corresponding ingredients.", RecipeVo.class, response);
    }

    /**
     * Query rms_recipe;Stores all recipes and the corresponding ingredients. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("recipe:recipe:query")
    @GetMapping("/{id}")
    public R<RecipeVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(recipeService.queryById(id));
    }

    /**
     * Add rms_recipe;Stores all recipes and the corresponding ingredients.
     */
    // @SaCheckPermission("recipe:recipe:add")
    @Log(title = "rms_recipe;Stores all recipes and the corresponding ingredients.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RecipeBo bo) {
        return toAjax(recipeService.insertByBo(bo));
    }

    /**
     * Modify rms_recipe;Stores all recipes and the corresponding ingredients.
     */
    // @SaCheckPermission("recipe:recipe:edit")
    @Log(title = "rms_recipe;Stores all recipes and the corresponding ingredients.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RecipeBo bo) {
        return toAjax(recipeService.updateByBo(bo));
    }

    /**
     * Delete rms_recipe;Stores all recipes and the corresponding ingredients.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("recipe:recipe:remove")
    @Log(title = "rms_recipe;Stores all recipes and the corresponding ingredients.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(recipeService.deleteWithValidByIds(List.of(ids), true));
    }
}
