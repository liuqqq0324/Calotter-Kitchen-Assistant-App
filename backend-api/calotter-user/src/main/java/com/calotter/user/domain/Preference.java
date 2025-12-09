package com.calotter.user.domain;

import com.calotter.common.mybatis.core.domain.BaseEntity;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serial;

/**
 * ums_preference;The global dietary preference of dining roles object ums_preference
 *
 * @author Ruoyu Ji
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ums_preference")
public class Preference extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * Preference id;Preference ID (PK)
     */
    @TableId(value = "id")
    private Long id;

    /**
     * Preference name;Preference name
     */
    private String name;

    /**
     * Preference description;Preference description
     */
    private String description;

    /**
     * Whether is shown by default;Whether the Preference is shown by default
     */
    private Boolean defaultShown;

    /**
     * Sort priority;Sort the priority of the display sequence
     */
    private Short sort;


}
