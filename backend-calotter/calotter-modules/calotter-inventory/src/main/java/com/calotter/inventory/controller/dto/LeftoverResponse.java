package com.calotter.inventory.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 剩菜响应 DTO
 * 
 * 注意：由于 inventory 模块不依赖 cooking 模块，此 DTO 不包含 name 和 coverImage。
 * 如果需要这些信息，请使用 cooking 模块的 LeftoverDishService.getLeftoverDishDetail() 方法。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeftoverResponse {
    
    private Long id;
    private Long householdId;
    private Long originalDishId;
    private Integer currentQuantityGram;
    private LocalDateTime producedTime;
}
