package com.calotter.cook.domain;

import cn.hutool.core.date.DateTime;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * cms_session;This table records the start and end times for all users cooking sessions, along with which meal they prepared. object cms_session
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cms_session")
public class Session extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Cooking session id;Cooking history ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * User id;Who performed this cooking (FK, user_id -> user.id)
     */
    private Long userId;

    /**
     * Start time;Cooking start time
     */
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
