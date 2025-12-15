package com.calotter.controller;

import com.calotter.health.controller.NutritionController;
import com.calotter.health.controller.dto.ManualNutritionLogRequest;
import com.calotter.health.controller.dto.WeeklyReportVO;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.service.NutritionAggregateService;
import com.calotter.health.service.NutritionLogService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * NutritionController API 集成测试
 */
@WebMvcTest(controllers = NutritionController.class)
@AutoConfigureMockMvc(addFilters = false)
class NutritionControllerApiTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NutritionLogService nutritionLogService;

    @MockBean
    private NutritionAggregateService aggregateService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testGetWeeklyReport_Success() throws Exception {
        // Given
        WeeklyReportVO report = WeeklyReportVO.builder()
                .weekStart(LocalDate.now())
                .weekEnd(LocalDate.now().plusDays(6))
                .build();

        when(aggregateService.getWeeklyReport(anyLong(), any(LocalDate.class))).thenReturn(report);

        // When & Then
        mockMvc.perform(get("/api/nutrition/weekly")
                        .param("memberId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    void testCreateManualLog_Success() throws Exception {
        // Given
        ManualNutritionLogRequest request = new ManualNutritionLogRequest();
        request.setFamilyMemberId(1L);
        request.setEatenAt(LocalDateTime.now());
        request.setFoodName("苹果");
        request.setQuantity(200.0); // Double类型
        request.setUnit("g");
        request.setCalories(100);

        NutritionLog log = new NutritionLog();
        log.setId(1L);
        log.setFoodName("苹果");
        log.setCalories(100); // Integer类型

        when(nutritionLogService.createManual(any(ManualNutritionLogRequest.class))).thenReturn(log);

        // When & Then
        mockMvc.perform(post("/api/nutrition/log/manual")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.foodName").value("苹果"));
    }

    @Test
    void testCreateFromLeftover_Success() throws Exception {
        // Given
        NutritionLog log = new NutritionLog();
        log.setId(1L);
        log.setFoodName("剩菜");
        log.setCalories(500);

        when(nutritionLogService.createFromLeftover(anyLong(), anyLong(), any(), any(LocalDateTime.class)))
                .thenReturn(log);

        // When & Then
        mockMvc.perform(post("/api/nutrition/log/leftover")
                        .param("leftoverId", "1")
                        .param("memberId", "1")
                        .param("consumedGram", "200"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    void testCreateFromLeftover_InvalidConsumedGram() throws Exception {
        // Given - 测试Service层的异常处理
        when(nutritionLogService.createFromLeftover(anyLong(), anyLong(), any(), any(LocalDateTime.class)))
                .thenThrow(new IllegalArgumentException("食用重量必须大于0"));

        // When & Then - 注意：根据Controller代码，异常没有被try-catch，可能被全局异常处理器处理
        // 或者返回400状态码（如果Controller没有捕获异常）
        // 由于Controller没有try-catch，异常会被全局异常处理器处理，可能返回400
        mockMvc.perform(post("/api/nutrition/log/leftover")
                        .param("leftoverId", "1")
                        .param("memberId", "1")
                        .param("consumedGram", "0")) // 无效的重量
                .andExpect(status().isBadRequest()) // 400状态码
                .andExpect(jsonPath("$.message").value("食用重量必须大于0"));
    }
}
