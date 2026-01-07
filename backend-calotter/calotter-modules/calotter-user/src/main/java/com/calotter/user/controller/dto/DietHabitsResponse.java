package com.calotter.user.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

/**
 * 用户饮食习惯响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DietHabitsResponse {
    
    private List<String> dietHabits;
}

