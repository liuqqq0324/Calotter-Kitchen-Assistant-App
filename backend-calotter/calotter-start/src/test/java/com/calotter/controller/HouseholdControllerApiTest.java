package com.calotter.controller;

import com.calotter.user.controller.HouseholdController;
import com.calotter.user.controller.dto.HouseholdRequest;
import com.calotter.user.controller.dto.HouseholdResponse;
import com.calotter.user.service.HouseholdService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * HouseholdController API 集成测试
 */
@WebMvcTest(controllers = HouseholdController.class)
@AutoConfigureMockMvc(addFilters = false)
class HouseholdControllerApiTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private HouseholdService householdService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testCreateHousehold_Success() throws Exception {
        // Given
        HouseholdRequest request = new HouseholdRequest();
        request.setName("测试家庭");
        request.setOwnerId(1L);

        HouseholdResponse response = HouseholdResponse.builder()
                .id(1L)
                .name("测试家庭")
                .ownerId(1L)
                .inviteCode("ABC123")
                .build();

        when(householdService.createHousehold(any(HouseholdRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(post("/api/household")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.name").value("测试家庭"))
                .andExpect(jsonPath("$.data.ownerId").value(1))
                .andExpect(jsonPath("$.data.inviteCode").value("ABC123"));
    }

    @Test
    void testUpdateHousehold_Success() throws Exception {
        // Given
        HouseholdRequest request = new HouseholdRequest();
        request.setName("更新后的家庭");
        request.setOwnerId(1L);

        HouseholdResponse response = HouseholdResponse.builder()
                .id(1L)
                .name("更新后的家庭")
                .ownerId(1L)
                .inviteCode("ABC123")
                .build();

        when(householdService.updateHousehold(anyLong(), any(HouseholdRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/household/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").value("更新后的家庭"));
    }

    @Test
    void testGetHousehold_Success() throws Exception {
        // Given
        HouseholdResponse response = HouseholdResponse.builder()
                .id(1L)
                .name("测试家庭")
                .ownerId(1L)
                .inviteCode("ABC123")
                .build();

        when(householdService.getHousehold(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/household/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.name").value("测试家庭"));
    }

    @Test
    void testGetHouseholdByInviteCode_Success() throws Exception {
        // Given
        HouseholdResponse response = HouseholdResponse.builder()
                .id(1L)
                .name("测试家庭")
                .ownerId(1L)
                .inviteCode("ABC123")
                .build();

        when(householdService.getHouseholdByInviteCode("ABC123")).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/household/invite/ABC123"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.inviteCode").value("ABC123"));
    }

    @Test
    void testGetHouseholdsByOwner_Success() throws Exception {
        // Given
        List<HouseholdResponse> responses = Arrays.asList(
                HouseholdResponse.builder().id(1L).name("家庭1").ownerId(1L).build(),
                HouseholdResponse.builder().id(2L).name("家庭2").ownerId(1L).build()
        );

        when(householdService.getHouseholdsByOwner(1L)).thenReturn(responses);

        // When & Then
        mockMvc.perform(get("/api/household/owner/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testDeleteHousehold_Success() throws Exception {
        // Given
        when(householdService.getHousehold(anyLong())).thenReturn(
                HouseholdResponse.builder().id(1L).ownerId(1L).build()
        );

        // When & Then
        mockMvc.perform(delete("/api/household/1")
                        .param("ownerId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }
}
