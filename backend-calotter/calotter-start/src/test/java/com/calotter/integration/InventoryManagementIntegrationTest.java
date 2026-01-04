package com.calotter.integration;

import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.domain.entity.StandardSpice;
import com.calotter.common.core.domain.entity.StandardUtensil;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.HouseholdSpice;
import com.calotter.inventory.domain.entity.HouseholdUtensil;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.HouseholdSpiceRepository;
import com.calotter.inventory.repository.HouseholdUtensilRepository;
import com.calotter.inventory.repository.StandardIngredientRepository;
import com.calotter.inventory.repository.StandardSpiceRepository;
import com.calotter.inventory.repository.StandardUtensilRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
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

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 库存管理集成测试
 * 
 * 测试完整的库存管理流程，包括：
 * - 添加食材
 * - 更新食材
 * - 获取食材列表
 * - 切换厨具和调料可用性
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class InventoryManagementIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private HouseholdRepository householdRepository;

    @Autowired
    private IngredientRepository ingredientRepository;

    @Autowired
    private HouseholdUtensilRepository utensilRepository;

    @Autowired
    private HouseholdSpiceRepository spiceRepository;

    @Autowired
    private StandardIngredientRepository standardIngredientRepository;

    @Autowired
    private StandardSpiceRepository standardSpiceRepository;

    @Autowired
    private StandardUtensilRepository standardUtensilRepository;

    private User user;
    private Household household;

    @BeforeEach
    void setUp() {
        // 清理测试数据
        spiceRepository.deleteAll();
        utensilRepository.deleteAll();
        ingredientRepository.deleteAll();
        householdRepository.deleteAll();
        userRepository.deleteAll();
        standardIngredientRepository.deleteAll();
        standardSpiceRepository.deleteAll();
        standardUtensilRepository.deleteAll();

        // 创建测试用户
        user = new User();
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPasswordHash("$2a$10$encodedPasswordHash");
        user.setRole("ROLE_USER");
        user.setStatus(1);
        user.setIsOnboarded(false);
        user = userRepository.save(user);

        // 创建测试家庭
        household = new Household();
        household.setName("测试家庭");
        household.setOwnerId(user.getId());
        household.setInviteCode("TEST001");
        household = householdRepository.save(household);

        user.setCurrentHouseholdId(household.getId());
        userRepository.save(user);
    }

    @Test
    void testIngredientCRUD() throws Exception {
        // ==================== 步骤1：添加食材 ====================
        Map<String, Object> addRequest = new HashMap<>();
        addRequest.put("householdId", household.getId());
        addRequest.put("standardIngredientId", 1001L);
        addRequest.put("quantity", 500.0);
        addRequest.put("unit", "g");
        addRequest.put("expirationDate", LocalDate.now().plusDays(7).toString());

        String addResponse = mockMvc.perform(post("/api/inventory/ingredients")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(addRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").exists())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Long ingredientId = objectMapper.readTree(addResponse)
                .at("/data/id")
                .asLong();

        // 验证食材已保存
        Ingredient savedIngredient = ingredientRepository.findById(ingredientId).orElse(null);
        assertThat(savedIngredient).isNotNull();
        assertThat(savedIngredient.getHousehold().getId()).isEqualTo(household.getId());
        assertThat(savedIngredient.getQuantity()).isEqualTo(500.0);

        // ==================== 步骤2：获取食材列表 ====================
        mockMvc.perform(get("/api/inventory/ingredients")
                        .param("householdId", household.getId().toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data[0].id").value(ingredientId));

        // ==================== 步骤3：更新食材 ====================
        Map<String, Object> updateRequest = new HashMap<>();
        updateRequest.put("householdId", household.getId());
        updateRequest.put("standardIngredientId", 1001L);
        updateRequest.put("quantity", 300.0);
        updateRequest.put("unit", "g");

        mockMvc.perform(put("/api/inventory/ingredients/{id}", ingredientId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.quantity").value(300.0));

        // 验证更新
        Ingredient updatedIngredient = ingredientRepository.findById(ingredientId).orElse(null);
        assertThat(updatedIngredient).isNotNull();
        assertThat(updatedIngredient.getQuantity()).isEqualTo(300.0);

        // ==================== 步骤4：删除食材 ====================
        mockMvc.perform(delete("/api/inventory/ingredients/{id}", ingredientId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        // 验证删除
        assertThat(ingredientRepository.findById(ingredientId)).isEmpty();
    }

    @Test
    void testToggleUtensilAvailability() throws Exception {
        // Given: 创建标准厨具
        StandardUtensil standardUtensil = new StandardUtensil();
        standardUtensil.setId(2001L);
        standardUtensil.setName("wok");
        standardUtensil = standardUtensilRepository.save(standardUtensil);

        // 创建家庭厨具
        HouseholdUtensil utensil = new HouseholdUtensil();
        utensil.setHousehold(household);
        utensil.setIsAvailable(false);
        utensil.setMetadata(standardUtensil);
        utensil = utensilRepository.save(utensil);

        // When: 切换可用性
        mockMvc.perform(patch("/api/inventory/utensils/{id}/toggle", utensil.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(true));

        // Then: 验证状态已切换
        HouseholdUtensil updatedUtensil = utensilRepository.findById(utensil.getId()).orElse(null);
        assertThat(updatedUtensil).isNotNull();
        assertThat(updatedUtensil.getIsAvailable()).isTrue();
    }

    @Test
    void testToggleSpiceAvailability() throws Exception {
        // Given: 创建标准调料
        StandardSpice standardSpice = new StandardSpice();
        standardSpice.setId(3001L);
        standardSpice.setName("salt");
        standardSpice = standardSpiceRepository.save(standardSpice);

        // 创建家庭调料
        HouseholdSpice spice = new HouseholdSpice();
        spice.setHousehold(household);
        spice.setIsAvailable(false);
        spice.setMetadata(standardSpice);
        spice = spiceRepository.save(spice);

        // When: 切换可用性
        mockMvc.perform(patch("/api/inventory/spices/{id}/toggle", spice.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(true));

        // Then: 验证状态已切换
        HouseholdSpice updatedSpice = spiceRepository.findById(spice.getId()).orElse(null);
        assertThat(updatedSpice).isNotNull();
        assertThat(updatedSpice.getIsAvailable()).isTrue();
    }

    @Test
    void testGetStandardLibraries() throws Exception {
        // 测试获取标准库（这些接口应该返回数据，即使数据库为空也应该返回空数组）
        mockMvc.perform(get("/api/inventory/standard-ingredients"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());

        mockMvc.perform(get("/api/inventory/standard-utensils"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());

        mockMvc.perform(get("/api/inventory/standard-spices"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());

        mockMvc.perform(get("/api/user/standard-allergens"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }
}

