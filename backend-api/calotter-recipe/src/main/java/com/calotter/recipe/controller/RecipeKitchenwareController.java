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
import com.calotter.recipe.domain.vo.RecipeKitchenwareVo;
import com.calotter.recipe.domain.bo.RecipeKitchenwareBo;
import com.calotter.recipe.service.IRecipeKitchenwareService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/recipe/recipeKitchenware")
public class RecipeKitchenwareController extends BaseController {

    private final IRecipeKitchenwareService recipeKitchenwareService;

    /**
     * Query rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. list
     */
    // @SaCheckPermission("recipe:recipeKitchenware:list")
    @GetMapping("/list")
    public TableDataInfo<RecipeKitchenwareVo> list(RecipeKitchenwareBo bo, PageQuery pageQuery) {
        return recipeKitchenwareService.queryPageList(bo, pageQuery);
    }

    /**
     * Export rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. list
     */
    // @SaCheckPermission("recipe:recipeKitchenware:export")
    @Log(title = "rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RecipeKitchenwareBo bo, HttpServletResponse response) {
        List<RecipeKitchenwareVo> list = recipeKitchenwareService.queryList(bo);
        ExcelUtil.exportExcel(list, "rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.", RecipeKitchenwareVo.class, response);
    }

    /**
     * Query rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("recipe:recipeKitchenware:query")
    @GetMapping("/{id}")
    public R<RecipeKitchenwareVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(recipeKitchenwareService.queryById(id));
    }

    /**
     * Add rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     */
    // @SaCheckPermission("recipe:recipeKitchenware:add")
    @Log(title = "rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RecipeKitchenwareBo bo) {
        return toAjax(recipeKitchenwareService.insertByBo(bo));
    }

    /**
     * Modify rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     */
    // @SaCheckPermission("recipe:recipeKitchenware:edit")
    @Log(title = "rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RecipeKitchenwareBo bo) {
        return toAjax(recipeKitchenwareService.updateByBo(bo));
    }

    /**
     * Delete rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("recipe:recipeKitchenware:remove")
    @Log(title = "rms_recipe_kitchenware;A light-weight association table which defines kitchenware requirements of recipes.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(recipeKitchenwareService.deleteWithValidByIds(List.of(ids), true));
    }
}
