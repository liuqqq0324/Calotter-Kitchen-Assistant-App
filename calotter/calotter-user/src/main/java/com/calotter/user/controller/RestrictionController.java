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
import com.calotter.user.domain.vo.RestrictionVo;
import com.calotter.user.domain.bo.RestrictionBo;
import com.calotter.user.service.IRestrictionService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * ums_restriction;The global dietary restrictions of dining roles
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/user/restriction")
public class RestrictionController extends BaseController {

    private final IRestrictionService restrictionService;

    /**
     * Query ums_restriction;The global dietary restrictions of dining roles list
     */
    // @SaCheckPermission("user:restriction:list")
    @GetMapping("/list")
    public TableDataInfo<RestrictionVo> list(RestrictionBo bo, PageQuery pageQuery) {
        return restrictionService.queryPageList(bo, pageQuery);
    }

    /**
     * Export ums_restriction;The global dietary restrictions of dining roles list
     */
    // @SaCheckPermission("user:restriction:export")
    @Log(title = "ums_restriction;The global dietary restrictions of dining roles", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(RestrictionBo bo, HttpServletResponse response) {
        List<RestrictionVo> list = restrictionService.queryList(bo);
        ExcelUtil.exportExcel(list, "ums_restriction;The global dietary restrictions of dining roles", RestrictionVo.class, response);
    }

    /**
     * Query ums_restriction;The global dietary restrictions of dining roles details
     *
     * @param id primary key
     */
    // @SaCheckPermission("user:restriction:query")
    @GetMapping("/{id}")
    public R<RestrictionVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(restrictionService.queryById(id));
    }

    /**
     * Add ums_restriction;The global dietary restrictions of dining roles
     */
    // @SaCheckPermission("user:restriction:add")
    @Log(title = "ums_restriction;The global dietary restrictions of dining roles", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody RestrictionBo bo) {
        return toAjax(restrictionService.insertByBo(bo));
    }

    /**
     * Modify ums_restriction;The global dietary restrictions of dining roles
     */
    // @SaCheckPermission("user:restriction:edit")
    @Log(title = "ums_restriction;The global dietary restrictions of dining roles", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody RestrictionBo bo) {
        return toAjax(restrictionService.updateByBo(bo));
    }

    /**
     * Delete ums_restriction;The global dietary restrictions of dining roles
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("user:restriction:remove")
    @Log(title = "ums_restriction;The global dietary restrictions of dining roles", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(restrictionService.deleteWithValidByIds(List.of(ids), true));
    }
}
