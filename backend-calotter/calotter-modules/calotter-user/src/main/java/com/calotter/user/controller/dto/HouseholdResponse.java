package com.calotter.user.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 家庭响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HouseholdResponse {
    
    private Long id;
    private String name;
    private String inviteCode;
    private Long ownerId;
}
