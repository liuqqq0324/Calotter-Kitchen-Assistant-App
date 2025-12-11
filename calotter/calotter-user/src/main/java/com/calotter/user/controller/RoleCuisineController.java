package com.calotter.user.controller;

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
import com.calotter.user.domain.vo.RoleCuisineVo;
import com.calotter.user.domain.bo.RoleCuisineBo;
import com.calotter.user.service.IRoleCuisineService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * ums_role_cuisine;The association table of dining role and cuisine
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/roleCuisine")
public class RoleCuisineController extends BaseController {

    private final IRoleCuisineService roleCuisineService;

    /**
     * Query ums_role_cuisine;The association table of dining role and cuisine list
     */
    // @SaCheckPermission("user:roleCuisine:list")
    @GetMapping("/list")
    public TableDataInfo<RoleCuisineVo> list(RoleCuisineBo bo, PageQuery pageQuery) {
        return roleCuisineService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_role_cuisine;The association table of dining role and cuisine list
     */
    // @SaCheckPermission("user:roleCuisine:export")
    @Log(title = "ums_role_cuisine;The association table of dining role and cuisine", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RoleCuisineBo bo, HttpServletResponse response) {
        List<RoleCuisineVo> list = roleCuisineService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_role_cuisine;The association table of dining role and cuisine", RoleCuisineVo.class, response);
    }

    /**
     * Query ums_role_cuisine;The association table of dining role and cuisine details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:roleCuisine:query")
    @GetMapping("/{id}")
    public R<RoleCuisineVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(roleCuisineService.queryById(id));
    }

    /**
     * Add ums_role_cuisine;The association table of dining role and cuisine
     */
    // @SaCheckPermission("user:roleCuisine:add")
    @Log(title = "ums_role_cuisine;The association table of dining role and cuisine", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RoleCuisineBo bo) {
        return toAjax(roleCuisineService.insertByBo(bo));
    }

    /**
     * Modify ums_role_cuisine;The association table of dining role and cuisine
     */
    // @SaCheckPermission("user:roleCuisine:edit")
    @Log(title = "ums_role_cuisine;The association table of dining role and cuisine", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RoleCuisineBo bo) {
        return toAjax(roleCuisineService.updateByBo(bo));
    }

    /**
     * Delete ums_role_cuisine;The association table of dining role and cuisine
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:roleCuisine:remove")
    @Log(title = "ums_role_cuisine;The association table of dining role and cuisine", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(roleCuisineService.deleteWithValidByIds(List.of(ids), true));
    }
}
