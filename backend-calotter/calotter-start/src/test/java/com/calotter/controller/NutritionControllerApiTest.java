package com.calotter.controller;

import com.calotter.health.controller.NutritionController;
import com.calotter.health.controller.dto.ManualNutritionLogRequest;
import com.calotter.health.controller.dto.WeeklyReportVO;
import com.calotter.health.controller.dto.WeeklySummaryVO;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.service.NutritionAggregateService;
import com.calotter.health.service.NutritionLogService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * NutritionController API 完整测试
 * 覆盖所有营养相关API端点
 */
@WebMvcTest(controllers = NutritionController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("营养控制器API测试")
class NutritionControllerApiTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NutritionAggregateService aggregateService;

    @MockBean
    private NutritionLogService nutritionLogService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("获取周营养目标 - 成功")
    void testGetWeeklyReport_Success() throws Exception {
        // Given
        WeeklyReportVO.NutritionStats weeklyTarget = WeeklyReportVO.NutritionStats.builder()
                .energy(14000) // 2000 * 7
                .protein(1050.0) // 150 * 7
                .fat(455.0) // 65 * 7
                .carbohydrates(1750.0) // 250 * 7
                .build();

        WeeklyReportVO report = WeeklyReportVO.builder()
                .weekStart(LocalDate.now())
                .weeklyTarget(weeklyTarget)
                .build();

        when(aggregateService.getWeeklyReport(anyLong(), any(LocalDate.class))).thenReturn(report);

        // When & Then
        mockMvc.perform(get("/api/nutrition/targets/weekly")
                        .param("userId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists())
                .andExpect(jsonPath("$.data.weeklyTarget").exists());
    }

    @Test
    @DisplayName("获取周营养目标 - 指定周开始日期")
    void testGetWeeklyReport_WithWeekStart() throws Exception {
        // Given
        WeeklyReportVO report = WeeklyReportVO.builder()
                .weekStart(LocalDate.of(2024, 1, 1))
                .build();

        when(aggregateService.getWeeklyReport(anyLong(), any(LocalDate.class))).thenReturn(report);

        // When & Then
        mockMvc.perform(get("/api/nutrition/targets/weekly")
                        .param("userId", "1")
                        .param("weekStart", "2024-01-01"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    @DisplayName("获取周营养总结 - 成功")
    void testGetWeeklySummary_Success() throws Exception {
        // Given
        WeeklySummaryVO.NutritionValues consumed = WeeklySummaryVO.NutritionValues.builder()
                .energy(14000)
                .protein(1050.0)
                .fat(455.0)
                .carbohydrates(1750.0)
                .build();

        WeeklySummaryVO summary = WeeklySummaryVO.builder()
                .period("week")
                .consumed(consumed)
                .build();

        when(aggregateService.getWeeklySummary(anyLong(), any(LocalDate.class))).thenReturn(summary);

        // When & Then
        mockMvc.perform(get("/api/nutrition/summary")
                        .param("period", "week")
                        .param("userId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists())
                .andExpect(jsonPath("$.data.period").value("week"))
                .andExpect(jsonPath("$.data.consumed").exists());
    }

    @Test
    @DisplayName("获取周营养总结 - 无效周期")
    void testGetWeeklySummary_InvalidPeriod() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/nutrition/summary")
                        .param("period", "month")
                        .param("userId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("目前只支持 period=week"));
    }

    @Test
    @DisplayName("创建手动营养日志 - 成功")
    void testCreateManualLog_Success() throws Exception {
        // Given
        ManualNutritionLogRequest request = new ManualNutritionLogRequest();
        request.setUserId(1L);
        request.setEnergy(500);
        request.setProtein(30.0);
        request.setFat(20.0);
        request.setCarbohydrates(50.0);
        request.setFoodName("测试食物");
        request.setEatenAt(LocalDateTime.now());

        com.calotter.user.domain.entity.User user = new com.calotter.user.domain.entity.User();
        user.setId(1L);

        NutritionLog log = new NutritionLog();
        log.setId(1L);
        log.setUser(user);
        log.setBaseEnergy(500);
        log.setBaseProtein(30.0);
        log.setBaseFat(20.0);
        log.setBaseCarbohydrates(50.0);
        log.setEnergy(500);
        log.setProtein(30.0);
        log.setFat(20.0);
        log.setCarbohydrates(50.0);

        when(nutritionLogService.createManual(any(ManualNutritionLogRequest.class))).thenReturn(log);

        // When & Then
        mockMvc.perform(post("/api/nutrition/log/manual")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1));
    }

    @Test
    @DisplayName("从剩菜创建营养日志 - 成功")
    void testCreateFromLeftover_Success() throws Exception {
        // Given
        com.calotter.user.domain.entity.User user = new com.calotter.user.domain.entity.User();
        user.setId(1L);

        NutritionLog log = new NutritionLog();
        log.setId(1L);
        log.setUser(user);
        log.setDishId(100L); // 使用dishId存储leftoverId
        log.setBaseEnergy(400);
        log.setEnergy(400);

        when(nutritionLogService.createFromLeftover(eq(100L), eq(1L), eq(200), any(LocalDateTime.class))).thenReturn(log);

        // When & Then
        mockMvc.perform(post("/api/nutrition/log/leftover")
                        .param("leftoverId", "100")
                        .param("userId", "1")
                        .param("consumedGram", "200"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1));
    }

    @Test
    @DisplayName("从剩菜创建营养日志 - 指定进食时间")
    void testCreateFromLeftover_WithEatenAt() throws Exception {
        // Given
        com.calotter.user.domain.entity.User user = new com.calotter.user.domain.entity.User();
        user.setId(1L);

        NutritionLog log = new NutritionLog();
        log.setId(1L);
        log.setUser(user);
        log.setDishId(100L);

        when(nutritionLogService.createFromLeftover(eq(100L), eq(1L), eq(200), any(LocalDateTime.class))).thenReturn(log);

        // When & Then
        mockMvc.perform(post("/api/nutrition/log/leftover")
                        .param("leftoverId", "100")
                        .param("userId", "1")
                        .param("consumedGram", "200")
                        .param("eatenAt", "2024-01-01T12:00:00"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }
}
