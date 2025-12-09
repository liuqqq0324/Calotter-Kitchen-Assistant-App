package com.calotter.inventory.support;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * Lightweight entity mapping to rms_ingredient for cross-module lookups.
 */
@Data
@TableName("rms_ingredient")
public class RmsIngredient {
    @TableId("id")
    private Long id;
    private String name;
    @TableField("image_url")
    private String imageUrl; // maps to image_url
}
