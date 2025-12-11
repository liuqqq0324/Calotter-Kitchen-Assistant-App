package com.calotter.user.domain.vo;

import com.calotter.user.domain.RolePreference;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import com.calotter.common.excel.annotation.ExcelDictFormat;
import com.calotter.common.excel.convert.ExcelDictConvert;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;



/**
 * ums_role_preference;The dietary preference of specific dining role view object ums_role_preference
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = RolePreference.class)
public class RolePreferenceVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role preference id;Role preference ID (PK)
     */
    @ExcelProperty(value = "Role preference id;Role preference ID (PK)")
    private Long id;

    /**
     * Role id;Role id (FK, role_id -> user_role.id)
     */
    @ExcelProperty(value = "Role id;Role id (FK, role_id -> user_role.id)")
    private Long roleId;

    /**
     * Preference id;Preference id (FK, preference_id -> preference.id)
     */
    @ExcelProperty(value = "Preference id;Preference id (FK, preference_id -> preference.id)")
    private Long preferenceId;

    /**
     * Preference level;Preference level: [1-like, 2-favorite]
     */
    @ExcelProperty(value = "Preference level;Preference level: [1-like, 2-favorite]")
    private Short level;


}
