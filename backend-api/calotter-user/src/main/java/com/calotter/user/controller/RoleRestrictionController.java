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
import com.calotter.user.domain.bo.RoleRestrictionBo;
import com.calotter.user.domain.vo.RoleRestrictionVo;
import com.calotter.user.service.IRoleRestrictionService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ums_role_restriction;The dietary restrictions of specific dining role
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/roleRestriction")
public class RoleRestrictionController extends BaseController {

    private final IRoleRestrictionService roleRestrictionService;

    /**
     * Query ums_role_restriction;The dietary restrictions of specific dining role list
     */
    // @SaCheckPermission("user:roleRestriction:list")
    @GetMapping("/list")
    public TableDataInfo<RoleRestrictionVo> list(RoleRestrictionBo bo, PageQuery pageQuery) {
        return roleRestrictionService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_role_restriction;The dietary restrictions of specific dining role list
     */
    // @SaCheckPermission("user:roleRestriction:export")
    @Log(title = "ums_role_restriction;The dietary restrictions of specific dining role", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RoleRestrictionBo bo, HttpServletResponse response) {
        List<RoleRestrictionVo> list = roleRestrictionService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_role_restriction;The dietary restrictions of specific dining role", RoleRestrictionVo.class, response);
    }

    /**
     * Query ums_role_restriction;The dietary restrictions of specific dining role details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:roleRestriction:query")
    @GetMapping("/{id}")
    public R<RoleRestrictionVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(roleRestrictionService.queryById(id));
    }

    /**
     * Add ums_role_restriction;The dietary restrictions of specific dining role
     */
    // @SaCheckPermission("user:roleRestriction:add")
    @Log(title = "ums_role_restriction;The dietary restrictions of specific dining role", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RoleRestrictionBo bo) {
        return toAjax(roleRestrictionService.insertByBo(bo));
    }

    /**
     * Modify ums_role_restriction;The dietary restrictions of specific dining role
     */
    // @SaCheckPermission("user:roleRestriction:edit")
    @Log(title = "ums_role_restriction;The dietary restrictions of specific dining role", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RoleRestrictionBo bo) {
        return toAjax(roleRestrictionService.updateByBo(bo));
    }

    /**
     * Delete ums_role_restriction;The dietary restrictions of specific dining role
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:roleRestriction:remove")
    @Log(title = "ums_role_restriction;The dietary restrictions of specific dining role", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(roleRestrictionService.deleteWithValidByIds(List.of(ids), true));
    }
}
