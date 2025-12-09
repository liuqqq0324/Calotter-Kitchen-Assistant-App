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
import com.calotter.user.domain.bo.UserRoleBo;
import com.calotter.user.domain.vo.UserRoleVo;
import com.calotter.user.service.IUserRoleService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/userRole")
public class UserRoleController extends BaseController {

    private final IUserRoleService userRoleService;

    /**
     * Query ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. list
     */
    // @SaCheckPermission("user:userRole:list")
    @GetMapping("/list")
    public TableDataInfo<UserRoleVo> list(UserRoleBo bo, PageQuery pageQuery) {
        return userRoleService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. list
     */
    // @SaCheckPermission("user:userRole:export")
    @Log(title = "ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(UserRoleBo bo, HttpServletResponse response) {
        List<UserRoleVo> list = userRoleService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.", UserRoleVo.class, response);
    }

    /**
     * Query ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:userRole:query")
    @GetMapping("/{id}")
    public R<UserRoleVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(userRoleService.queryById(id));
    }

    /**
     * Add ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     */
    // @SaCheckPermission("user:userRole:add")
    @Log(title = "ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody UserRoleBo bo) {
        return toAjax(userRoleService.insertByBo(bo));
    }

    /**
     * Modify ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     */
    // @SaCheckPermission("user:userRole:edit")
    @Log(title = "ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody UserRoleBo bo) {
        return toAjax(userRoleService.updateByBo(bo));
    }

    /**
     * Delete ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:userRole:remove")
    @Log(title = "ums_user_role;This table represents the user role. A user can cook for one to multiple diners (user role). Each record in this table stores all information about a role, along with the account to which that role belongs.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(userRoleService.deleteWithValidByIds(List.of(ids), true));
    }
}
