package com.calotter.user.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * ums_role_cuisine;The association table of dining role and cuisine object ums_role_cuisine
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_role_cuisine")
public class RoleCuisine extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Role cuisine id;Role cuisine ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Role id;Role ID (FK, role_id -> user_role.id)
     */
    private Long roleId;

    /**
     * Cuisine id;Cuisine ID (FK, cuisine_id -> cuisine_type.id)
     */
    private Long cuisineId;

    /**
     * Type of association;Association type: [1-like, 2-dislike]
     */
    private Short type;

    /**
     * Description;Association description (e.g., like to eat Sichuan Dishes for lunch)
     */
    private String description;


}
