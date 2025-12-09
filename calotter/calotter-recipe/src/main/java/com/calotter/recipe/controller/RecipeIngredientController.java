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
import com.calotter.recipe.domain.vo.RecipeIngredientVo;
import com.calotter.recipe.domain.bo.RecipeIngredientBo;
import com.calotter.recipe.service.IRecipeIngredientService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * rms_recipe_ingredient;Store the ingredient compositions of recipes.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/recipe/recipeIngredient")
public class RecipeIngredientController extends BaseController {

    private final IRecipeIngredientService recipeIngredientService;

    /**
     * Query rms_recipe_ingredient;Store the ingredient compositions of recipes. list
     */
    // @SaCheckPermission("recipe:recipeIngredient:list")
    @GetMapping("/list")
    public TableDataInfo<RecipeIngredientVo> list(RecipeIngredientBo bo, PageQuery pageQuery) {
        return recipeIngredientService.queryPageList(bo, pageQuery);
    }

    /**
     * Export rms_recipe_ingredient;Store the ingredient compositions of recipes. list
     */
    // @SaCheckPermission("recipe:recipeIngredient:export")
    @Log(title = "rms_recipe_ingredient;Store the ingredient compositions of recipes.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RecipeIngredientBo bo, HttpServletResponse response) {
        List<RecipeIngredientVo> list = recipeIngredientService.queryList(bo);
        ExcelUtil.exportExcel(list, "rms_recipe_ingredient;Store the ingredient compositions of recipes.", RecipeIngredientVo.class, response);
    }

    /**
     * Query rms_recipe_ingredient;Store the ingredient compositions of recipes. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("recipe:recipeIngredient:query")
    @GetMapping("/{id}")
    public R<RecipeIngredientVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(recipeIngredientService.queryById(id));
    }

    /**
     * Add rms_recipe_ingredient;Store the ingredient compositions of recipes.
     */
    // @SaCheckPermission("recipe:recipeIngredient:add")
    @Log(title = "rms_recipe_ingredient;Store the ingredient compositions of recipes.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RecipeIngredientBo bo) {
        return toAjax(recipeIngredientService.insertByBo(bo));
    }

    /**
     * Modify rms_recipe_ingredient;Store the ingredient compositions of recipes.
     */
    // @SaCheckPermission("recipe:recipeIngredient:edit")
    @Log(title = "rms_recipe_ingredient;Store the ingredient compositions of recipes.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RecipeIngredientBo bo) {
        return toAjax(recipeIngredientService.updateByBo(bo));
    }

    /**
     * Delete rms_recipe_ingredient;Store the ingredient compositions of recipes.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("recipe:recipeIngredient:remove")
    @Log(title = "rms_recipe_ingredient;Store the ingredient compositions of recipes.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(recipeIngredientService.deleteWithValidByIds(List.of(ids), true));
    }
}
