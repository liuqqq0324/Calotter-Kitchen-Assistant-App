package com.calotter.user.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

/**
 * 用户禁忌响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaboosResponse {
    
    private List<String> taboos;
}
