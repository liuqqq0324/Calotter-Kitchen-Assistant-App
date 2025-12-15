package com.calotter.inventory.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 厨具响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UtensilResponse {
    
    private Long id;
    private Long householdId;
    private Long standardUtensilId;
    private String standardUtensilName;
    private Boolean isAvailable;
    private String remark;
}
