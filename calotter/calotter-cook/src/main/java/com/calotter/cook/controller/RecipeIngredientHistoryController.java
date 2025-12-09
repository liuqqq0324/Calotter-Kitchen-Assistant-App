package com.calotter.cook.controller;

import com.calotter.common.core.domain.R;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import com.calotter.common.excel.utils.ExcelUtil;
import com.calotter.common.idempotent.annotation.RepeatSubmit;
import com.calotter.common.log.annotation.Log;
import com.calotter.common.log.enums.BusinessType;
import com.calotter.common.mybatis.core.page.PageQuery;
import com.calotter.common.mybatis.core.page.TableDataInfo;
import com.calotter.common.web.core.BaseController;
import com.calotter.cook.domain.bo.RecipeIngredientHistoryBo;
import com.calotter.cook.domain.vo.RecipeIngredientHistoryVo;
import com.calotter.cook.service.IRecipeIngredientHistoryService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cook/recipeIngredientHistory")
public class RecipeIngredientHistoryController extends BaseController {

    private final IRecipeIngredientHistoryService recipeIngredientHistoryService;

    /**
     * Query cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. List
     */
    // @SaCheckPermission("cook:recipeIngredientHistory:list")
    @GetMapping("/list")
    public TableDataInfo<RecipeIngredientHistoryVo> list(RecipeIngredientHistoryBo bo, PageQuery pageQuery) {
        return recipeIngredientHistoryService.queryPageList(bo, pageQuery);
    }

    /**
     * Export cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     * List
     */
    // @SaCheckPermission("cook:recipeIngredientHistory:export")
    @Log(title = "cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RecipeIngredientHistoryBo bo, HttpServletResponse response) {
        List<RecipeIngredientHistoryVo> list = recipeIngredientHistoryService.queryList(bo);
        ExcelUtil.exportExcel(list, "cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.", RecipeIngredientHistoryVo.class, response);
    }

    /**
     * Query cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user. Details
     *
     * @param id primary key
     */
    // @SaCheckPermission("cook:recipeIngredientHistory:query")
    @GetMapping("/{id}")
    public R<RecipeIngredientHistoryVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(recipeIngredientHistoryService.queryById(id));
    }

    /**
     * Add cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     */
    // @SaCheckPermission("cook:recipeIngredientHistory:add")
    @Log(title = "cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RecipeIngredientHistoryBo bo) {
        return toAjax(recipeIngredientHistoryService.insertByBo(bo));
    }

    /**
     * Modify cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     */
    // @SaCheckPermission("cook:recipeIngredientHistory:edit")
    @Log(title = "cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RecipeIngredientHistoryBo bo) {
        return toAjax(recipeIngredientHistoryService.updateByBo(bo));
    }

    /**
     * Delete cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("cook:recipeIngredientHistory:remove")
    @Log(title = "cms_recipe_ingredient_history;This table stores all associated data regarding which ingredients were consumed for a specific dish prepared by the user.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(recipeIngredientHistoryService.deleteWithValidByIds(List.of(ids), true));
    }
}
