package com.calotter.health.service;

import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.repository.DishRepository;
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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.ObjectProvider;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * IntakeServiceImpl 单元测试
 */
@ExtendWith(MockitoExtension.class)
class IntakeServiceImplTest {

    @Mock
    private NutritionLogRepository nutritionLogRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private HouseholdRepository householdRepository;

    @Mock
    private CookingSessionRepository cookingSessionRepository;

    @Mock
    private LeftoverDishRepository leftoverDishRepository;

    @Mock
    private DishRepository dishRepository;

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
    private Dish dish;
    private CookingSession cookingSession;

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

        dish = new Dish();
        dish.setId(200L);
        dish.setName("红烧肉");
        dish.setTotalCalories(2000);
        dish.setTotalProtein(100.0);
        dish.setTotalFat(150.0);
        dish.setTotalCarb(50.0);
        dish.setTotalWeightGram(1000);

        cookingSession = new CookingSession();
        cookingSession.setId(300L);
        cookingSession.setHouseholdId(1L);
        cookingSession.setStatus(CookingSession.SessionStatus.COOKED);
        cookingSession.setFinalDish(dish);
        cookingSession.setUpdateTime(LocalDateTime.now());
    }

    // ==================== getTodayIntakes 测试 ====================

    @Test
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
    void testGetTodayIntakes_Recipe_Success() {
        // Given
        LocalDate today = LocalDate.now();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(cookingSessionRepository.findByHouseholdId(1L))
                .thenReturn(Arrays.asList(cookingSession));
        when(dishRepository.findAllById(any())).thenReturn(Arrays.asList(dish));
        when(nutritionLogRepository.findByUserAndLogDateAndSourceType(
                eq(user), eq(today), eq(LogSourceType.APP_COOKING)))
                .thenReturn(Collections.emptyList());

        // When
        IIntakeService.TodayIntakesResponse response = intakeService.getTodayIntakes(1L, "recipe");

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getSource()).isEqualTo("recipe");
        // 验证返回了菜谱相关的摄入记录
    }

    @Test
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
    void testGetTodayIntakes_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.getTodayIntakes(999L, "all"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    // ==================== updateIntakePercentage 测试 ====================

    @Test
    void testUpdateIntakePercentage_Success() {
        // Given
        nutritionLog.setBaseEnergy(1000);
        nutritionLog.setBaseProtein(50.0);
        nutritionLog.setBaseFat(30.0);
        nutritionLog.setBaseCarbohydrates(100.0);
        nutritionLog.setConsumedPercentage(BigDecimal.valueOf(50.0));

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

        // 验证营养值被重新计算
        verify(nutritionLogRepository, times(1)).save(argThat(log ->
                log.getConsumedPercentage().compareTo(BigDecimal.valueOf(80.0)) == 0
        ));
        verify(nutritionAggregateService, times(1)).rebuildDailyAggregate(eq(user), any(LocalDate.class));
    }

    @Test
    void testUpdateIntakePercentage_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.updateIntakePercentage(999L, 100L, BigDecimal.valueOf(80.0)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
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
    void testAddManualIntake_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.addManualIntake(999L, LocalDate.now(), "food", "1 bowl"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
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
    void testDeleteIntake_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> intakeService.deleteIntake(999L, 100L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("用户不存在");
    }

    @Test
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

