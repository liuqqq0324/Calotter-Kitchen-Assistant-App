package com.calotter.common.core.domain.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 标准厨具库
 */
@Data
@Entity
@Table(name = "ref_standard_utensils")
public class StandardUtensil {

    /**
     * 建议手动分配 ID 以便维护固定的图标映射
     * e.g. 2001 = "Frying Pan", 2002 = "Air Fryer"
     */
    @Id
    private Long id; 

    @Column(nullable = false)
    private String name;

    /**
     * 前端展示图标的资源路径或 Key
     * e.g., "icon_pan_2001.png" 或 "mdi-pot-steam"
     */
    private String iconUrl;
}
