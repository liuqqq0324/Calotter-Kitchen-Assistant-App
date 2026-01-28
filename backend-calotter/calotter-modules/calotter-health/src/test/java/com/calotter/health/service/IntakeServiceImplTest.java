package com.calotter.health.service;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.health.service.ai.ManualNutritionEstimator;
import com.calotter.health.service.ai.NutritionEstimate;
import com.calotter.health.service.impl.IntakeServiceImpl;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.User;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.ObjectProvider;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * IntakeServiceImpl 单元测试
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("摄入服务实现测试")
class IntakeServiceImplTest {

    @Mock
    private NutritionLogRepository nutritionLogRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private HouseholdRepository householdRepository;

    @Mock
    private LeftoverDishRepository leftoverDishRepository;

    @Mock
    private NutritionLogService nutritionLogService;

    @Mock
    private NutritionAggregateService nutritionAggregateService;

    @Mock
    private INutritionService nutritionService;

    @Mock
    private ObjectProvider<ManualNutritionEstimator> manualNutritionEstimatorProvider;

    @Mock
    private ManualNutritionEstimator manualNutritionEstimator;

    @InjectMocks
    private IntakeServiceImpl intakeService;

    private User user;
    private Household household;
    private NutritionLog nutritionLog;
    private LeftoverDish leftoverDish;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setUsername("testuser");
        user.setCurrentHouseholdId(1L);

        household = new Household();
        household.setId(1L);
        household.setName("测试家庭");

        nutritionLog = new NutritionLog();
        nutritionLog.setId(100L);
        nutritionLog.setUser(user);
        nutritionLog.setLogDate(LocalDate.now());
        nutritionLog.setSourceType(LogSourceType.MANUAL);
        nutritionLog.setFoodName("fried rice with egg");
        nutritionLog.setEnergy(650);
        nutritionLog.setProtein(18.0);
        nutritionLog.setFat(20.0);
        nutritionLog.setCarbohydrates(80.0);
        nutritionLog.setConsumedPercentage(BigDecimal.valueOf(100.0));
        nutritionLog.setBaseEnergy(650);
        nutritionLog.setBaseProtein(18.0);
        nutritionLog.setBaseFat(20.0);
        nutritionLog.setBaseCarbohydrates(80.0);

