package com.calotter.cook.domain.bo;

import com.calotter.cook.domain.SessionRole;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * cms_session_role;Association table that stores the relation of role and cooking history, with optional feedback from the role. business object cms_session_role
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = SessionRole.class, reverseConvertGenerate = false)
public class SessionRoleBo extends BaseEntity {

    /**
     * Session role id;Session role ID (PK)
     */
    @NotNull(message = "Session role id;Session role ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * Session record id;Session record ID (FK, session_id -> session.id)
     */
    @NotNull(message = "Session record id;Session record ID (FK, session_id -> session.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long sessionId;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    @NotNull(message = "Role id;Role ID (FK, role_id -> user_role.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
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
