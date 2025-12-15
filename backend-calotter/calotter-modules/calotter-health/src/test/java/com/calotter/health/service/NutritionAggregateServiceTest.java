package com.calotter.health.service;

import com.calotter.health.domain.entity.DailyNutrientAggregate;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.repository.DailyNutrientAggregateRepository;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.user.domain.entity.FamilyMember;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.repository.FamilyMemberRepository;
import com.calotter.user.repository.HealthGoalRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Arrays;
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
class NutritionAggregateServiceTest {

    @Mock
    private DailyNutrientAggregateRepository aggregateRepository;

    @Mock
    private NutritionLogRepository nutritionLogRepository;

    @Mock
    private FamilyMemberRepository familyMemberRepository;

    @Mock
    private HealthGoalRepository healthGoalRepository;

    @InjectMocks
    private NutritionAggregateService aggregateService;

    private FamilyMember member;
    private HealthGoal goal;
    private NutritionLog log;

    @BeforeEach
    void setUp() {
        member = new FamilyMember();
        member.setId(1L);
        member.setName("测试用户");

        goal = new HealthGoal();
        goal.setId(1L);
        goal.setFamilyMember(member);
        goal.setStatus(1); // ACTIVE
        goal.setDailyCalories(2000);
        goal.setProtein(100);
        goal.setFat(60);
        goal.setCarb(300);
        goal.setFiber(30);

        log = new NutritionLog();
        log.setId(1L);
        log.setFamilyMember(member);
        log.setLogDate(LocalDate.now());
        log.setCalories(500);
        log.setProtein(25.0);
        log.setFat(15.0);
        log.setCarb(50.0);
        log.setFiber(5.0);
    }

    @Test
    void testUpdateAggregate_NewRecord() {
        // Given: 聚合表不存在，需要创建新记录
        when(aggregateRepository.findByFamilyMemberAndDate(member, LocalDate.now()))
            .thenReturn(Optional.empty());
        when(healthGoalRepository.findByFamilyMemberAndStatus(member, 1))
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
        assertThat(saved.getFamilyMember()).isEqualTo(member);
        assertThat(saved.getDate()).isEqualTo(LocalDate.now());
        assertThat(saved.getTotalCalories()).isEqualTo(500);
        assertThat(saved.getTotalProtein()).isEqualTo(25.0);
        assertThat(saved.getGoalCaloriesSnapshot()).isEqualTo(2000);
        assertThat(saved.getGoalProteinSnapshot()).isEqualTo(100);
    }

    @Test
    void testUpdateAggregate_Accumulate() {
        // Given: 已存在聚合记录
        DailyNutrientAggregate existing = new DailyNutrientAggregate();
        existing.setId(1L);
        existing.setFamilyMember(member);
        existing.setDate(LocalDate.now());
        existing.setTotalCalories(500);
        existing.setTotalProtein(25.0);
        existing.setTotalFat(15.0);
        existing.setTotalCarb(50.0);
        existing.setTotalFiber(5.0);

        when(aggregateRepository.findByFamilyMemberAndDate(member, LocalDate.now()))
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
        assertThat(saved.getTotalCalories()).isEqualTo(1000); // 500 + 500
        assertThat(saved.getTotalProtein()).isEqualTo(50.0); // 25.0 + 25.0
        assertThat(saved.getTotalFat()).isEqualTo(30.0); // 15.0 + 15.0
    }

    @Test
    void testUpdateAggregate_NoGoal() {
        // Given: 没有健康目标
        when(aggregateRepository.findByFamilyMemberAndDate(member, LocalDate.now()))
            .thenReturn(Optional.empty());
        when(healthGoalRepository.findByFamilyMemberAndStatus(member, 1))
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
        assertThat(saved.getGoalCaloriesSnapshot()).isNull();
        assertThat(saved.getTotalCalories()).isEqualTo(500);
    }

    @Test
    void testUpdateAggregate_NullValues() {
        // Given: 日志中的某些营养值为null
        log.setCalories(null);
        log.setProtein(null);

        DailyNutrientAggregate existing = new DailyNutrientAggregate();
        existing.setTotalCalories(500);
        existing.setTotalProtein(25.0);

        when(aggregateRepository.findByFamilyMemberAndDate(member, LocalDate.now()))
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
        assertThat(saved.getTotalCalories()).isEqualTo(500); // 500 + 0
        assertThat(saved.getTotalProtein()).isEqualTo(25.0); // 25.0 + 0.0
    }

