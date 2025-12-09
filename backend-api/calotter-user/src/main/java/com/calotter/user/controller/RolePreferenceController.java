package com.calotter.user.controller;

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
import com.calotter.user.domain.bo.RolePreferenceBo;
import com.calotter.user.domain.vo.RolePreferenceVo;
import com.calotter.user.service.IRolePreferenceService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ums_role_preference;The dietary preference of specific dining role
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/rolePreference")
public class RolePreferenceController extends BaseController {

    private final IRolePreferenceService rolePreferenceService;

    /**
     * Query ums_role_preference;The dietary preference of specific dining role list
     */
    // @SaCheckPermission("user:rolePreference:list")
    @GetMapping("/list")
    public TableDataInfo<RolePreferenceVo> list(RolePreferenceBo bo, PageQuery pageQuery) {
        return rolePreferenceService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_role_preference;The dietary preference of specific dining role list
     */
    // @SaCheckPermission("user:rolePreference:export")
    @Log(title = "ums_role_preference;The dietary preference of specific dining role", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RolePreferenceBo bo, HttpServletResponse response) {
        List<RolePreferenceVo> list = rolePreferenceService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_role_preference;The dietary preference of specific dining role", RolePreferenceVo.class, response);
    }

    /**
     * Query ums_role_preference;The dietary preference of specific dining role details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:rolePreference:query")
    @GetMapping("/{id}")
    public R<RolePreferenceVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(rolePreferenceService.queryById(id));
    }

    /**
     * Add ums_role_preference;The dietary preference of specific dining role
     */
    // @SaCheckPermission("user:rolePreference:add")
    @Log(title = "ums_role_preference;The dietary preference of specific dining role", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RolePreferenceBo bo) {
        return toAjax(rolePreferenceService.insertByBo(bo));
    }

    /**
     * Modify ums_role_preference;The dietary preference of specific dining role
     */
    // @SaCheckPermission("user:rolePreference:edit")
    @Log(title = "ums_role_preference;The dietary preference of specific dining role", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RolePreferenceBo bo) {
        return toAjax(rolePreferenceService.updateByBo(bo));
    }

    /**
     * Delete ums_role_preference;The dietary preference of specific dining role
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:rolePreference:remove")
    @Log(title = "ums_role_preference;The dietary preference of specific dining role", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(rolePreferenceService.deleteWithValidByIds(List.of(ids), true));
    }
}
