package com.calotter.integration;

import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.domain.entity.StandardSpice;
import com.calotter.common.core.domain.entity.StandardUtensil;
import com.calotter.inventory.controller.dto.IngredientRequest;
import com.calotter.inventory.controller.dto.SpiceRequest;
import com.calotter.inventory.controller.dto.UtensilRequest;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.HouseholdSpice;
import com.calotter.inventory.domain.entity.HouseholdUtensil;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.HouseholdSpiceRepository;
import com.calotter.inventory.repository.HouseholdUtensilRepository;
import com.calotter.common.core.repository.StandardIngredientRepository;
import com.calotter.inventory.repository.StandardSpiceRepository;
import com.calotter.inventory.repository.StandardUtensilRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

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
 * - 删除食材
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
    private StandardIngredient standardIngredient;

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

        // 创建标准食材
        standardIngredient = new StandardIngredient();
        standardIngredient.setId(1001L);
        standardIngredient.setName("五花肉");
        standardIngredient.setCategory("MEAT");
        standardIngredient.setPrimaryUnit("g");
        standardIngredient.setSecondaryUnit("kg");
        standardIngredient.setUnitConversionFactor(0.001);
        standardIngredient.setStandardUnit("g");
        standardIngredient = standardIngredientRepository.save(standardIngredient);
    }

    @Test
    @DisplayName("食材完整CRUD操作")
    void testIngredientCRUD() throws Exception {
        // ==================== 步骤1：创建食材 ====================
        IngredientRequest createRequest = new IngredientRequest();
        createRequest.setHouseholdId(household.getId());
        createRequest.setStandardIngredientId(standardIngredient.getId());
        createRequest.setQuantity(500.0);
        createRequest.setUnit("g");
        createRequest.setExpirationDate(LocalDate.now().plusDays(7));

        String createResponse = mockMvc.perform(post("/api/inventory/ingredients")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").exists())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Long ingredientId = objectMapper.readTree(createResponse)
                .at("/data/id")
                .asLong();

        // 验证食材已保存
        Ingredient savedIngredient = ingredientRepository.findById(ingredientId).orElse(null);
        assertThat(savedIngredient).isNotNull();
        assertThat(savedIngredient.getHousehold().getId()).isEqualTo(household.getId());
        assertThat(savedIngredient.getQuantity()).isEqualTo(500.0);

        // ==================== 步骤2：获取食材详情 ====================
        mockMvc.perform(get("/api/inventory/ingredients/{id}", ingredientId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(ingredientId))
                .andExpect(jsonPath("$.data.quantity").value(500.0));

        // ==================== 步骤3：获取食材列表 ====================
        mockMvc.perform(get("/api/inventory/ingredients")
                        .param("householdId", household.getId().toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data[0].id").value(ingredientId));

        // ==================== 步骤4：更新食材 ====================
        IngredientRequest updateRequest = new IngredientRequest();
        updateRequest.setHouseholdId(household.getId());
        updateRequest.setStandardIngredientId(standardIngredient.getId());
        updateRequest.setQuantity(300.0);
        updateRequest.setUnit("g");

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

        // ==================== 步骤5：扣减食材库存 ====================
        mockMvc.perform(post("/api/inventory/ingredients/{id}/deduct", ingredientId)
                        .param("amount", "100.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        // 验证扣减
        Ingredient deductedIngredient = ingredientRepository.findById(ingredientId).orElse(null);
        assertThat(deductedIngredient).isNotNull();
        assertThat(deductedIngredient.getQuantity()).isEqualTo(200.0); // 300 - 100 = 200

        // ==================== 步骤6：删除食材 ====================
        mockMvc.perform(delete("/api/inventory/ingredients/{id}", ingredientId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        // 验证删除
        assertThat(ingredientRepository.findById(ingredientId)).isEmpty();
    }

    @Test
    @DisplayName("切换厨具可用性")
    void testToggleUtensilAvailability() throws Exception {
        // Given: 创建标准厨具
        StandardUtensil standardUtensil = new StandardUtensil();
        standardUtensil.setId(2001L);
        standardUtensil.setName("wok");
        standardUtensil = standardUtensilRepository.save(standardUtensil);

        // 创建家庭厨具
        UtensilRequest createRequest = new UtensilRequest();
        createRequest.setHouseholdId(household.getId());
        createRequest.setStandardUtensilId(standardUtensil.getId());
        createRequest.setIsAvailable(false);

        String createResponse = mockMvc.perform(post("/api/inventory/utensils")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andReturn()
                .getResponse()
                .getContentAsString();

        Long utensilId = objectMapper.readTree(createResponse)
                .at("/data/id")
                .asLong();

        // When: 切换可用性
        mockMvc.perform(patch("/api/inventory/utensils/{id}/toggle", utensilId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(true));

        // Then: 验证状态已切换
        HouseholdUtensil updatedUtensil = utensilRepository.findById(utensilId).orElse(null);
        assertThat(updatedUtensil).isNotNull();
        assertThat(updatedUtensil.getIsAvailable()).isTrue();
    }

    @Test
    @DisplayName("切换调料可用性")
    void testToggleSpiceAvailability() throws Exception {
        // Given: 创建标准调料
        StandardSpice standardSpice = new StandardSpice();
        standardSpice.setId(3001L);
        standardSpice.setName("salt");
        standardSpice = standardSpiceRepository.save(standardSpice);

        // 创建家庭调料
        SpiceRequest createRequest = new SpiceRequest();
        createRequest.setHouseholdId(household.getId());
        createRequest.setStandardSpiceId(standardSpice.getId());
        createRequest.setIsAvailable(false);

        String createResponse = mockMvc.perform(post("/api/inventory/spices")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andReturn()
                .getResponse()
                .getContentAsString();

        Long spiceId = objectMapper.readTree(createResponse)
                .at("/data/id")
                .asLong();

        // When: 切换可用性
        mockMvc.perform(patch("/api/inventory/spices/{id}/toggle", spiceId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.isAvailable").value(true));

        // Then: 验证状态已切换
        HouseholdSpice updatedSpice = spiceRepository.findById(spiceId).orElse(null);
        assertThat(updatedSpice).isNotNull();
        assertThat(updatedSpice.getIsAvailable()).isTrue();
    }

    @Test
    @DisplayName("获取标准库列表")
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

    @Test
    @DisplayName("搜索标准食材")
    void testSearchStandardIngredients() throws Exception {
        // Given: 已有标准食材
        StandardIngredient ingredient1 = new StandardIngredient();
        ingredient1.setId(2001L);
        ingredient1.setName("猪肉");
        ingredient1.setCategory("MEAT");
        ingredient1.setPrimaryUnit("g");
        ingredient1.setSecondaryUnit("kg");
        ingredient1.setUnitConversionFactor(0.001);
        ingredient1.setStandardUnit("g");
        standardIngredientRepository.save(ingredient1);

        StandardIngredient ingredient2 = new StandardIngredient();
        ingredient2.setId(2002L);
        ingredient2.setName("牛肉");
        ingredient2.setCategory("MEAT");
        ingredient2.setPrimaryUnit("g");
        ingredient2.setSecondaryUnit("kg");
        ingredient2.setUnitConversionFactor(0.001);
        ingredient2.setStandardUnit("g");
        standardIngredientRepository.save(ingredient2);

        // When & Then: 精确搜索
        mockMvc.perform(get("/api/inventory/standard-ingredients/search")
                        .param("name", "猪肉")
                        .param("fuzzy", "false"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").value("猪肉"));

        // When & Then: 模糊搜索
        mockMvc.perform(get("/api/inventory/standard-ingredients/search")
                        .param("name", "肉")
                        .param("fuzzy", "true"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray())
                // setUp() 已创建了“五花肉”，也会命中“肉”
                .andExpect(jsonPath("$.data.length()").value(3));
    }

    @Test
    @DisplayName("更新食材时更新标准食材ID")
    void testUpdateIngredient_UpdateStandardIngredientId() throws Exception {
        // Given: 创建食材
        IngredientRequest createRequest = new IngredientRequest();
        createRequest.setHouseholdId(household.getId());
        createRequest.setStandardIngredientId(standardIngredient.getId());
        createRequest.setQuantity(500.0);
        createRequest.setUnit("g");

        String createResponse = mockMvc.perform(post("/api/inventory/ingredients")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Long ingredientId = objectMapper.readTree(createResponse)
                .at("/data/id")
                .asLong();

        // 创建新的标准食材
        StandardIngredient newStandardIngredient = new StandardIngredient();
        newStandardIngredient.setId(2001L);
        newStandardIngredient.setName("牛肉");
        newStandardIngredient.setCategory("MEAT");
        newStandardIngredient.setPrimaryUnit("g");
        newStandardIngredient.setSecondaryUnit("kg");
        newStandardIngredient.setUnitConversionFactor(0.001);
        newStandardIngredient.setStandardUnit("g");
        newStandardIngredient = standardIngredientRepository.save(newStandardIngredient);

        // When: 更新食材的标准食材ID
        IngredientRequest updateRequest = new IngredientRequest();
        updateRequest.setHouseholdId(household.getId());
        updateRequest.setStandardIngredientId(newStandardIngredient.getId());
        updateRequest.setQuantity(500.0);
        updateRequest.setUnit("g");

        mockMvc.perform(put("/api/inventory/ingredients/{id}", ingredientId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        // Then: 验证标准食材ID已更新
        Ingredient updatedIngredient = ingredientRepository.findById(ingredientId).orElse(null);
        assertThat(updatedIngredient).isNotNull();
        assertThat(updatedIngredient.getMetadata().getId()).isEqualTo(newStandardIngredient.getId());
    }
}
