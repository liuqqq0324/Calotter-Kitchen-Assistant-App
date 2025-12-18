package com.calotter.user.controller.dto;

import lombok.Data;
import java.util.List;

/**
 * 用户过敏更新请求 DTO
 */
@Data
public class AllergiesRequest {
    
    private List<String> allergies;
}
