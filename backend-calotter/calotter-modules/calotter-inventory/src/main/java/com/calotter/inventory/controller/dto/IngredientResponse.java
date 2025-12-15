package com.calotter.inventory.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * 食材响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class IngredientResponse {
    
    private Long id;
    private Long householdId;
    private Long standardIngredientId;
    private String standardIngredientName;
    private String category;
    private Double quantity;
    private String unit;
    private LocalDate expirationDate;
    private String location;
}
