package com.calotter.controller;

import com.calotter.health.controller.NutritionController;
import com.calotter.health.service.INutritionService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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
    private INutritionService nutritionService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testGetWeeklyNutritionTargets_Success() throws Exception {
        // Given
        INutritionService.WeeklyNutritionTargetsResponse resp = new INutritionService.WeeklyNutritionTargetsResponse();
        when(nutritionService.getWeeklyNutritionTargets(anyLong())).thenReturn(resp);

        // When & Then
        mockMvc.perform(get("/api/nutrition/targets/weekly")
                        .param("userId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    void testGetWeeklyNutritionSummary_Success() throws Exception {
        // Given
        INutritionService.WeeklyNutritionSummaryResponse resp = new INutritionService.WeeklyNutritionSummaryResponse();
        resp.setPeriod("week");
        when(nutritionService.getWeeklyNutritionSummary(anyLong())).thenReturn(resp);

        // When & Then
        mockMvc.perform(get("/api/nutrition/summary")
                        .param("period", "week")
                        .param("userId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists());
    }
}
