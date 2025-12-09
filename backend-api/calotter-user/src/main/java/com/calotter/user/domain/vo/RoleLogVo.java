package com.calotter.user.domain.vo;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.calotter.user.domain.RoleLog;
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
 * ums_role_log;Stores body metrics of user roles. view object ums_role_log
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = RoleLog.class)
public class RoleLogVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Record id;Record ID (PK)
     */
    @ExcelProperty(value = "Record id;Record ID (PK)")
    private Long id;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    @ExcelProperty(value = "Role id;Role ID (FK, role_id -> user_role.id)")
    private Long roleId;

    /**
     * Creation date;The creation date of this record
     */
    @ExcelProperty(value = "Creation date;The creation date of this record")
    private Date recordAt;

    /**
     * Role weight;The weight of the role (unit: kg)
     */
    @ExcelProperty(value = "Role weight;The weight of the role (unit: kg)")
    private Double weightKg;

    /**
     * Role height;The height of the role (unit: cm)
     */
    @ExcelProperty(value = "Role height;The height of the role (unit: cm)")
    private Short heightCm;

    /**
     * Note;Note of the record (e.g., on an empty stomach or after dinner)
     */
    @ExcelProperty(value = "Note;Note of the record (e.g., on an empty stomach or after dinner)")
    private String notes;


}
