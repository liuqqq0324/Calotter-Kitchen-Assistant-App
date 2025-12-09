package com.calotter.user.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * ums_restriction;The global dietary restrictions of dining roles object ums_restriction
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_restriction")
public class Restriction extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Restriction id;Restriction ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Restriction name;Restriction name
     */
    private String name;

    /**
     * Restriction description;The description of the restriction
     */
    private String description;

    /**
     * Whether is default shown;Whether the dietary restriction is shown by default
     */
    private Boolean defaultShown;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    private Short sort;


}
