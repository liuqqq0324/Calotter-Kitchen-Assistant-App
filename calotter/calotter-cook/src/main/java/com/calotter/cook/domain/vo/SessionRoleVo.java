package com.calotter.cook.domain.vo;

import com.calotter.cook.domain.SessionRole;
import cn.idev.excel.annotation.ExcelIgnoreUnannotated;
import cn.idev.excel.annotation.ExcelProperty;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;


/**
 * cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. view object cms_session_role
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = SessionRole.class)
public class SessionRoleVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Session role id;Session role ID (PK)
     */
    @ExcelProperty(value = "Session role id;Session role ID (PK)")
    private Long id;

    /**
     * Session record id;Session record ID (FK, session_id -> session.id)
     */
    @ExcelProperty(value = "Session record id;Session record ID (FK, session_id -> session.id)")
    private Long sessionId;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    @ExcelProperty(value = "Role id;Role ID (FK, role_id -> user_role.id)")
    private Long roleId;

    /**
     * Feedback score;Feedback score (optional): [0 - not specified, 1 - Unsatisfied, 2 - Somewhat unsatisfied, 3 - Neutral, 4 - Somewhat satisfied, 5 - satisfied]
     */
    @ExcelProperty(value = "Feedback score;Feedback score (optional): [0 - not specified, 1 - Unsatisfied, 2 - Somewhat unsatisfied, 3 - Neutral, 4 - Somewhat satisfied, 5 - satisfied]")
    private Short feedbackScore;

    /**
     * Feedback text;Feedback description from the role (optional)
     */
    @ExcelProperty(value = "Feedback text;Feedback description from the role (optional)")
    private String feedbackDesc;


}
