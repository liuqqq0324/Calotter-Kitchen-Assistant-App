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
import com.calotter.cook.domain.vo.SessionRoleVo;
import com.calotter.cook.domain.bo.SessionRoleBo;
import com.calotter.cook.service.ISessionRoleService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cook/sessionRole")
public class SessionRoleController extends BaseController {

    private final ISessionRoleService sessionRoleService;

    /**
     * Query cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. list
     */
    // @SaCheckPermission("cook:sessionRole:list")
    @GetMapping("/list")
    public TableDataInfo<SessionRoleVo> list(SessionRoleBo bo, PageQuery pageQuery) {
        return sessionRoleService.queryPageList(bo, pageQuery);
    }

    /**
     * Export cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. list
     */
    // @SaCheckPermission("cook:sessionRole:export")
    @Log(title = "cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(SessionRoleBo bo, HttpServletResponse response) {
        List<SessionRoleVo> list = sessionRoleService.queryList(bo);
        ExcelUtil.exportExcel(list, "cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.", SessionRoleVo.class, response);
    }

    /**
     * Query cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("cook:sessionRole:query")
    @GetMapping("/{id}")
    public R<SessionRoleVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(sessionRoleService.queryById(id));
    }

    /**
     * Add cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     */
    // @SaCheckPermission("cook:sessionRole:add")
    @Log(title = "cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody SessionRoleBo bo) {
        return toAjax(sessionRoleService.insertByBo(bo));
    }

    /**
     * Modify cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     */
    // @SaCheckPermission("cook:sessionRole:edit")
    @Log(title = "cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody SessionRoleBo bo) {
        return toAjax(sessionRoleService.updateByBo(bo));
    }

    /**
     * Delete cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("cook:sessionRole:remove")
    @Log(title = "cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(sessionRoleService.deleteWithValidByIds(List.of(ids), true));
    }
}
