package com.calotter.health.service;

import com.calotter.health.domain.entity.DailyNutrientAggregate;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.repository.DailyNutrientAggregateRepository;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.user.domain.entity.User;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.repository.HealthGoalRepository;
import com.calotter.user.service.UserHealthService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * NutritionAggregateService 单元测试
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("营养聚合服务测试")
class NutritionAggregateServiceTest {

    @Mock
    private DailyNutrientAggregateRepository aggregateRepository;

    @Mock
    private NutritionLogRepository nutritionLogRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private HealthGoalRepository healthGoalRepository;

    @Mock
    private UserHealthService userHealthService;

    @InjectMocks
    private NutritionAggregateService aggregateService;

    private User user;
    private HealthGoal goal;
    private NutritionLog log;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1L);
        user.setUsername("测试用户");

        goal = new HealthGoal();
        goal.setId(1L);
        goal.setUser(user);
        goal.setStatus(1); // ACTIVE
        goal.setDailyCalories(2000);
        goal.setProtein(100);
        goal.setFat(60);
        goal.setCarb(300);
        goal.setFiber(30);

        log = new NutritionLog();
        log.setId(1L);
        log.setUser(user);
        log.setLogDate(LocalDate.now());
        log.setEnergy(500);
        log.setProtein(25.0);
        log.setFat(15.0);
        log.setCarbohydrates(50.0);
        log.setFiber(5.0);
    }

    @Test
    @DisplayName("更新聚合 - 新记录")
    void testUpdateAggregate_NewRecord() {
        // Given: 聚合表不存在，需要创建新记录
        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.empty());
        when(healthGoalRepository.findByUserAndStatus(user, 1))
            .thenReturn(goal);
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        aggregateService.updateAggregate(log);

        // Then: 应该创建新记录并设置快照目标值
        ArgumentCaptor<DailyNutrientAggregate> captor = 
            ArgumentCaptor.forClass(DailyNutrientAggregate.class);
        verify(aggregateRepository).save(captor.capture());

        DailyNutrientAggregate saved = captor.getValue();
        assertThat(saved.getUser()).isEqualTo(user);
        assertThat(saved.getDate()).isEqualTo(LocalDate.now());
        assertThat(saved.getTotalEnergy()).isEqualTo(500);
        assertThat(saved.getTotalProtein()).isEqualTo(25.0);
        assertThat(saved.getGoalEnergySnapshot()).isEqualTo(2000);
        assertThat(saved.getGoalProteinSnapshot()).isEqualTo(100);
    }

    @Test
    @DisplayName("更新聚合 - 累加")
    void testUpdateAggregate_Accumulate() {
        // Given: 已存在聚合记录
        DailyNutrientAggregate existing = new DailyNutrientAggregate();
        existing.setId(1L);
        existing.setUser(user);
        existing.setDate(LocalDate.now());
        existing.setTotalEnergy(500);
        existing.setTotalProtein(25.0);
        existing.setTotalFat(15.0);
        existing.setTotalCarbohydrates(50.0);
        existing.setTotalFiber(5.0);

        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.of(existing));
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When: 添加第二条日志
        aggregateService.updateAggregate(log);

        // Then: 应该累加
        ArgumentCaptor<DailyNutrientAggregate> captor = 
            ArgumentCaptor.forClass(DailyNutrientAggregate.class);
        verify(aggregateRepository).save(captor.capture());

        DailyNutrientAggregate saved = captor.getValue();
        assertThat(saved.getTotalEnergy()).isEqualTo(1000); // 500 + 500
        assertThat(saved.getTotalProtein()).isEqualTo(50.0); // 25.0 + 25.0
        assertThat(saved.getTotalFat()).isEqualTo(30.0); // 15.0 + 15.0
    }

    @Test
    @DisplayName("更新聚合 - 无目标")
    void testUpdateAggregate_NoGoal() {
        // Given: 没有健康目标
        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.empty());
        when(healthGoalRepository.findByUserAndStatus(user, 1))
            .thenReturn(null);
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        aggregateService.updateAggregate(log);

        // Then: 目标快照应该为null
        ArgumentCaptor<DailyNutrientAggregate> captor = 
            ArgumentCaptor.forClass(DailyNutrientAggregate.class);
        verify(aggregateRepository).save(captor.capture());

        DailyNutrientAggregate saved = captor.getValue();
        assertThat(saved.getGoalEnergySnapshot()).isNull();
        assertThat(saved.getTotalEnergy()).isEqualTo(500);
    }

    @Test
    @DisplayName("更新聚合 - null值")
    void testUpdateAggregate_NullValues() {
        // Given: 日志中的某些营养值为null
        log.setEnergy(null);
        log.setProtein(null);

        DailyNutrientAggregate existing = new DailyNutrientAggregate();
        existing.setTotalEnergy(500);
        existing.setTotalProtein(25.0);

        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.of(existing));
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        aggregateService.updateAggregate(log);

        // Then: null值应该被当作0处理
        ArgumentCaptor<DailyNutrientAggregate> captor = 
            ArgumentCaptor.forClass(DailyNutrientAggregate.class);
        verify(aggregateRepository).save(captor.capture());

        DailyNutrientAggregate saved = captor.getValue();
        assertThat(saved.getTotalEnergy()).isEqualTo(500); // 500 + 0
        assertThat(saved.getTotalProtein()).isEqualTo(25.0); // 25.0 + 0.0
    }

    @Test
    @DisplayName("重建日聚合 - 成功")
    void testRebuildDailyAggregate_Success() {
        // Given
        NutritionLog log2 = new NutritionLog();
        log2.setId(2L);
        log2.setUser(user);
        log2.setLogDate(LocalDate.now());
        log2.setEnergy(300);
        log2.setProtein(15.0);
        log2.setFat(10.0);
        log2.setCarbohydrates(30.0);
        log2.setFiber(3.0);

        when(nutritionLogRepository.findByUserAndLogDate(user, LocalDate.now()))
            .thenReturn(Arrays.asList(log, log2));
        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.empty());
        
        UserHealthService.UserHealthInfo healthInfo = new UserHealthService.UserHealthInfo();
        healthInfo.setDailyEnergy(2000);
        healthInfo.setDailyProtein(100);
        healthInfo.setDailyFat(60);
        healthInfo.setDailyCarbohydrates(300);
        healthInfo.setDailyFiber(30);
        when(userHealthService.getUserHealthInfo(user.getId())).thenReturn(healthInfo);
        
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        DailyNutrientAggregate result = aggregateService.rebuildDailyAggregate(user, LocalDate.now());

        // Then: 应该汇总所有日志
        assertThat(result).isNotNull();
        assertThat(result.getTotalEnergy()).isEqualTo(800); // 500 + 300
        assertThat(result.getTotalProtein()).isEqualTo(40.0); // 25.0 + 15.0
        assertThat(result.getGoalEnergySnapshot()).isEqualTo(2000);
    }

    @Test
    @DisplayName("重建日聚合 - 已存在记录")
    void testRebuildDailyAggregate_ExistingRecord() {
        // Given: 已存在聚合记录
        DailyNutrientAggregate existing = new DailyNutrientAggregate();
        existing.setId(1L);
        existing.setUser(user);
        existing.setDate(LocalDate.now());
        existing.setTotalEnergy(1000);
        existing.setTotalProtein(50.0);

        when(nutritionLogRepository.findByUserAndLogDate(user, LocalDate.now()))
            .thenReturn(Arrays.asList(log));
        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.of(existing));
        
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        DailyNutrientAggregate result = aggregateService.rebuildDailyAggregate(user, LocalDate.now());

        // Then: 应该覆盖写回，而不是累加
        assertThat(result.getTotalEnergy()).isEqualTo(500); // 覆盖为500，不是1000+500
        assertThat(result.getTotalProtein()).isEqualTo(25.0);
    }

    @Test
    @DisplayName("获取周报告 - 成功")
    void testGetWeeklyReport_Success() {
        // Given: 7天的聚合数据
        LocalDate weekStart = LocalDate.of(2024, 1, 1); // 周一
        LocalDate weekEnd = weekStart.plusDays(6); // 周日

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        
        // Mock UserHealthService
        UserHealthService.UserHealthInfo healthInfo = new UserHealthService.UserHealthInfo();
        healthInfo.setDailyEnergy(2000);
        healthInfo.setDailyProtein(100);
        healthInfo.setDailyFat(60);
        healthInfo.setDailyCarbohydrates(300);
        healthInfo.setDailyFiber(30);
        healthInfo.setBmi(java.math.BigDecimal.valueOf(22.3));
        healthInfo.setGoalType("fat_loss");
        when(userHealthService.getUserHealthInfo(1L)).thenReturn(healthInfo);

        // 创建7天的聚合数据
        List<DailyNutrientAggregate> aggregates = Arrays.asList(
            createAggregate(weekStart, 2000, 100.0),
            createAggregate(weekStart.plusDays(1), 1800, 90.0),
            createAggregate(weekStart.plusDays(2), 2200, 110.0),
            createAggregate(weekStart.plusDays(3), 1900, 95.0),
            createAggregate(weekStart.plusDays(4), 2100, 105.0),
            createAggregate(weekStart.plusDays(5), 1950, 97.5),
            createAggregate(weekStart.plusDays(6), 2050, 102.5)
        );

        when(aggregateRepository.findByUserAndDateBetween(user, weekStart, weekEnd))
            .thenReturn(aggregates);

        // When
        com.calotter.health.controller.dto.WeeklyReportVO report = 
            aggregateService.getWeeklyReport(1L, weekStart);

        // Then
        assertThat(report).isNotNull();
        assertThat(report.getWeekStart()).isEqualTo(weekStart);
        assertThat(report.getWeekEnd()).isEqualTo(weekEnd);

        // 验证周目标：2000 * 7 = 14000
        assertThat(report.getWeeklyTarget().getEnergy()).isEqualTo(14000);
        assertThat(report.getWeeklyTarget().getProtein()).isEqualTo(700.0); // 100 * 7

        // 验证周实际：7天累计
        assertThat(report.getWeeklyActual().getEnergy()).isEqualTo(14000); // 总和
        assertThat(report.getWeeklyActual().getProtein()).isEqualTo(700.0);

        // 验证每日详情
        assertThat(report.getDailyReports()).hasSize(7);
        assertThat(report.getDailyReports().get(0).getDate()).isEqualTo(weekStart);
        assertThat(report.getDailyReports().get(0).getActual().getEnergy()).isEqualTo(2000);
    }

    @Test
    @DisplayName("获取周报告 - 无目标")
    void testGetWeeklyReport_NoGoal() {
        // Given: 没有健康目标
        LocalDate weekStart = LocalDate.now().minusDays(7);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        
        // Mock UserHealthService 返回空目标（使用默认值）
        UserHealthService.UserHealthInfo healthInfo = new UserHealthService.UserHealthInfo();
        healthInfo.setDailyEnergy(null); // 没有目标
        healthInfo.setDailyProtein(null);
        when(userHealthService.getUserHealthInfo(1L)).thenReturn(healthInfo);
        
        when(aggregateRepository.findByUserAndDateBetween(any(), any(), any()))
            .thenReturn(Arrays.asList(createAggregate(LocalDate.now(), 2000, 100.0)));

        // When
        com.calotter.health.controller.dto.WeeklyReportVO report = 
            aggregateService.getWeeklyReport(1L, weekStart);

        // Then: 目标应该为null（当healthInfo中没有目标时）
        assertThat(report).isNotNull();
        assertThat(report.getWeeklyTarget()).isNull();
    }

    @Test
    @DisplayName("获取周报告 - 用户不存在")
    void testGetWeeklyReport_UserNotFound() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> aggregateService.getWeeklyReport(999L, LocalDate.now()))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("用户不存在");
    }

    @Test
    @DisplayName("获取或创建日聚合 - 已存在")
    void testGetOrCreateDailyAggregate_Existing() {
        // Given
        DailyNutrientAggregate existing = new DailyNutrientAggregate();
        existing.setId(1L);
        existing.setUser(user);
        existing.setDate(LocalDate.now());

        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.of(existing));

        // When
        DailyNutrientAggregate result = aggregateService.getOrCreateDailyAggregate(user, LocalDate.now());

        // Then: 应该返回已存在的记录
        assertThat(result).isEqualTo(existing);
        verify(aggregateRepository, never()).save(any());
    }

    @Test
    @DisplayName("获取或创建日聚合 - 新建")
    void testGetOrCreateDailyAggregate_New() {
        // Given
        when(aggregateRepository.findByUserAndDate(user, LocalDate.now()))
            .thenReturn(Optional.empty());
        when(healthGoalRepository.findByUserAndStatus(user, 1))
            .thenReturn(goal);
        
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        DailyNutrientAggregate result = aggregateService.getOrCreateDailyAggregate(user, LocalDate.now());

        // Then: 应该创建新记录
        assertThat(result).isNotNull();
        assertThat(result.getUser()).isEqualTo(user);
        assertThat(result.getGoalEnergySnapshot()).isEqualTo(2000);
        verify(aggregateRepository).save(result);
    }

    @Test
    @DisplayName("获取周摘要 - 成功")
    void testGetWeeklySummary_Success() {
        // Given
        LocalDate weekStart = LocalDate.of(2024, 1, 1);
        LocalDate weekEnd = weekStart.plusDays(6);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        
        UserHealthService.UserHealthInfo healthInfo = new UserHealthService.UserHealthInfo();
        healthInfo.setDailyEnergy(2000);
        healthInfo.setDailyProtein(100);
        healthInfo.setDailyFat(60);
        healthInfo.setDailyCarbohydrates(300);
        when(userHealthService.getUserHealthInfo(1L)).thenReturn(healthInfo);

        List<DailyNutrientAggregate> aggregates = Arrays.asList(
            createAggregate(weekStart, 2000, 100.0),
            createAggregate(weekStart.plusDays(1), 1800, 90.0)
        );

        when(aggregateRepository.findByUserAndDateBetween(user, weekStart, weekEnd))
            .thenReturn(aggregates);

        // When
        com.calotter.health.controller.dto.WeeklySummaryVO summary = 
            aggregateService.getWeeklySummary(1L, weekStart);

        // Then
        assertThat(summary).isNotNull();
        assertThat(summary.getWeekStart()).isEqualTo(weekStart);
        assertThat(summary.getWeekEnd()).isEqualTo(weekEnd);
        assertThat(summary.getConsumed().getEnergy()).isEqualTo(3800); // 2000 + 1800
        assertThat(summary.getConsumed().getProtein()).isEqualTo(190.0); // 100 + 90
        // 剩余 = 目标 - 已消耗
        assertThat(summary.getRemaining().getEnergy()).isEqualTo(10200); // 14000 - 3800
    }

    // 辅助方法：创建聚合记录
    private DailyNutrientAggregate createAggregate(LocalDate date, Integer calories, Double protein) {
        DailyNutrientAggregate aggregate = new DailyNutrientAggregate();
        aggregate.setUser(user);
        aggregate.setDate(date);
        aggregate.setTotalEnergy(calories);
        aggregate.setTotalProtein(protein);
        aggregate.setTotalFat(calories != null ? calories / 13.0 : 0.0);
        aggregate.setTotalCarbohydrates(calories != null ? calories / 4.0 : 0.0);
        aggregate.setTotalFiber(calories != null ? calories / 50.0 : 0.0);
        return aggregate;
    }
}
