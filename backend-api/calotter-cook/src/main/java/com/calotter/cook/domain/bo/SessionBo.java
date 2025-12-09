package com.calotter.cook.domain.bo;

import cn.hutool.core.date.DateTime;
import com.calotter.cook.domain.Session;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. business object cms_session
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = Session.class, reverseConvertGenerate = false)
public class SessionBo extends BaseEntity {

    /**
     * Cooking session id;Cooking history ID (PK)
     */
    @NotNull(message = "Cooking session id;Cooking history ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * User id;Who performed this cooking (FK, user_id -> user.id)
     */
    @NotNull(message = "User id;Who performed this cooking (FK, user_id -> user.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long userId;

    /**
     * Start time;Cooking start time
     */
    @NotNull(message = "Start time;Cooking start time can not be empty", groups = { AddGroup.class, EditGroup.class })
    private DateTime startTime;

    /**
     * End time;Cooking end time
     */
    private DateTime endTime;

    /**
     * Meal type;Meal type: [0 - other / unknown, 1 - breakfast, 2 - lunch, 3 - dinner, 4 - midnight snack, 5 - snack]
     */
    private Short mealType;

    /**
     * Overall note;Overall note (e.g., to celebrate the birthday of mom)
     */
    private String note;


}
