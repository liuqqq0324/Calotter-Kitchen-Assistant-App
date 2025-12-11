package com.calotter.inventory.domain.vo;

import com.calotter.inventory.domain.UserKitchenware;
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
 * ims_user_kitchenware;This table stores all user kitchenware, with each record containing the basic information of the kitchenware and the user to whom it belongs. view object ims_user_kitchenware
 *
 * @author Ruoyu Ji
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = UserKitchenware.class)
public class UserKitchenwareVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * User Kitchenware id;User kitchenware ID (PK)
     */
    @ExcelProperty(value = "User Kitchenware id;User kitchenware ID (PK)")
    private Long id;

    /**
     * User id;Refer to the account owner user id (FK, user_id -> user.id)
     */
    @ExcelProperty(value = "User id;Refer to the account owner user id (FK, user_id -> user.id)")
    private Long userId;

    /**
     * Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenware.id)
     */
    @ExcelProperty(value = "Kitchenware id;Associate to global kitchenware table (FK, kitchenware_id -> kitchenware.id)")
    private Long kitchenwareId;

    /**
     * Nickname;Nickname that the user made for the kitchenware (e.g., My Frying Pan)
     */
    @ExcelProperty(value = "Nickname;Nickname that the user made for the kitchenware (e.g., My Frying Pan)")
    private String nickname;

    /**
     * Date of purchase;When the kitchenware is purchased
     */
    @ExcelProperty(value = "Date of purchase;When the kitchenware is purchased")
    private String purchaseDate;

    /**
     * Condition status;The status of the kitchenware (e.g., NEW, USED, BROKEN)
     */
    @ExcelProperty(value = "Condition status;The status of the kitchenware (e.g., NEW, USED, BROKEN)")
    private String conditionStatus;


}
