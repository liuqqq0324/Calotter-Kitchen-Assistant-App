package com.calotter.user.controller.dto;

import lombok.Data;
import java.util.List;

/**
 * 用户饮食习惯更新请求 DTO
 */
@Data
public class DietHabitsRequest {
    
    private List<String> dietHabits;
}

