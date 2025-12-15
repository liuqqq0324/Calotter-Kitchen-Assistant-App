package com.calotter.inventory.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 调料响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SpiceResponse {
    
    private Long id;
    private Long householdId;
    private Long standardSpiceId;
    private String standardSpiceName;
    private Boolean isAvailable;
    private String remark;
}
