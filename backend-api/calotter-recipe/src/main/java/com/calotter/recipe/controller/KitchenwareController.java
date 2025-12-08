package com.calotter.recipe.controller;

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
import com.calotter.recipe.domain.vo.KitchenwareVo;
import com.calotter.recipe.domain.bo.KitchenwareBo;
import com.calotter.recipe.service.IKitchenwareService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * rms_kitchenware;Global kitchenware table
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/recipe/kitchenware")
public class KitchenwareController extends BaseController {

    private final IKitchenwareService kitchenwareService;

    /**
     * Query rms_kitchenware;Global kitchenware table list
     */
    // @SaCheckPermission("recipe:kitchenware:list")
    @GetMapping("/list")
    public TableDataInfo<KitchenwareVo> list(KitchenwareBo bo, PageQuery pageQuery) {
        return kitchenwareService.queryPageList(bo, pageQuery);
    }

    /**
     * Export rms_kitchenware;Global kitchenware table list
     */
    // @SaCheckPermission("recipe:kitchenware:export")
    @Log(title = "rms_kitchenware;Global kitchenware table", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(KitchenwareBo bo, HttpServletResponse response) {
        List<KitchenwareVo> list = kitchenwareService.queryList(bo);
        ExcelUtil.exportExcel(list, "rms_kitchenware;Global kitchenware table", KitchenwareVo.class, response);
    }

    /**
     * Query rms_kitchenware;Global kitchenware table details
     *
     * @param id primary key
     */
    // @SaCheckPermission("recipe:kitchenware:query")
    @GetMapping("/{id}")
    public R<KitchenwareVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(kitchenwareService.queryById(id));
    }

    /**
     * Add rms_kitchenware;Global kitchenware table
     */
    // @SaCheckPermission("recipe:kitchenware:add")
    @Log(title = "rms_kitchenware;Global kitchenware table", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody KitchenwareBo bo) {
        return toAjax(kitchenwareService.insertByBo(bo));
    }

    /**
     * Modify rms_kitchenware;Global kitchenware table
     */
    // @SaCheckPermission("recipe:kitchenware:edit")
    @Log(title = "rms_kitchenware;Global kitchenware table", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody KitchenwareBo bo) {
        return toAjax(kitchenwareService.updateByBo(bo));
    }

    /**
     * Delete rms_kitchenware;Global kitchenware table
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("recipe:kitchenware:remove")
    @Log(title = "rms_kitchenware;Global kitchenware table", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(kitchenwareService.deleteWithValidByIds(List.of(ids), true));
    }
}
