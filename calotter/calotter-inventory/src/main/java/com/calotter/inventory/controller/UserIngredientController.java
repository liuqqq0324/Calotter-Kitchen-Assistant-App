package com.calotter.inventory.controller;

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
import com.calotter.inventory.domain.vo.UserIngredientVo;
import com.calotter.inventory.domain.bo.UserIngredientBo;
import com.calotter.inventory.service.IUserIngredientService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/inventory/userIngredient")
public class UserIngredientController extends BaseController {

    private final IUserIngredientService userIngredientService;

    /**
     * Query ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. list
     */
    // @SaCheckPermission("inventory:userIngredient:list")
    @GetMapping("/list")
    public TableDataInfo<UserIngredientVo> list(UserIngredientBo bo, PageQuery pageQuery) {
        return userIngredientService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. list
     */
    // @SaCheckPermission("inventory:userIngredient:export")
    @Log(title = "ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(UserIngredientBo bo, HttpServletResponse response) {
        List<UserIngredientVo> list = userIngredientService.queryList(bo);
        ExcelUtil.exportExcel(list, "ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.", UserIngredientVo.class, response);
    }

    /**
     * Query ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("inventory:userIngredient:query")
    @GetMapping("/{id}")
    public R<UserIngredientVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(userIngredientService.queryById(id));
    }

    /**
     * Add ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     */
    // @SaCheckPermission("inventory:userIngredient:add")
    @Log(title = "ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody UserIngredientBo bo) {
        return toAjax(userIngredientService.insertByBo(bo));
    }

    /**
     * Modify ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     */
    // @SaCheckPermission("inventory:userIngredient:edit")
    @Log(title = "ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody UserIngredientBo bo) {
        return toAjax(userIngredientService.updateByBo(bo));
    }

    /**
     * Delete ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("inventory:userIngredient:remove")
    @Log(title = "ims_user_ingredient;This table stores all user ingredients. Each record contains the ingredient basic information and specifies which user owns it.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(userIngredientService.deleteWithValidByIds(List.of(ids), true));
    }
}