    @Test
    void testGetWeeklyReport_Success() {
        // Given: 7天的聚合数据
        LocalDate weekStart = LocalDate.of(2024, 1, 1); // 周一
        LocalDate weekEnd = weekStart.plusDays(6); // 周日

        when(familyMemberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(healthGoalRepository.findByFamilyMemberAndStatus(member, 1))
            .thenReturn(goal);

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

        when(aggregateRepository.findByFamilyMemberAndDateBetween(member, weekStart, weekEnd))
            .thenReturn(aggregates);

        // When
        com.calotter.health.controller.dto.WeeklyReportVO report = 
            aggregateService.getWeeklyReport(1L, weekStart);

        // Then
        assertThat(report).isNotNull();
        assertThat(report.getWeekStart()).isEqualTo(weekStart);
        assertThat(report.getWeekEnd()).isEqualTo(weekEnd);

        // 验证周目标：2000 * 7 = 14000
        assertThat(report.getWeeklyTarget().getCalories()).isEqualTo(14000);
        assertThat(report.getWeeklyTarget().getProtein()).isEqualTo(700.0); // 100 * 7

        // 验证周实际：7天累计
        assertThat(report.getWeeklyActual().getCalories()).isEqualTo(14000); // 总和
        assertThat(report.getWeeklyActual().getProtein()).isEqualTo(700.0);

        // 验证每日详情
        assertThat(report.getDailyReports()).hasSize(7);
        assertThat(report.getDailyReports().get(0).getDate()).isEqualTo(weekStart);
        assertThat(report.getDailyReports().get(0).getActual().getCalories()).isEqualTo(2000);
    }

    @Test
    void testGetWeeklyReport_NoGoal() {
        // Given: 没有健康目标
        LocalDate weekStart = LocalDate.now().minusDays(7);

        when(familyMemberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(healthGoalRepository.findByFamilyMemberAndStatus(member, 1))
            .thenReturn(null);
        when(aggregateRepository.findByFamilyMemberAndDateBetween(any(), any(), any()))
            .thenReturn(Arrays.asList(createAggregate(LocalDate.now(), 2000, 100.0)));

        // When
        com.calotter.health.controller.dto.WeeklyReportVO report = 
            aggregateService.getWeeklyReport(1L, weekStart);

        // Then: 目标应该为null
        assertThat(report.getWeeklyTarget()).isNull();
        assertThat(report.getDailyReports().get(0).getTarget()).isNull();
    }

    @Test
    void testGetWeeklyReport_MemberNotFound() {
        // Given
        when(familyMemberRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> aggregateService.getWeeklyReport(999L, LocalDate.now()))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("家庭成员不存在");
    }

    @Test
    void testGetOrCreateDailyAggregate_Existing() {
        // Given
        DailyNutrientAggregate existing = new DailyNutrientAggregate();
        existing.setId(1L);
        existing.setFamilyMember(member);
        existing.setDate(LocalDate.now());

        when(aggregateRepository.findByFamilyMemberAndDate(member, LocalDate.now()))
            .thenReturn(Optional.of(existing));

        // When
        DailyNutrientAggregate result = aggregateService.getOrCreateDailyAggregate(member, LocalDate.now());

        // Then: 应该返回已存在的记录
        assertThat(result).isEqualTo(existing);
        verify(aggregateRepository, never()).save(any());
    }

    @Test
    void testGetOrCreateDailyAggregate_New() {
        // Given
        when(aggregateRepository.findByFamilyMemberAndDate(member, LocalDate.now()))
            .thenReturn(Optional.empty());
        when(healthGoalRepository.findByFamilyMemberAndStatus(member, 1))
            .thenReturn(goal);
        when(aggregateRepository.save(any(DailyNutrientAggregate.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        // When
        DailyNutrientAggregate result = aggregateService.getOrCreateDailyAggregate(member, LocalDate.now());

        // Then: 应该创建新记录
        assertThat(result).isNotNull();
        assertThat(result.getFamilyMember()).isEqualTo(member);
        assertThat(result.getGoalCaloriesSnapshot()).isEqualTo(2000);
        verify(aggregateRepository).save(result);
    }

    // 辅助方法：创建聚合记录
    private DailyNutrientAggregate createAggregate(LocalDate date, Integer calories, Double protein) {
        DailyNutrientAggregate aggregate = new DailyNutrientAggregate();
        aggregate.setFamilyMember(member);
        aggregate.setDate(date);
        aggregate.setTotalCalories(calories);
        aggregate.setTotalProtein(protein);
        aggregate.setTotalFat(calories != null ? calories / 13.0 : 0.0);
        aggregate.setTotalCarb(calories != null ? calories / 4.0 : 0.0);
        aggregate.setTotalFiber(calories != null ? calories / 50.0 : 0.0);
        return aggregate;
    }
}

