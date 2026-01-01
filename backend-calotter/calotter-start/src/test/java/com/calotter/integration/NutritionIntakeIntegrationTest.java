package com.calotter.integration;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 营养摄入流程集成测试
 * 
 * 测试完整的营养摄入流程，包括：
 * - 添加手动摄入
 * - 获取今日摄入
 * - 更新摄入百分比
 * - 删除摄入记录
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class NutritionIntakeIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NutritionLogRepository nutritionLogRepository;

    private User user;

    @BeforeEach
    void setUp() {
        // 清理测试数据
        nutritionLogRepository.deleteAll();
        userRepository.deleteAll();

        // 创建测试用户
        user = new User();
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPasswordHash("$2a$10$encodedPasswordHash");
        user.setRole("ROLE_USER");
        user.setStatus(1);
        user.setIsOnboarded(false);
        user = userRepository.save(user);
    }

    @Test
    void testAddManualIntakeAndGetTodayIntakes() throws Exception {
        // ==================== 步骤1：添加手动摄入 ====================
        Map<String, Object> addRequest = new HashMap<>();
        addRequest.put("date", LocalDate.now().toString());
        addRequest.put("foodName", "fried rice with egg");
        addRequest.put("portionDescription", "1 bowl");

        String addResponse = mockMvc.perform(post("/api/intake/manual")
                        .param("userId", user.getId().toString())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(addRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.intake.intakeId").exists())
                .andExpect(jsonPath("$.data.intake.manualFoodName").value("fried rice with egg"))
                .andReturn()
                .getResponse()
                .getContentAsString();

        // 验证NutritionLog已创建
        Long intakeId = objectMapper.readTree(addResponse)
                .at("/data/intake/intakeId")
                .asLong();

        NutritionLog log = nutritionLogRepository.findById(intakeId).orElse(null);
        assertThat(log).isNotNull();
        assertThat(log.getUser().getId()).isEqualTo(user.getId());
        assertThat(log.getSourceType()).isEqualTo(LogSourceType.MANUAL);
        assertThat(log.getFoodName()).isEqualTo("fried rice with egg");

        // ==================== 步骤2：获取今日手动摄入 ====================
        mockMvc.perform(get("/api/intake/today")
                        .param("userId", user.getId().toString())
                        .param("source", "manual"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.source").value("manual"))
                .andExpect(jsonPath("$.data.items").isArray())
                .andExpect(jsonPath("$.data.items[0].manualFoodName").value("fried rice with egg"));
    }

    @Test
    void testUpdateIntakePercentage() throws Exception {
        // Given: 创建一个营养日志
        NutritionLog log = new NutritionLog();
        log.setUser(user);
        log.setLogDate(LocalDate.now());
        log.setSourceType(LogSourceType.MANUAL);
        log.setFoodName("test food");
        log.setEnergy(1000);
        log.setBaseEnergy(1000);
        log.setProtein(50.0);
        log.setBaseProtein(50.0);
        log.setFat(30.0);
        log.setBaseFat(30.0);
        log.setCarbohydrates(100.0);
        log.setBaseCarbohydrates(100.0);
        log.setConsumedPercentage(BigDecimal.valueOf(100.0));
        log = nutritionLogRepository.save(log);

        // When: 更新摄入百分比为80%
        Map<String, Object> updateRequest = new HashMap<>();
        updateRequest.put("consumedPercentage", 80.0);

        mockMvc.perform(patch("/api/intake/{intake_id}", log.getId())
                        .param("userId", user.getId().toString())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.intake.consumedPercentage").value(80.0));

        // Then: 验证营养值已重新计算
        NutritionLog updatedLog = nutritionLogRepository.findById(log.getId()).orElse(null);
        assertThat(updatedLog).isNotNull();
        assertThat(updatedLog.getConsumedPercentage()).isEqualByComparingTo(BigDecimal.valueOf(80.0));
        // 验证实际摄入值 = 基础值 * 0.8
        assertThat(updatedLog.getEnergy()).isEqualTo(800); // 1000 * 0.8
    }

    @Test
    void testDeleteIntake() throws Exception {
        // Given: 创建一个营养日志
        NutritionLog log = new NutritionLog();
        log.setUser(user);
        log.setLogDate(LocalDate.now());
        log.setSourceType(LogSourceType.MANUAL);
        log.setFoodName("test food");
        log.setEnergy(1000);
        log.setConsumedPercentage(BigDecimal.valueOf(100.0));
        log = nutritionLogRepository.save(log);

        Long intakeId = log.getId();

        // When: 删除摄入记录
        mockMvc.perform(delete("/api/intake/{intake_id}", intakeId)
                        .param("userId", user.getId().toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.success").value(true));

        // Then: 验证记录已删除
        assertThat(nutritionLogRepository.findById(intakeId)).isEmpty();
    }

    @Test
    void testGetTodayIntakes_All() throws Exception {
        // Given: 创建多个营养日志（手动和菜谱）
        NutritionLog manualLog = new NutritionLog();
        manualLog.setUser(user);
        manualLog.setLogDate(LocalDate.now());
        manualLog.setSourceType(LogSourceType.MANUAL);
        manualLog.setFoodName("manual food");
        manualLog.setEnergy(500);
        manualLog.setConsumedPercentage(BigDecimal.valueOf(100.0));
        nutritionLogRepository.save(manualLog);

        NutritionLog recipeLog = new NutritionLog();
        recipeLog.setUser(user);
        recipeLog.setLogDate(LocalDate.now());
        recipeLog.setSourceType(LogSourceType.APP_COOKING);
        recipeLog.setFoodName("recipe food");
        recipeLog.setDishId(1L);
        recipeLog.setEnergy(800);
        recipeLog.setConsumedPercentage(BigDecimal.valueOf(100.0));
        nutritionLogRepository.save(recipeLog);

        // When: 获取所有今日摄入
        mockMvc.perform(get("/api/intake/today")
                        .param("userId", user.getId().toString())
                        .param("source", "all"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.source").value("all"))
                .andExpect(jsonPath("$.data.items").isArray())
                .andExpect(jsonPath("$.data.items.length()").value(2));
    }

    @Test
    void testAddManualIntake_UserNotFound() throws Exception {
        // When & Then: 使用不存在的userId
        Map<String, Object> addRequest = new HashMap<>();
        addRequest.put("date", LocalDate.now().toString());
        addRequest.put("foodName", "test food");
        addRequest.put("portionDescription", "1 bowl");

        mockMvc.perform(post("/api/intake/manual")
                        .param("userId", "999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(addRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("用户不存在")));
    }
}

