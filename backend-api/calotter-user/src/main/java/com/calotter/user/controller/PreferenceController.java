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
import com.calotter.user.domain.bo.PreferenceBo;
import com.calotter.user.domain.vo.PreferenceVo;
import com.calotter.user.service.IPreferenceService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ums_preference;The global dietary preference of dining roles
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/preference")
public class PreferenceController extends BaseController {

    private final IPreferenceService preferenceService;

    /**
     * Query ums_preference;The global dietary preference of dining roles list
     */
    // @SaCheckPermission("user:preference:list")
    @GetMapping("/list")
    public TableDataInfo<PreferenceVo> list(PreferenceBo bo, PageQuery pageQuery) {
        return preferenceService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_preference;The global dietary preference of dining roles list
     */
    // @SaCheckPermission("user:preference:export")
    @Log(title = "ums_preference;The global dietary preference of dining roles", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(PreferenceBo bo, HttpServletResponse response) {
        List<PreferenceVo> list = preferenceService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_preference;The global dietary preference of dining roles", PreferenceVo.class, response);
    }

    /**
     * Query ums_preference;The global dietary preference of dining roles details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:preference:query")
    @GetMapping("/{id}")
    public R<PreferenceVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(preferenceService.queryById(id));
    }

    /**
     * Add ums_preference;The global dietary preference of dining roles
     */
    // @SaCheckPermission("user:preference:add")
    @Log(title = "ums_preference;The global dietary preference of dining roles", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody PreferenceBo bo) {
        return toAjax(preferenceService.insertByBo(bo));
    }

    /**
     * Modify ums_preference;The global dietary preference of dining roles
     */
    // @SaCheckPermission("user:preference:edit")
    @Log(title = "ums_preference;The global dietary preference of dining roles", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody PreferenceBo bo) {
        return toAjax(preferenceService.updateByBo(bo));
    }

    /**
     * Delete ums_preference;The global dietary preference of dining roles
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:preference:remove")
    @Log(title = "ums_preference;The global dietary preference of dining roles", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(preferenceService.deleteWithValidByIds(List.of(ids), true));
    }
}
