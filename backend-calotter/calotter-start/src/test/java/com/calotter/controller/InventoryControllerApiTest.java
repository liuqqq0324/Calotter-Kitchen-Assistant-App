package com.calotter.controller;

import com.calotter.inventory.controller.InventoryController;
import com.calotter.inventory.controller.dto.*;
import com.calotter.inventory.service.InventoryService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * InventoryController API 集成测试
 * 重点测试剩菜管理API（字段已更新）
 */
@WebMvcTest(controllers = InventoryController.class)
@AutoConfigureMockMvc(addFilters = false)
class InventoryControllerApiTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private InventoryService inventoryService;

    @Autowired
    private ObjectMapper objectMapper;

    // ==================== 剩菜管理API测试 ====================

    @Test
    void testCreateLeftover_Success() throws Exception {
        // Given - 使用新的字段结构
        LeftoverRequest request = new LeftoverRequest();
        request.setHouseholdId(1L);
        request.setOriginalDishId(100L);
        request.setCurrentQuantityGram(500);
        request.setProducedTime(LocalDateTime.now());

        LeftoverResponse response = LeftoverResponse.builder()
                .id(1L)
                .householdId(1L)
                .originalDishId(100L)
                .currentQuantityGram(500)
                .producedTime(request.getProducedTime())
                .build();

        when(inventoryService.createLeftover(any(LeftoverRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(post("/api/inventory/leftovers")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.householdId").value(1))
                .andExpect(jsonPath("$.data.originalDishId").value(100))
                .andExpect(jsonPath("$.data.currentQuantityGram").value(500))
                // 验证响应中不包含旧字段（name, coverImage, quantityGram）
                .andExpect(jsonPath("$.data.name").doesNotExist())
                .andExpect(jsonPath("$.data.coverImage").doesNotExist());
    }

    @Test
    void testUpdateLeftover_Success() throws Exception {
        // Given - 由于DTO验证，需要提供所有必需字段（即使更新时只需要部分字段）
        LeftoverRequest request = new LeftoverRequest();
        request.setHouseholdId(1L);
        request.setOriginalDishId(100L);
        request.setCurrentQuantityGram(200);
        request.setProducedTime(LocalDateTime.now());

        LeftoverResponse response = LeftoverResponse.builder()
                .id(1L)
                .householdId(1L)
                .originalDishId(100L)
                .currentQuantityGram(200)
                .build();

        when(inventoryService.updateLeftover(anyLong(), any(LeftoverRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/inventory/leftovers/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.currentQuantityGram").value(200));
    }

    @Test
    void testGetLeftover_Success() throws Exception {
        // Given
        LeftoverResponse response = LeftoverResponse.builder()
                .id(1L)
                .householdId(1L)
                .originalDishId(100L)
                .currentQuantityGram(300)
                .build();

        when(inventoryService.getLeftover(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/inventory/leftovers/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.originalDishId").value(100))
                .andExpect(jsonPath("$.data.currentQuantityGram").value(300));
    }

    @Test
    void testGetLeftoversByHousehold_Success() throws Exception {
        // Given
        List<LeftoverResponse> responses = Arrays.asList(
                LeftoverResponse.builder().id(1L).householdId(1L).originalDishId(100L).currentQuantityGram(300).build(),
                LeftoverResponse.builder().id(2L).householdId(1L).originalDishId(200L).currentQuantityGram(400).build()
        );

        when(inventoryService.getLeftoversByHousehold(1L)).thenReturn(responses);

        // When & Then
        mockMvc.perform(get("/api/inventory/leftovers")
                        .param("householdId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testDeleteLeftover_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/inventory/leftovers/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    // ==================== 食材管理API测试 ====================

    @Test
    void testCreateIngredient_Success() throws Exception {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(1L);
        request.setStandardIngredientId(1L);
        request.setQuantity(500.0);
        request.setUnit("g");

        IngredientResponse response = IngredientResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardIngredientId(1L)
                .quantity(500.0)
                .unit("g")
                .build();

        when(inventoryService.createIngredient(any(IngredientRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(post("/api/inventory/ingredients")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1));
    }

    @Test
    void testGetIngredientsByHousehold_Success() throws Exception {
        // Given
        List<IngredientResponse> responses = Arrays.asList(
                IngredientResponse.builder().id(1L).householdId(1L).build()
        );

        when(inventoryService.getIngredientsByHousehold(1L)).thenReturn(responses);

        // When & Then
        mockMvc.perform(get("/api/inventory/ingredients")
                        .param("householdId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    void testUpdateIngredient_Success() throws Exception {
        // Given
        IngredientRequest request = new IngredientRequest();
        request.setHouseholdId(1L);
        request.setStandardIngredientId(1L);
        request.setQuantity(300.0);
        request.setUnit("g");

        IngredientResponse response = IngredientResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardIngredientId(1L)
                .quantity(300.0)
                .unit("g")
                .build();

        when(inventoryService.updateIngredient(anyLong(), any(IngredientRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/inventory/ingredients/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.quantity").value(300.0));
    }

    @Test
    void testGetIngredient_Success() throws Exception {
        // Given
        IngredientResponse response = IngredientResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardIngredientId(1L)
                .quantity(500.0)
                .unit("g")
                .build();

        when(inventoryService.getIngredient(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/inventory/ingredients/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.quantity").value(500.0));
    }

    @Test
    void testDeleteIngredient_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/inventory/ingredients/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testDeductIngredient_Success() throws Exception {
        // When & Then
        mockMvc.perform(post("/api/inventory/ingredients/1/deduct")
                        .param("amount", "100.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    // ==================== 调料管理API测试 ====================

    @Test
    void testCreateSpice_Success() throws Exception {
        // Given
        SpiceRequest request = new SpiceRequest();
        request.setHouseholdId(1L);
        request.setStandardSpiceId(1L);
        request.setIsAvailable(true);
        request.setRemark("新买的");

        SpiceResponse response = SpiceResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardSpiceId(1L)
                .isAvailable(true)
                .remark("新买的")
                .build();

        when(inventoryService.createSpice(any(SpiceRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(post("/api/inventory/spices")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.isAvailable").value(true));
    }

    @Test
    void testUpdateSpice_Success() throws Exception {
        // Given
        SpiceRequest request = new SpiceRequest();
        request.setHouseholdId(1L);
        request.setStandardSpiceId(1L);
        request.setIsAvailable(false);
        request.setRemark("用完了");

        SpiceResponse response = SpiceResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardSpiceId(1L)
                .isAvailable(false)
                .remark("用完了")
                .build();

        when(inventoryService.updateSpice(anyLong(), any(SpiceRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/inventory/spices/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(false));
    }

    @Test
    void testGetSpice_Success() throws Exception {
        // Given
        SpiceResponse response = SpiceResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardSpiceId(1L)
                .isAvailable(true)
                .build();

        when(inventoryService.getSpice(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/inventory/spices/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.isAvailable").value(true));
    }

    @Test
    void testGetSpicesByHousehold_Success() throws Exception {
        // Given
        List<SpiceResponse> responses = Arrays.asList(
                SpiceResponse.builder().id(1L).householdId(1L).isAvailable(true).build(),
                SpiceResponse.builder().id(2L).householdId(1L).isAvailable(true).build()
        );

        when(inventoryService.getSpicesByHousehold(1L)).thenReturn(responses);

        // When & Then
        mockMvc.perform(get("/api/inventory/spices")
                        .param("householdId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testDeleteSpice_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/inventory/spices/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    // ==================== 厨具管理API测试 ====================

    @Test
    void testCreateUtensil_Success() throws Exception {
        // Given
        UtensilRequest request = new UtensilRequest();
        request.setHouseholdId(1L);
        request.setStandardUtensilId(1L);
        request.setIsAvailable(true);
        request.setRemark("新的");

        UtensilResponse response = UtensilResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardUtensilId(1L)
                .isAvailable(true)
                .remark("新的")
                .build();

        when(inventoryService.createUtensil(any(UtensilRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(post("/api/inventory/utensils")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.isAvailable").value(true));
    }

    @Test
    void testUpdateUtensil_Success() throws Exception {
        // Given
        UtensilRequest request = new UtensilRequest();
        request.setHouseholdId(1L);
        request.setStandardUtensilId(1L);
        request.setIsAvailable(false);
        request.setRemark("坏了");

        UtensilResponse response = UtensilResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardUtensilId(1L)
                .isAvailable(false)
                .remark("坏了")
                .build();

        when(inventoryService.updateUtensil(anyLong(), any(UtensilRequest.class))).thenReturn(response);

        // When & Then
        mockMvc.perform(put("/api/inventory/utensils/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(false));
    }

    @Test
    void testGetUtensil_Success() throws Exception {
        // Given
        UtensilResponse response = UtensilResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardUtensilId(1L)
                .isAvailable(true)
                .build();

        when(inventoryService.getUtensil(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(get("/api/inventory/utensils/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(1))
                .andExpect(jsonPath("$.data.isAvailable").value(true));
    }

    @Test
    void testGetUtensilsByHousehold_Success() throws Exception {
        // Given
        List<UtensilResponse> responses = Arrays.asList(
                UtensilResponse.builder().id(1L).householdId(1L).isAvailable(true).build(),
                UtensilResponse.builder().id(2L).householdId(1L).isAvailable(true).build()
        );

        when(inventoryService.getUtensilsByHousehold(1L)).thenReturn(responses);

        // When & Then
        mockMvc.perform(get("/api/inventory/utensils")
                        .param("householdId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data.length()").value(2));
    }

    @Test
    void testDeleteUtensil_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/api/inventory/utensils/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testToggleUtensilAvailability_Success() throws Exception {
        // Given
        UtensilResponse response = UtensilResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardUtensilId(1L)
                .isAvailable(false)
                .build();

        when(inventoryService.toggleUtensilAvailability(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(patch("/api/inventory/utensils/1/toggle"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(false));
    }

    @Test
    void testToggleSpiceAvailability_Success() throws Exception {
        // Given
        SpiceResponse response = SpiceResponse.builder()
                .id(1L)
                .householdId(1L)
                .standardSpiceId(1L)
                .isAvailable(false)
                .build();

        when(inventoryService.toggleSpiceAvailability(1L)).thenReturn(response);

        // When & Then
        mockMvc.perform(patch("/api/inventory/spices/1/toggle"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(false));
    }

    // ==================== 剩菜部分更新测试 ====================

    @Test
    void testPatchLeftover_Success() throws Exception {
        // Given
        Map<String, Object> request = new HashMap<>();
        request.put("consumedPercentage", 30.0);

        LeftoverResponse response = LeftoverResponse.builder()
                .id(1L)
                .householdId(1L)
                .originalDishId(100L)
                .currentQuantityGram(350) // 消费30%后剩余
                .build();

        when(inventoryService.patchLeftover(1L, new java.math.BigDecimal("30.0"))).thenReturn(response);

        // When & Then
        mockMvc.perform(patch("/api/inventory/leftovers/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.currentQuantityGram").value(350));
    }

    // ==================== 标准库查询测试 ====================

    @Test
    void testGetAllStandardIngredients_Success() throws Exception {
        // Given
        com.calotter.common.core.domain.entity.StandardIngredient ingredient = 
                new com.calotter.common.core.domain.entity.StandardIngredient();
        ingredient.setId(1001L);
        ingredient.setName("鸡蛋");
        List<com.calotter.common.core.domain.entity.StandardIngredient> ingredients = Arrays.asList(ingredient);

        when(inventoryService.getAllStandardIngredients()).thenReturn(ingredients);

        // When & Then
        mockMvc.perform(get("/api/inventory/standard-ingredients"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    void testSearchStandardIngredients_ExactMatch() throws Exception {
        // Given
        com.calotter.common.core.domain.entity.StandardIngredient ingredient = 
                new com.calotter.common.core.domain.entity.StandardIngredient();
        ingredient.setId(1001L);
        ingredient.setName("鸡蛋");

        when(inventoryService.findStandardIngredientByName("鸡蛋")).thenReturn(ingredient);

        // When & Then
        mockMvc.perform(get("/api/inventory/standard-ingredients/search")
                        .param("name", "鸡蛋")
                        .param("fuzzy", "false"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").value("鸡蛋"));
    }

    @Test
    void testSearchStandardIngredients_FuzzyMatch() throws Exception {
        // Given
        com.calotter.common.core.domain.entity.StandardIngredient ingredient = 
                new com.calotter.common.core.domain.entity.StandardIngredient();
        ingredient.setId(1001L);
        ingredient.setName("鸡蛋");
        List<com.calotter.common.core.domain.entity.StandardIngredient> ingredients = Arrays.asList(ingredient);

        when(inventoryService.searchStandardIngredientsByName("鸡")).thenReturn(ingredients);

        // When & Then
        mockMvc.perform(get("/api/inventory/standard-ingredients/search")
                        .param("name", "鸡")
                        .param("fuzzy", "true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    void testGetAllowedUnits_Success() throws Exception {
        // Given
        List<String> allowedUnits = Arrays.asList("pcs", "g");

        when(inventoryService.getAllowedUnits(1001L)).thenReturn(allowedUnits);

        // When & Then
        mockMvc.perform(get("/api/inventory/standard-ingredients/1001/allowed-units"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data.length()").value(2));
    }
}
