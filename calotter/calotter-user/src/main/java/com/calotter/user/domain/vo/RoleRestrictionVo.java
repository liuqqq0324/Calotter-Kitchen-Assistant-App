package com.calotter.user.domain.vo;

import com.calotter.user.domain.RoleRestriction;
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
 * ums_role_restriction;The dietary restrictions of specific dining role view object ums_role_restriction
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = RoleRestriction.class)
public class RoleRestrictionVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role restriction id;Role restriction ID (PK)
     */
    @ExcelProperty(value = "Role restriction id;Role restriction ID (PK)")
    private Long id;

    /**
     * Role id;Role id (FK, role_id -> user_role.id)
     */
    @ExcelProperty(value = "Role id;Role id (FK, role_id -> user_role.id)")
    private Long roleId;

    /**
     * Restriction id;Restriction id (FK, restriction_id -> restriction.id)
     */
    @ExcelProperty(value = "Restriction id;Restriction id (FK, restriction_id -> restriction.id)")
    private Long restrictionId;

    /**
     * Restriction type;Restriction type: [1-allergic, 2-taboo]
     */
    @ExcelProperty(value = "Restriction type;Restriction type: [1-allergic, 2-taboo]")
    private Short type;


}
