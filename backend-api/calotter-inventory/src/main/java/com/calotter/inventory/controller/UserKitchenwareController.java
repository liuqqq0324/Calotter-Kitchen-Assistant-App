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
import com.calotter.inventory.domain.vo.UserKitchenwareVo;
import com.calotter.inventory.domain.bo.UserKitchenwareBo;
import com.calotter.inventory.service.IUserKitchenwareService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/inventory/userKitchenware")
public class UserKitchenwareController extends BaseController {

    private final IUserKitchenwareService userKitchenwareService;

    /**
     * Query ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. list
     */
    // @SaCheckPermission("inventory:userKitchenware:list")
    @GetMapping("/list")
    public TableDataInfo<UserKitchenwareVo> list(UserKitchenwareBo bo, PageQuery pageQuery) {
        return userKitchenwareService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. list
     */
    // @SaCheckPermission("inventory:userKitchenware:export")
    @Log(title = "ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(UserKitchenwareBo bo, HttpServletResponse response) {
        List<UserKitchenwareVo> list = userKitchenwareService.queryList(bo);
        ExcelUtil.exportExcel(list, "ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.", UserKitchenwareVo.class, response);
    }

    /**
     * Query ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("inventory:userKitchenware:query")
    @GetMapping("/{id}")
    public R<UserKitchenwareVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(userKitchenwareService.queryById(id));
    }

    /**
     * Add ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     */
    // @SaCheckPermission("inventory:userKitchenware:add")
    @Log(title = "ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody UserKitchenwareBo bo) {
        return toAjax(userKitchenwareService.insertByBo(bo));
    }

    /**
     * Modify ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     */
    // @SaCheckPermission("inventory:userKitchenware:edit")
    @Log(title = "ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody UserKitchenwareBo bo) {
        return toAjax(userKitchenwareService.updateByBo(bo));
    }

    /**
     * Delete ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("inventory:userKitchenware:remove")
    @Log(title = "ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(userKitchenwareService.deleteWithValidByIds(List.of(ids), true));
    }
}
