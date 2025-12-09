package com.calotter.cook.controller;

import java.util.List;

import lombok.RequiredArgsConstructor;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.*;
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
import com.calotter.cook.domain.vo.SessionRecipeVo;
import com.calotter.cook.domain.bo.SessionRecipeBo;
import com.calotter.cook.service.ISessionRecipeService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cook/sessionRecipe")
public class SessionRecipeController extends BaseController {

    private final ISessionRecipeService sessionRecipeService;

    /**
     * Query cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. list
     */
    // @SaCheckPermission("cook:sessionRecipe:list")
    @GetMapping("/list")
    public TableDataInfo<SessionRecipeVo> list(SessionRecipeBo bo, PageQuery pageQuery) {
        return sessionRecipeService.queryPageList(bo, pageQuery);
    }

    /**
     * Export cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. list
     */
    // @SaCheckPermission("cook:sessionRecipe:export")
    @Log(title = "cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(SessionRecipeBo bo, HttpServletResponse response) {
        List<SessionRecipeVo> list = sessionRecipeService.queryList(bo);
        ExcelUtil.exportExcel(list, "cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.", SessionRecipeVo.class, response);
    }

    /**
     * Query cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("cook:sessionRecipe:query")
    @GetMapping("/{id}")
    public R<SessionRecipeVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(sessionRecipeService.queryById(id));
    }

    /**
     * Add cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     */
    // @SaCheckPermission("cook:sessionRecipe:add")
    @Log(title = "cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody SessionRecipeBo bo) {
        return toAjax(sessionRecipeService.insertByBo(bo));
    }

    /**
     * Modify cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     */
    // @SaCheckPermission("cook:sessionRecipe:edit")
    @Log(title = "cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody SessionRecipeBo bo) {
        return toAjax(sessionRecipeService.updateByBo(bo));
    }

    /**
     * Delete cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("cook:sessionRecipe:remove")
    @Log(title = "cms_session_recipe;This table stores all associated data regarding the specific dishes included in a particular meal prepared by the user.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(sessionRecipeService.deleteWithValidByIds(List.of(ids), true));
    }
}
