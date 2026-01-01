package com.calotter.user.controller.dto;

import lombok.Data;
import java.util.List;

/**
 * 用户禁忌更新请求 DTO
 */
@Data
public class TaboosRequest {
    
    private List<String> taboos;
}
