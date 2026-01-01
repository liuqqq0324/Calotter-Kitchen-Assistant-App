package com.calotter.user.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

/**
 * 用户过敏响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AllergiesResponse {
    
    private List<String> allergies;
}
