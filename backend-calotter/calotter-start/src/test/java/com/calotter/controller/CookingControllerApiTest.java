package com.calotter.controller;

import com.calotter.cooking.controller.CookingController;
import com.calotter.cooking.controller.dto.CookingCompletionRequest;
import com.calotter.cooking.controller.dto.CookingCompletionResponse;
import com.calotter.cooking.controller.dto.CookingGenerationRequest;
import com.calotter.cooking.service.CookingContextBuilderService;
import com.calotter.cooking.service.CookingSessionService;
import com.calotter.cooking.service.dto.AiCookingContext;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * CookingController API 集成测试
 */
@WebMvcTest(controllers = CookingController.class)
@AutoConfigureMockMvc(addFilters = false)
class CookingControllerApiTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CookingContextBuilderService cookingContextBuilderService;

    @MockBean
    private CookingSessionService cookingSessionService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testGenerateContext_Success() throws Exception {
        // Given
        CookingGenerationRequest request = new CookingGenerationRequest();
        request.setUserIds(Arrays.asList(1L, 2L));
        request.setDishCount(3);
        request.setMaxTimeMinutes(60);
        request.setDifficulty("MEDIUM");

        AiCookingContext context = AiCookingContext.builder()
                .build();

        when(cookingContextBuilderService.buildContext(any(CookingGenerationRequest.class))).thenReturn(context);

        // When & Then
        mockMvc.perform(post("/api/cooking/generate-context")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testCompleteSession_Success() throws Exception {
        // Given
        CookingCompletionRequest request = new CookingCompletionRequest();
        request.setSessionId(1L);
        CookingCompletionRequest.DinerConsumption diner = new CookingCompletionRequest.DinerConsumption();
        diner.setUserId(1L);
        diner.setPortionPercentage(0.4); // 40%
        request.setDiners(Arrays.asList(diner));

        CookingCompletionResponse response = CookingCompletionResponse.builder()
                .success(true)
                .logsCreated(1)
                .leftoverCreated(false)
                .totalCaloriesConsumed(800)
                .build();

        when(cookingSessionService.completeSession(any(CookingCompletionRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(post("/api/cooking/complete")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.success").value(true))
                .andExpect(jsonPath("$.data.logsCreated").value(1));
    }
}
