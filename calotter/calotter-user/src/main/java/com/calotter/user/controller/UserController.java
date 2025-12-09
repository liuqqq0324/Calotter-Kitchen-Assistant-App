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
import com.calotter.user.domain.bo.UserBo;
import com.calotter.user.domain.vo.UserVo;
import com.calotter.user.service.IUserService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ums_user;This table is the master user table, storing the basic information of all users.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/user")
public class UserController extends BaseController {

    private final IUserService userService;

    /**
     * Query ums_user;This table is the master user table, storing the basic information of all users. list
     */
    // @SaCheckPermission("user:user:list")
    @GetMapping("/list")
    public TableDataInfo<UserVo> list(UserBo bo, PageQuery pageQuery) {
        return userService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_user;This table is the master user table, storing the basic information of all users. list
     */
    // @SaCheckPermission("user:user:export")
    @Log(title = "ums_user;This table is the master user table, storing the basic information of all users.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(UserBo bo, HttpServletResponse response) {
        List<UserVo> list = userService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_user;This table is the master user table, storing the basic information of all users.", UserVo.class, response);
    }

    /**
     * Query ums_user;This table is the master user table, storing the basic information of all users. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:user:query")
    @GetMapping("/{id}")
    public R<UserVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(userService.queryById(id));
    }

    /**
     * Add ums_user;This table is the master user table, storing the basic information of all users.
     */
    // @SaCheckPermission("user:user:add")
    @Log(title = "ums_user;This table is the master user table, storing the basic information of all users.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody UserBo bo) {
        return toAjax(userService.insertByBo(bo));
    }

    /**
     * Modify ums_user;This table is the master user table, storing the basic information of all users.
     */
    // @SaCheckPermission("user:user:edit")
    @Log(title = "ums_user;This table is the master user table, storing the basic information of all users.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody UserBo bo) {
        return toAjax(userService.updateByBo(bo));
    }

    /**
     * Delete ums_user;This table is the master user table, storing the basic information of all users.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:user:remove")
    @Log(title = "ums_user;This table is the master user table, storing the basic information of all users.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(userService.deleteWithValidByIds(List.of(ids), true));
    }
}
