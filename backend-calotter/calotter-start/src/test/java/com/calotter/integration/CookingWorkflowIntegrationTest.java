package com.calotter.integration;

import com.calotter.cooking.controller.dto.FinishCookingRequest;
import com.calotter.cooking.controller.dto.StartCookingRequest;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.common.core.repository.StandardIngredientRepository;
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

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 烹饪工作流集成测试
 * 
 * 测试完整的烹饪流程，包括：
 * - 开始烹饪（创建Session）
 * - 完成烹饪（保存快照、扣减库存、创建剩菜）
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class CookingWorkflowIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private HouseholdRepository householdRepository;

    @Autowired
    private CookingSessionRepository sessionRepository;

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private IngredientRepository ingredientRepository;

    @Autowired
    private LeftoverDishRepository leftoverDishRepository;

    @Autowired
    private StandardIngredientRepository standardIngredientRepository;

    private User user;
    private Household household;
    private Dish dish;
    private Ingredient ingredient;

    @BeforeEach
    void setUp() {
        // 清理测试数据
        leftoverDishRepository.deleteAll();
        ingredientRepository.deleteAll();
        sessionRepository.deleteAll();
        dishRepository.deleteAll();
        householdRepository.deleteAll();
        userRepository.deleteAll();
        standardIngredientRepository.deleteAll();

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

        // 设置用户的当前家庭
        user.setCurrentHouseholdId(household.getId());
        userRepository.save(user);

        // 创建测试菜品
        dish = new Dish();
        dish.setName("红烧肉");
        dish.setTotalCalories(2000);
        dish.setTotalProtein(100.0);
        dish.setTotalFat(150.0);
        dish.setTotalCarb(50.0);
        dish.setTotalWeightGram(1000);
        dish = dishRepository.save(dish);

        // 创建标准食材
        StandardIngredient standardIngredient = new StandardIngredient();
        standardIngredient.setId(1001L);
        standardIngredient.setName("五花肉");
        standardIngredient.setCategory("MEAT");
        standardIngredient.setPrimaryUnit("g");
        standardIngredient.setSecondaryUnit("kg");
        standardIngredient.setUnitConversionFactor(0.001);
        standardIngredient.setStandardUnit("g");
        standardIngredient = standardIngredientRepository.save(standardIngredient);
        
        // 创建测试食材
        ingredient = new Ingredient();
        ingredient.setHousehold(household);
        ingredient.setQuantity(1000.0);
        ingredient.setUnit("g");
        ingredient.setMetadata(standardIngredient);
        ingredient = ingredientRepository.save(ingredient);
    }

    @Test
    @DisplayName("完整烹饪流程：开始烹饪并完成烹饪")
    void testCookingWorkflow_StartAndFinish() throws Exception {
        // ==================== 步骤1：开始烹饪 ====================
        StartCookingRequest startRequest = new StartCookingRequest();
        startRequest.setHouseholdId(household.getId());
        startRequest.setInitiatorId(user.getId());
        startRequest.setDishId(dish.getId());
        startRequest.setMenuId(1);

        String startResponse = mockMvc.perform(post("/api/cooking/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(startRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").exists())
                .andReturn()
                .getResponse()
                .getContentAsString();

        // 解析sessionId
        Long sessionId = objectMapper.readTree(startResponse)
                .at("/data")
                .asLong();

        // 验证Session已创建
        CookingSession session = sessionRepository.findById(sessionId).orElse(null);
        assertThat(session).isNotNull();
        assertThat(session.getHouseholdId()).isEqualTo(household.getId());
        assertThat(session.getInitiatorId()).isEqualTo(user.getId());
        assertThat(session.getMenuId()).isEqualTo(1);
        assertThat(session.getStatus()).isEqualTo(CookingSession.SessionStatus.PENDING);
        assertThat(session.getFinalDish()).isNotNull();
        assertThat(session.getFinalDish().getId()).isEqualTo(dish.getId());

        // ==================== 步骤2：完成烹饪 ====================
        FinishCookingRequest finishRequest = new FinishCookingRequest();
        finishRequest.setSessionId(sessionId);
        finishRequest.setConsumedAt(LocalDateTime.now());

        // 设置最终用料（扣减库存）
        FinishCookingRequest.FinalIngredient finalIngredient = new FinishCookingRequest.FinalIngredient();
        finalIngredient.setName("五花肉");
        finalIngredient.setSourceType("INVENTORY");
        finalIngredient.setAmountValue(500.0);
        finalIngredient.setAmountUnit("g");
        finishRequest.setFinalIngredients(Arrays.asList(finalIngredient));

        // 设置营养快照
        FinishCookingRequest.NutritionSnapshot nutrition = new FinishCookingRequest.NutritionSnapshot();
        nutrition.setCalories(2000.0);
        nutrition.setProtein(100.0);
        nutrition.setFat(150.0);
        nutrition.setCarbs(50.0);
        finishRequest.setTotalNutrition(nutrition);

        mockMvc.perform(post("/api/cooking/finish")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(finishRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(sessionId))
                .andExpect(jsonPath("$.data.status").value("COOKED"));

        // 验证Session状态已更新
        CookingSession updatedSession = sessionRepository.findById(sessionId).orElse(null);
        assertThat(updatedSession).isNotNull();
        assertThat(updatedSession.getStatus()).isEqualTo(CookingSession.SessionStatus.COOKED);
        assertThat(updatedSession.getTotalNutritionSnapshot()).isNotNull();

        // 验证库存已扣减
        Ingredient updatedIngredient = ingredientRepository.findById(ingredient.getId()).orElse(null);
        assertThat(updatedIngredient).isNotNull();
        assertThat(updatedIngredient.getQuantity()).isEqualTo(500.0); // 1000 - 500 = 500

        // 验证剩菜已创建
        List<LeftoverDish> leftovers = leftoverDishRepository.findByHouseholdId(household.getId());
        assertThat(leftovers).hasSize(1);
        assertThat(leftovers.get(0).getOriginalDishId()).isEqualTo(dish.getId());
        assertThat(leftovers.get(0).getCurrentQuantityGram()).isEqualTo(1000); // 初始100%
    }

    @Test
    @DisplayName("使用菜谱开始烹饪")
    void testCookingWorkflow_StartWithRecipes() throws Exception {
        // Given: 创建RecipeDTO
        MenuDTO.RecipeDTO recipeDto = new MenuDTO.RecipeDTO();
        recipeDto.setTitle("红烧肉");
        recipeDto.setShortDescription("经典红烧肉");
        recipeDto.setCookingTimeMin(60);
        recipeDto.setDifficulty("MEDIUM");

        StartCookingRequest startRequest = new StartCookingRequest();
        startRequest.setHouseholdId(household.getId());
        startRequest.setInitiatorId(user.getId());
        startRequest.setRecipes(Arrays.asList(recipeDto));
        startRequest.setMenuId(1);

        // When: 开始烹饪
        String startResponse = mockMvc.perform(post("/api/cooking/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(startRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andReturn()
                .getResponse()
                .getContentAsString();

        // Then: 验证Session和Dish已创建
        Long sessionId = objectMapper.readTree(startResponse)
                .at("/data")
                .asLong();

        CookingSession session = sessionRepository.findById(sessionId).orElse(null);
        assertThat(session).isNotNull();
        assertThat(session.getDishes()).isNotEmpty();
        assertThat(session.getFinalDish()).isNotNull();
    }

    @Test
    @DisplayName("完成烹饪时记录用餐者信息")
    void testCookingWorkflow_FinishWithDiners() throws Exception {
        // Given: 创建Session
        StartCookingRequest startRequest = new StartCookingRequest();
        startRequest.setHouseholdId(household.getId());
        startRequest.setInitiatorId(user.getId());
        startRequest.setDishId(dish.getId());

        String startResponse = mockMvc.perform(post("/api/cooking/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(startRequest)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Long sessionId = objectMapper.readTree(startResponse)
                .at("/data")
                .asLong();

        // When: 完成烹饪（带用餐者信息）
        FinishCookingRequest finishRequest = new FinishCookingRequest();
        finishRequest.setSessionId(sessionId);
        finishRequest.setConsumedAt(LocalDateTime.now());

        FinishCookingRequest.DinerConsumption diner = new FinishCookingRequest.DinerConsumption();
        diner.setUserId(user.getId());
        diner.setPortionPercentage(0.5); // 50%
        finishRequest.setDiners(Arrays.asList(diner));

        mockMvc.perform(post("/api/cooking/finish")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(finishRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        // Then: 验证Session状态
        CookingSession session = sessionRepository.findById(sessionId).orElse(null);
        assertThat(session).isNotNull();
        assertThat(session.getStatus()).isEqualTo(CookingSession.SessionStatus.COOKED);
    }

    @Test
    @DisplayName("使用不存在的家庭ID开始烹饪应返回错误")
    void testCookingWorkflow_StartWithInvalidHousehold() throws Exception {
        // Given: 使用不存在的householdId
        StartCookingRequest startRequest = new StartCookingRequest();
        startRequest.setHouseholdId(999L);
        startRequest.setInitiatorId(user.getId());
        startRequest.setDishId(dish.getId());

        // When & Then: 应该返回错误
        mockMvc.perform(post("/api/cooking/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(startRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(400));
    }

    @Test
    @DisplayName("完成烹饪时部分完成菜品")
    void testCookingWorkflow_FinishWithPartialDishes() throws Exception {
        // Given: 创建Session
        StartCookingRequest startRequest = new StartCookingRequest();
        startRequest.setHouseholdId(household.getId());
        startRequest.setInitiatorId(user.getId());
        startRequest.setDishId(dish.getId());

        String startResponse = mockMvc.perform(post("/api/cooking/start")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(startRequest)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        Long sessionId = objectMapper.readTree(startResponse)
                .at("/data")
                .asLong();

        // When: 完成烹饪（自动完成session中的所有dish）
        FinishCookingRequest finishRequest = new FinishCookingRequest();
        finishRequest.setSessionId(sessionId);
        finishRequest.setConsumedAt(LocalDateTime.now());
        // 不再需要设置 completedDishIds，系统会自动完成session中的所有dish

        mockMvc.perform(post("/api/cooking/finish")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(finishRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.status").value("COOKED"));

        // Then: 验证Session状态
        CookingSession session = sessionRepository.findById(sessionId).orElse(null);
        assertThat(session).isNotNull();
        assertThat(session.getStatus()).isEqualTo(CookingSession.SessionStatus.COOKED);
    }
}
