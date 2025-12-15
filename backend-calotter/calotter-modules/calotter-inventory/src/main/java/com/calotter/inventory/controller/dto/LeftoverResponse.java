package com.calotter.inventory.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 剩菜响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeftoverResponse {
    
    private Long id;
    private Long householdId;
    private String name;
    private String coverImage;
    private Double quantityGram;
    private LocalDateTime producedTime;
}
