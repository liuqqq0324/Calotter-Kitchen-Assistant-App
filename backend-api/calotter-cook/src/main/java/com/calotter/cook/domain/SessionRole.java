package com.calotter.cook.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. object cms_session_role
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cms_session_role")
public class SessionRole extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Session role id;Session role ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Session record id;Session record ID (FK, session_id -> session.id)
     */
    private Long sessionId;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    private Long roleId;

    /**
     * Feedback score;Feedback score (optional): [0 - not specified, 1 - Unsatisfied, 2 - Somewhat unsatisfied, 3 - Neutral, 4 - Somewhat satisfied, 5 - satisfied]
     */
    private Short feedbackScore;

    /**
     * Feedback text;Feedback description from the role (optional)
     */
    private String feedbackDesc;


}