        leftoverDish = new LeftoverDish();
        leftoverDish.setId(200L);
        leftoverDish.setHousehold(household);
        leftoverDish.setDishName("红烧肉");
        leftoverDish.setCurrentQuantityGram(300);
        leftoverDish.setInitialQuantityGram(1000);
        leftoverDish.setCaloriesPer100g(200);
        leftoverDish.setProteinPer100g(10.0);
        leftoverDish.setFatPer100g(15.0);
        leftoverDish.setCarbPer100g(5.0);
        leftoverDish.setFiberPer100g(0.5);
    }

    // ==================== getTodayIntakes 测试 ====================

    @Test
    @DisplayName("获取今日摄入 - 手动记录成功")
    void testGetTodayIntakes_Manual_Success() {
        // Given
        LocalDate today = LocalDate.now();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByUserAndLogDateAndSourceType(
                eq(user), eq(today), eq(LogSourceType.MANUAL)))
                .thenReturn(Arrays.asList(nutritionLog));

        // When
        IIntakeService.TodayIntakesResponse response = intakeService.getTodayIntakes(1L, "manual");

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDate()).isEqualTo(today);
        assertThat(response.getSource()).isEqualTo("manual");
        assertThat(response.getItems()).hasSize(1);
        assertThat(response.getItems().get(0).getSourceType()).isEqualTo("manual");
        assertThat(response.getItems().get(0).getManualFoodName()).isEqualTo("fried rice with egg");
    }

    @Test
    @DisplayName("获取今日摄入 - 食谱记录成功")
    void testGetTodayIntakes_Recipe_Success() {
        // Given
        LocalDate today = LocalDate.now();
        NutritionLog leftoverLog = new NutritionLog();
        leftoverLog.setId(101L);
        leftoverLog.setUser(user);
        leftoverLog.setLogDate(today);
        leftoverLog.setSourceType(LogSourceType.LEFTOVER);
        leftoverLog.setFoodName("红烧肉");
        leftoverLog.setDishId(200L);
        leftoverLog.setEnergy(600);
        leftoverLog.setProtein(30.0);
        leftoverLog.setConsumedPercentage(BigDecimal.valueOf(100.0));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByUserAndLogDateAndSourceTypeIn(
                eq(user), eq(today), anyList()))
                .thenReturn(Arrays.asList(leftoverLog));
        when(leftoverDishRepository.findById(200L)).thenReturn(Optional.of(leftoverDish));

        // When
        IIntakeService.TodayIntakesResponse response = intakeService.getTodayIntakes(1L, "recipe");

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getSource()).isEqualTo("recipe");
        assertThat(response.getItems()).hasSize(1);
        assertThat(response.getItems().get(0).getSourceType()).isEqualTo("leftover");
        assertThat(response.getItems().get(0).getLeftoverTitle()).isEqualTo("红烧肉");
    }

    @Test
    @DisplayName("获取今日摄入 - 全部记录成功")
    void testGetTodayIntakes_All_Success() {
        // Given
        LocalDate today = LocalDate.now();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByUserAndLogDate(eq(user), eq(today)))
                .thenReturn(Arrays.asList(nutritionLog));

        // When
        IIntakeService.TodayIntakesResponse response = intakeService.getTodayIntakes(1L, "all");

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getSource()).isEqualTo("all");
        assertThat(response.getItems()).hasSize(1);
    }

    @Test
    @DisplayName("获取今日摄入 - 用户不存在")
    void testGetTodayIntakes_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.getTodayIntakes(999L, "all"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    // ==================== getDishOptions 测试 ====================

    @Test
    @DisplayName("获取菜品选项 - 成功")
    void testGetDishOptions_Success() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverDishRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(leftoverDish));

        // When
        IIntakeService.DishOptionsResponse response = intakeService.getDishOptions(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getOptions()).hasSize(1);
        assertThat(response.getOptions().get(0).getType()).isEqualTo("leftover");
        assertThat(response.getOptions().get(0).getId()).isEqualTo(200L);
        assertThat(response.getOptions().get(0).getTitle()).isEqualTo("红烧肉");
        assertThat(response.getOptions().get(0).getInitialGrams()).isEqualTo(1000);
        assertThat(response.getOptions().get(0).getCurrentGrams()).isEqualTo(300);
    }

    @Test
    @DisplayName("获取菜品选项 - 无家庭")
    void testGetDishOptions_NoHousehold() {
        // Given
        user.setCurrentHouseholdId(null);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user)); // 用于 resolveHousehold

        // When
        IIntakeService.DishOptionsResponse response = intakeService.getDishOptions(1L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getOptions()).isEmpty();
    }

    @Test
    @DisplayName("获取菜品选项 - 过滤零数量")
    void testGetDishOptions_FiltersZeroQuantity() {
        // Given
        LeftoverDish zeroLeftover = new LeftoverDish();
        zeroLeftover.setId(201L);
        zeroLeftover.setHousehold(household);
        zeroLeftover.setDishName("空剩菜");
        zeroLeftover.setCurrentQuantityGram(0);
        zeroLeftover.setInitialQuantityGram(500);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverDishRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(leftoverDish, zeroLeftover));

        // When
        IIntakeService.DishOptionsResponse response = intakeService.getDishOptions(1L);

        // Then: 应该过滤掉数量为0的剩菜
        assertThat(response.getOptions()).hasSize(1);
        assertThat(response.getOptions().get(0).getId()).isEqualTo(200L);
    }

    // ==================== addDishIntake 测试 ====================

    @Test
    @DisplayName("添加菜品摄入 - 成功")
    void testAddDishIntake_Success() {
        // Given
        IIntakeService.AddDishIntakeRequest request = new IIntakeService.AddDishIntakeRequest();
        request.setId(200L);
        request.setType("leftover");
        request.setConsumedPercentage(BigDecimal.valueOf(50.0));

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverDishRepository.findById(200L)).thenReturn(Optional.of(leftoverDish));
        when(nutritionLogRepository.save(any(NutritionLog.class))).thenAnswer(invocation -> {
            NutritionLog log = invocation.getArgument(0);
            log.setId(300L);
            return log;
        });
        when(nutritionLogRepository.findByUserAndLogDateAndSourceTypeIn(
                any(), any(), anyList())).thenReturn(Collections.emptyList());

        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = 
                new INutritionService.WeeklyNutritionSummaryResponse();
        weeklySummary.setWeekStart(LocalDate.now().minusDays(3));
        weeklySummary.setWeekEnd(LocalDate.now().plusDays(3));
        INutritionService.Nutrition consumed = new INutritionService.Nutrition();
        consumed.setEnergy(BigDecimal.valueOf(2000));
        consumed.setFat(BigDecimal.valueOf(60.0));
        consumed.setCarbohydrates(BigDecimal.valueOf(200.0));
        consumed.setProtein(BigDecimal.valueOf(100.0));
        weeklySummary.setConsumed(consumed);
        when(nutritionService.getWeeklyNutritionSummary(1L)).thenReturn(weeklySummary);

        // When
        IIntakeService.AddDishIntakeResponse response = intakeService.addDishIntake(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getAddedIntakes()).hasSize(1);
        assertThat(response.getIntake()).isNotNull();
        verify(nutritionAggregateService, times(1)).rebuildDailyAggregate(eq(user), any(LocalDate.class));
        verify(leftoverDishRepository, times(1)).save(any(LeftoverDish.class));
    }

    @Test
    @DisplayName("添加菜品摄入 - 批量成功")
    void testAddDishIntake_Batch_Success() {
        // Given
        LeftoverDish leftover2 = new LeftoverDish();
        leftover2.setId(201L);
        leftover2.setHousehold(household);
        leftover2.setDishName("糖醋里脊");
        leftover2.setCurrentQuantityGram(200);
        leftover2.setInitialQuantityGram(500);
        leftover2.setCaloriesPer100g(150);
        leftover2.setProteinPer100g(8.0);

        IIntakeService.AddDishIntakeRequest request = new IIntakeService.AddDishIntakeRequest();
        request.setIds(Arrays.asList(200L, 201L));
        request.setType("leftover");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverDishRepository.findById(200L)).thenReturn(Optional.of(leftoverDish));
        when(leftoverDishRepository.findById(201L)).thenReturn(Optional.of(leftover2));
        when(nutritionLogRepository.save(any(NutritionLog.class))).thenAnswer(invocation -> {
            NutritionLog log = invocation.getArgument(0);
            log.setId(300L + (log.getDishId() == 200L ? 0 : 1));
            return log;
        });
        when(nutritionLogRepository.findByUserAndLogDateAndSourceTypeIn(
                any(), any(), anyList())).thenReturn(Collections.emptyList());

        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = 
                new INutritionService.WeeklyNutritionSummaryResponse();
        weeklySummary.setWeekStart(LocalDate.now().minusDays(3));
        weeklySummary.setWeekEnd(LocalDate.now().plusDays(3));
        INutritionService.Nutrition consumed = new INutritionService.Nutrition();
        consumed.setEnergy(BigDecimal.valueOf(2000));
        consumed.setFat(BigDecimal.valueOf(60.0));
        consumed.setCarbohydrates(BigDecimal.valueOf(200.0));
        consumed.setProtein(BigDecimal.valueOf(100.0));
        weeklySummary.setConsumed(consumed);
        when(nutritionService.getWeeklyNutritionSummary(1L)).thenReturn(weeklySummary);

        // When
        IIntakeService.AddDishIntakeResponse response = intakeService.addDishIntake(1L, request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getAddedIntakes()).hasSize(2);
        verify(nutritionLogRepository, times(2)).save(any(NutritionLog.class));
    }

    @Test
    @DisplayName("添加菜品摄入 - 无效类型")
    void testAddDishIntake_InvalidType() {
        // Given
        IIntakeService.AddDishIntakeRequest request = new IIntakeService.AddDishIntakeRequest();
        request.setId(200L);
        request.setType("invalid");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        // When & Then
        assertThatThrownBy(() -> intakeService.addDishIntake(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Invalid type");
    }

    @Test
    @DisplayName("添加菜品摄入 - 未提供ID")
    void testAddDishIntake_NoIdOrIds() {
        // Given
        IIntakeService.AddDishIntakeRequest request = new IIntakeService.AddDishIntakeRequest();
        request.setType("leftover");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));

        // When & Then
        assertThatThrownBy(() -> intakeService.addDishIntake(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("id or ids is required");
    }

    @Test
    @DisplayName("添加菜品摄入 - 剩菜不存在")
    void testAddDishIntake_LeftoverNotFound() {
        // Given
        IIntakeService.AddDishIntakeRequest request = new IIntakeService.AddDishIntakeRequest();
        request.setId(999L);
        request.setType("leftover");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(leftoverDishRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.addDishIntake(1L, request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Leftover 不存在");
    }

    // ==================== updateIntakePercentage 测试 ====================

    @Test
    @DisplayName("更新摄入百分比 - 成功")
    void testUpdateIntakePercentage_Success() {
        // Given
        nutritionLog.setBaseEnergy(1000);
        nutritionLog.setBaseProtein(50.0);
        nutritionLog.setBaseFat(30.0);
        nutritionLog.setBaseCarbohydrates(100.0);
        nutritionLog.setConsumedPercentage(BigDecimal.valueOf(50.0));
        nutritionLog.setEnergy(500);
        nutritionLog.setProtein(25.0);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByIdAndUser(100L, user))
                .thenReturn(Optional.of(nutritionLog));
        when(nutritionLogRepository.save(any(NutritionLog.class))).thenReturn(nutritionLog);

        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = 
                new INutritionService.WeeklyNutritionSummaryResponse();
        weeklySummary.setWeekStart(LocalDate.now().minusDays(3));
        weeklySummary.setWeekEnd(LocalDate.now().plusDays(3));
        INutritionService.Nutrition consumed = new INutritionService.Nutrition();
        consumed.setEnergy(BigDecimal.valueOf(2000));
        consumed.setFat(BigDecimal.valueOf(60.0));
        consumed.setCarbohydrates(BigDecimal.valueOf(200.0));
        consumed.setProtein(BigDecimal.valueOf(100.0));
        weeklySummary.setConsumed(consumed);
        when(nutritionService.getWeeklyNutritionSummary(1L)).thenReturn(weeklySummary);

        // When
        IIntakeService.UpdateIntakeResponse response = 
                intakeService.updateIntakePercentage(1L, 100L, BigDecimal.valueOf(80.0));

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getIntake()).isNotNull();
        assertThat(response.getIntake().getConsumedPercentage()).isEqualByComparingTo(BigDecimal.valueOf(80.0));
        assertThat(response.getWeeklySummary()).isNotNull();

        verify(nutritionLogRepository, times(1)).save(argThat(log ->
                log.getConsumedPercentage().compareTo(BigDecimal.valueOf(80.0)) == 0
        ));
        verify(nutritionAggregateService, times(1)).rebuildDailyAggregate(eq(user), any(LocalDate.class));
    }

    @Test
    @DisplayName("更新摄入百分比 - 剩菜同步数量")
    void testUpdateIntakePercentage_Leftover_SyncsQuantity() {
        // Given
        NutritionLog leftoverLog = new NutritionLog();
        leftoverLog.setId(101L);
        leftoverLog.setUser(user);
        leftoverLog.setLogDate(LocalDate.now());
        leftoverLog.setSourceType(LogSourceType.LEFTOVER);
        leftoverLog.setDishId(200L);
        leftoverLog.setBaseEnergy(600);
        leftoverLog.setBaseProtein(30.0);
        leftoverLog.setConsumedPercentage(BigDecimal.valueOf(30.0));
        leftoverLog.setQuantity(300.0);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByIdAndUser(101L, user))
                .thenReturn(Optional.of(leftoverLog));
        when(leftoverDishRepository.findById(200L)).thenReturn(Optional.of(leftoverDish));
        when(nutritionLogRepository.save(any(NutritionLog.class))).thenReturn(leftoverLog);

        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = 
                new INutritionService.WeeklyNutritionSummaryResponse();
        weeklySummary.setWeekStart(LocalDate.now().minusDays(3));
        weeklySummary.setWeekEnd(LocalDate.now().plusDays(3));
        INutritionService.Nutrition consumed = new INutritionService.Nutrition();
        consumed.setEnergy(BigDecimal.valueOf(2000));
        consumed.setFat(BigDecimal.valueOf(60.0));
        consumed.setCarbohydrates(BigDecimal.valueOf(200.0));
        consumed.setProtein(BigDecimal.valueOf(100.0));
        weeklySummary.setConsumed(consumed);
        when(nutritionService.getWeeklyNutritionSummary(1L)).thenReturn(weeklySummary);

        // When
        IIntakeService.UpdateIntakeResponse response = 
                intakeService.updateIntakePercentage(1L, 101L, BigDecimal.valueOf(50.0));

        // Then
        assertThat(response).isNotNull();
        verify(leftoverDishRepository, times(1)).save(any(LeftoverDish.class));
    }

    @Test
    @DisplayName("更新摄入百分比 - 用户不存在")
    void testUpdateIntakePercentage_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.updateIntakePercentage(999L, 100L, BigDecimal.valueOf(80.0)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
    @DisplayName("更新摄入百分比 - 摄入记录不存在")
    void testUpdateIntakePercentage_IntakeNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByIdAndUser(999L, user))
                .thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.updateIntakePercentage(1L, 999L, BigDecimal.valueOf(80.0)))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Intake record not found");
    }

    // ==================== addManualIntake 测试 ====================

    @Test
    @DisplayName("添加手动摄入 - 成功")
    void testAddManualIntake_Success() {
        // Given
        LocalDate date = LocalDate.now();
        String foodName = "fried rice with egg";
        String portionDescription = "1 bowl";

        NutritionEstimate estimate = new NutritionEstimate(
                BigDecimal.valueOf(650),
                BigDecimal.valueOf(18.0),
                BigDecimal.valueOf(20.0),
                BigDecimal.valueOf(80.0),
                "test-source"
        );

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(manualNutritionEstimatorProvider.getIfAvailable()).thenReturn(manualNutritionEstimator);
        when(manualNutritionEstimator.estimate(foodName, portionDescription)).thenReturn(estimate);
        when(nutritionLogService.createManual(any())).thenReturn(nutritionLog);
        when(nutritionLogRepository.findByUserAndLogDateAndSourceType(
                eq(user), eq(date), eq(LogSourceType.MANUAL)))
                .thenReturn(Arrays.asList(nutritionLog));

        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = 
                new INutritionService.WeeklyNutritionSummaryResponse();
        weeklySummary.setWeekStart(LocalDate.now().minusDays(3));
        weeklySummary.setWeekEnd(LocalDate.now().plusDays(3));
        INutritionService.Nutrition consumed = new INutritionService.Nutrition();
        consumed.setEnergy(BigDecimal.valueOf(2000));
        consumed.setFat(BigDecimal.valueOf(60.0));
        consumed.setCarbohydrates(BigDecimal.valueOf(200.0));
        consumed.setProtein(BigDecimal.valueOf(100.0));
        weeklySummary.setConsumed(consumed);
        when(nutritionService.getWeeklyNutritionSummary(1L)).thenReturn(weeklySummary);

        // When
        IIntakeService.AddManualIntakeResponse response = 
                intakeService.addManualIntake(1L, date, foodName, portionDescription);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getIntake()).isNotNull();
        assertThat(response.getIntake().getManualFoodName()).isEqualTo(foodName);
        assertThat(response.getWeeklySummary()).isNotNull();
        verify(nutritionLogService, times(1)).createManual(any());
    }

    @Test
    @DisplayName("添加手动摄入 - 用户不存在")
    void testAddManualIntake_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.addManualIntake(999L, LocalDate.now(), "food", "1 bowl"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
    @DisplayName("添加手动摄入 - 估算器不存在")
    void testAddManualIntake_EstimatorNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(manualNutritionEstimatorProvider.getIfAvailable()).thenReturn(null);

        // When & Then
        assertThatThrownBy(() -> intakeService.addManualIntake(1L, LocalDate.now(), "food", "1 bowl"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("ManualNutritionEstimator bean not found");
    }

    // ==================== deleteIntake 测试 ====================

    @Test
    @DisplayName("删除摄入 - 成功")
    void testDeleteIntake_Success() {
        // Given
        LocalDate date = LocalDate.now();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByIdAndUser(100L, user))
                .thenReturn(Optional.of(nutritionLog));
        when(nutritionLogRepository.findByUserAndLogDateAndSourceType(
                eq(user), eq(date), eq(LogSourceType.MANUAL)))
                .thenReturn(Collections.emptyList());

        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = 
                new INutritionService.WeeklyNutritionSummaryResponse();
        weeklySummary.setWeekStart(LocalDate.now().minusDays(3));
        weeklySummary.setWeekEnd(LocalDate.now().plusDays(3));
        INutritionService.Nutrition consumed = new INutritionService.Nutrition();
        consumed.setEnergy(BigDecimal.valueOf(2000));
        consumed.setFat(BigDecimal.valueOf(60.0));
        consumed.setCarbohydrates(BigDecimal.valueOf(200.0));
        consumed.setProtein(BigDecimal.valueOf(100.0));
        weeklySummary.setConsumed(consumed);
        when(nutritionService.getWeeklyNutritionSummary(1L)).thenReturn(weeklySummary);

        // When
        IIntakeService.DeleteIntakeResponse response = intakeService.deleteIntake(1L, 100L);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getDeletedIntakeId()).isEqualTo(100L);
        assertThat(response.getDate()).isEqualTo(date);
        verify(nutritionLogRepository, times(1)).delete(nutritionLog);
        verify(nutritionAggregateService, times(1)).rebuildDailyAggregate(eq(user), eq(date));
    }

    @Test
    @DisplayName("删除摄入 - 用户不存在")
    void testDeleteIntake_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.deleteIntake(999L, 100L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
    @DisplayName("删除摄入 - 摄入记录不存在")
    void testDeleteIntake_IntakeNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(nutritionLogRepository.findByIdAndUser(999L, user))
                .thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.deleteIntake(1L, 999L))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Intake record not found");
    }
}
