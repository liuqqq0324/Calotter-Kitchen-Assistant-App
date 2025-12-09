package com.calotter.inventory.support;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * Lightweight entity mapping to rms_kitchenware for cross-module lookups.
 */
@Data
@TableName("rms_kitchenware")
public class RmsKitchenware {
    @TableId("id")
    private Long id;
    private String name;
}
