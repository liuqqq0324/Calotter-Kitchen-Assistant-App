package com.calotter.inventory.domain.bo;

import com.calotter.inventory.domain.UserKitchenware;
import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.calotter.common.core.validate.AddGroup;
import com.calotter.common.core.validate.EditGroup;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import jakarta.validation.constraints.*;

/**
 * ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. business object ims_user_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = UserKitchenware.class, reverseConvertGenerate = false)
public class UserKitchenwareBo extends BaseEntity {

    /**
     * User Kitchenware id;User kitchenware ID (PK)
     */
    @NotNull(message = "User Kitchenware id;User kitchenware ID (PK) can not be empty", groups = { EditGroup.class })
    private Long id;

    /**
     * User id;Refer to the account owner user id (FK, user_id -> user.id)
     */
    @NotNull(message = "User id;Refer to the account owner user id (FK, user_id -> user.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
    private Long userId;

    /**
     * Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenware.id)
     */
    @NotNull(message = "Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenware.id) can not be empty", groups = { AddGroup.class, EditGroup.class })
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
