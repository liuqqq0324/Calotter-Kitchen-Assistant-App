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
import com.calotter.user.domain.vo.RoleLogVo;
import com.calotter.user.domain.bo.RoleLogBo;
import com.calotter.user.service.IRoleLogService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * ums_role_log;Stores body metrics of user roles.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/roleLog")
public class RoleLogController extends BaseController {

    private final IRoleLogService roleLogService;

    /**
     * Query ums_role_log;Stores body metrics of user roles. list
     */
    // @SaCheckPermission("user:roleLog:list")
    @GetMapping("/list")
    public TableDataInfo<RoleLogVo> list(RoleLogBo bo, PageQuery pageQuery) {
        return roleLogService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_role_log;Stores body metrics of user roles. list
     */
    // @SaCheckPermission("user:roleLog:export")
    @Log(title = "ums_role_log;Stores body metrics of user roles.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RoleLogBo bo, HttpServletResponse response) {
        List<RoleLogVo> list = roleLogService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_role_log;Stores body metrics of user roles.", RoleLogVo.class, response);
    }

    /**
     * Query ums_role_log;Stores body metrics of user roles. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:roleLog:query")
    @GetMapping("/{id}")
    public R<RoleLogVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(roleLogService.queryById(id));
    }

    /**
     * Add ums_role_log;Stores body metrics of user roles.
     */
    // @SaCheckPermission("user:roleLog:add")
    @Log(title = "ums_role_log;Stores body metrics of user roles.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RoleLogBo bo) {
        return toAjax(roleLogService.insertByBo(bo));
    }

    /**
     * Modify ums_role_log;Stores body metrics of user roles.
     */
    // @SaCheckPermission("user:roleLog:edit")
    @Log(title = "ums_role_log;Stores body metrics of user roles.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RoleLogBo bo) {
        return toAjax(roleLogService.updateByBo(bo));
    }

    /**
     * Delete ums_role_log;Stores body metrics of user roles.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:roleLog:remove")
    @Log(title = "ums_role_log;Stores body metrics of user roles.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(roleLogService.deleteWithValidByIds(List.of(ids), true));
    }
}
