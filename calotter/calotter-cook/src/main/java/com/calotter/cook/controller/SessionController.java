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
import com.calotter.cook.domain.vo.SessionVo;
import com.calotter.cook.domain.bo.SessionBo;
import com.calotter.cook.service.ISessionService;
import com.calotter.common.mybatis.core.page.TableDataInfo;

/**
 * cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
 *
 * @author Ruoyu Ji
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cook/session")
public class SessionController extends BaseController {

    private final ISessionService sessionService;

    /**
     * Query cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. list
     */
    // @SaCheckPermission("cook:session:list")
    @GetMapping("/list")
    public TableDataInfo<SessionVo> list(SessionBo bo, PageQuery pageQuery) {
        return sessionService.queryPageList(bo, pageQuery);
    }

    /**
     * Export cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. list
     */
    // @SaCheckPermission("cook:session:export")
    @Log(title = "cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(SessionBo bo, HttpServletResponse response) {
        List<SessionVo> list = sessionService.queryList(bo);
        ExcelUtil.exportExcel(list, "cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.", SessionVo.class, response);
    }

    /**
     * Query cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. details
     *
     * @param id primary key
     */
    // @SaCheckPermission("cook:session:query")
    @GetMapping("/{id}")
    public R<SessionVo> getInfo(@NotNull(message = "Primary key should not be empty")
                                     @PathVariable Long id) {
        return R.ok(sessionService.queryById(id));
    }

    /**
     * Add cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     */
    // @SaCheckPermission("cook:session:add")
    @Log(title = "cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping()
    public R<Void> add(@Validated(AddGroup.class) @RequestBody SessionBo bo) {
        return toAjax(sessionService.insertByBo(bo));
    }

    /**
     * Modify cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     */
    // @SaCheckPermission("cook:session:edit")
    @Log(title = "cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping()
    public R<Void> edit(@Validated(EditGroup.class) @RequestBody SessionBo bo) {
        return toAjax(sessionService.updateByBo(bo));
    }

    /**
     * Delete cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.
     *
     * @param ids primary key sequences
     */
    // @SaCheckPermission("cook:session:remove")
    @Log(title = "cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared.", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@NotEmpty(message = "Primary key should not be empty")
                          @PathVariable Long[] ids) {
        return toAjax(sessionService.deleteWithValidByIds(List.of(ids), true));
    }
}
