package com.calotter.inventory.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. object ims_user_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ims_user_kitchenware")
public class UserKitchenware extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * User Kitchenware id;User kitchenware ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * User id;Refer to the account owner user id (FK, user_id -> user.id)
     */
    private Long userId;

    /**
     * Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenware.id)
     */
    private Long kitchenwareId;

    /**
     * Nickname;Nickname that the user made for the kitchenware (e.g., My Frying Pan)
     */
    private String nickname;

    /**
     * Date of purchase;When the kitchenware is purchased
     */
    private String purchaseDate;

    /**
     * Condition status;The status of the kitchenware (e.g., NEW, USED, BROKEN)
     */
    private String conditionStatus;


}
