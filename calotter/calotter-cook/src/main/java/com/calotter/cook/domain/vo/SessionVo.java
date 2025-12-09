package com.calotter.cook.domain.vo;

import cn.hutool.core.date.DateTime;
import com.calotter.cook.domain.Session;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;


/**
 * cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. view object cms_session
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = Session.class)
public class SessionVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Cooking session id;Cooking history ID (PK)
     */
    @ExcelProperty(value = "Cooking session id;Cooking history ID (PK)")
    private Long id;

    /**
     * User id;Who performed this cooking (FK, user_id -> user.id)
     */
    @ExcelProperty(value = "User id;Who performed this cooking (FK, user_id -> user.id)")
    private Long userId;

    /**
     * Start time;Cooking start time
     */
    @ExcelProperty(value = "Start time;Cooking start time")
    private DateTime startTime;

    /**
     * End time;Cooking end time
     */
    @ExcelProperty(value = "End time;Cooking end time")
    private DateTime endTime;

    /**
     * Meal type;Meal type: [0 - other / unknown, 1 - breakfast, 2 - lunch, 3 - dinner, 4 - midnight snack, 5 - snack]
     */
    @ExcelProperty(value = "Meal type;Meal type: [0 - other / unknown, 1 - breakfast, 2 - lunch, 3 - dinner, 4 - midnight snack, 5 - snack]")
    private Short mealType;

    /**
     * Overall note;Overall note (e.g., to celebrate the birthday of mom)
     */
    @ExcelProperty(value = "Overall note;Overall note (e.g., to celebrate the birthday of mom)")
    private String note;


}
