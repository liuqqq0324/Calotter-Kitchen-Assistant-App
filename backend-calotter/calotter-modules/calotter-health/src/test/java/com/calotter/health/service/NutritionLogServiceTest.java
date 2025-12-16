package com.calotter.health.service;

import com.calotter.cooking.service.LeftoverDishService;
import com.calotter.cooking.service.dto.LeftoverDishDetailDTO;
import com.calotter.cooking.service.dto.NutritionInfo;
import com.calotter.cooking.service.event.CookingSessionCompletedEvent;
import com.calotter.health.controller.dto.ManualNutritionLogRequest;
import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.health.domain.enums.LogSourceType;
import com.calotter.health.domain.enums.MealType;
import com.calotter.health.repository.NutritionLogRepository;
import com.calotter.health.service.event.NutritionLogCreatedEvent;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.FamilyMember;
import com.calotter.user.repository.FamilyMemberRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

/**
 * NutritionLogService 单元测试
 */
@ExtendWith(MockitoExtension.class)
class NutritionLogServiceTest {

    @Mock
    private NutritionLogRepository nutritionLogRepository;

    @Mock
    private FamilyMemberRepository familyMemberRepository;

    @Mock
    private LeftoverDishRepository leftoverDishRepository;

    @Mock
    private LeftoverDishService leftoverDishService;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @InjectMocks
    private NutritionLogService nutritionLogService;

    private FamilyMember member;
    private CookingSessionCompletedEvent event;
    private LeftoverDish leftoverDish;

    @BeforeEach
    void setUp() {
        member = new FamilyMember();
        member.setId(1L);
        member.setName("测试用户");

        // 准备烹饪完成事件
        CookingSessionCompletedEvent.DishNutritionSnapshot nutrition = 
            new CookingSessionCompletedEvent.DishNutritionSnapshot(
                2000, 100.0, 150.0, 50.0, 5.0, 1000);

        CookingSessionCompletedEvent.DinerConsumptionData diner1 = 
            new CookingSessionCompletedEvent.DinerConsumptionData(1L, 0.3, null);
        CookingSessionCompletedEvent.DinerConsumptionData diner2 = 
            new CookingSessionCompletedEvent.DinerConsumptionData(2L, 0.3, null);

        event = new CookingSessionCompletedEvent(
            this,
            200L,
            "红烧肉",
            nutrition,
            Arrays.asList(diner1, diner2),
            LocalDateTime.now(),
            "LUNCH"
        );

        // 准备剩菜数据
        leftoverDish = new LeftoverDish();
        leftoverDish.setId(1L);
        leftoverDish.setOriginalDishId(200L);
        leftoverDish.setCurrentQuantityGram(300);
    }

    @Test
    void testCreateFromEvent_Success() {
        // Given
        FamilyMember member2 = new FamilyMember();
        member2.setId(2L);
        member2.setName("测试用户2");

        when(familyMemberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(familyMemberRepository.findById(2L)).thenReturn(Optional.of(member2));
        when(nutritionLogRepository.saveAll(anyList())).thenAnswer(invocation -> {
            List<NutritionLog> logs = invocation.getArgument(0);
            for (int i = 0; i < logs.size(); i++) {
                logs.get(i).setId((long) (i + 1));
            }
            return logs;
        });

        // When
        List<NutritionLog> result = nutritionLogService.createFromEvent(event);

        // Then
        assertThat(result).hasSize(2);
        
        // 验证第一条日志
        NutritionLog log1 = result.get(0);
        assertThat(log1.getFamilyMember().getId()).isEqualTo(1L);
        assertThat(log1.getDishId()).isEqualTo(200L);
        assertThat(log1.getSourceType()).isEqualTo(LogSourceType.APP_COOKING);
        assertThat(log1.getFoodName()).isEqualTo("红烧肉");
        assertThat(log1.getMealType()).isEqualTo(MealType.LUNCH);
        
        // 验证营养计算：30%的比例
        assertThat(log1.getCalories()).isEqualTo(600); // 2000 * 0.3
        assertThat(log1.getProtein()).isEqualTo(30.0); // 100 * 0.3
        assertThat(log1.getFat()).isEqualTo(45.0); // 150 * 0.3
        assertThat(log1.getQuantity()).isEqualTo(300.0); // 1000 * 0.3

        // 验证事件发布
        ArgumentCaptor<NutritionLogCreatedEvent> eventCaptor = 
            ArgumentCaptor.forClass(NutritionLogCreatedEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        assertThat(eventCaptor.getValue().getLogs()).hasSize(2);
    }

    @Test
    void testCreateFromEvent_InvalidMealType() {
        // Given: 使用无效的餐次类型
        event.setMealType("INVALID_TYPE");
        when(familyMemberRepository.findById(anyLong())).thenReturn(Optional.of(member));
        when(nutritionLogRepository.saveAll(anyList())).thenAnswer(invocation -> 
            invocation.getArgument(0));

        // When
        List<NutritionLog> result = nutritionLogService.createFromEvent(event);

        // Then: 应该使用默认值SNACK
        assertThat(result.get(0).getMealType()).isEqualTo(MealType.SNACK);
    }

    @Test
    void testCreateFromEvent_MemberNotFound() {
        // Given
        when(familyMemberRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> nutritionLogService.createFromEvent(event))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("家庭成员不存在");
    }

    @Test
    void testCreateFromLeftover_Success() {
        // Given: 剩菜300g，吃100g
        NutritionInfo nutritionInfo = NutritionInfo.builder()
            .calories(200)
            .protein(10.0)
            .fat(15.0)
            .carb(5.0)
            .fiber(0.5)
            .build();

        LeftoverDishDetailDTO detailDTO = LeftoverDishDetailDTO.builder()
            .name("红烧肉")
            .build();

        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));
        when(familyMemberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(leftoverDishService.calculateNutritionForConsumption(1L, 100))
            .thenReturn(nutritionInfo);
        when(leftoverDishService.getLeftoverDishDetail(1L)).thenReturn(detailDTO);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenReturn(leftoverDish);
        when(nutritionLogRepository.save(any(NutritionLog.class))).thenAnswer(invocation -> {
            NutritionLog log = invocation.getArgument(0);
            log.setId(1L);
            return log;
        });

        // When
        NutritionLog result = nutritionLogService.createFromLeftover(1L, 1L, 100, LocalDateTime.now());

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getSourceType()).isEqualTo(LogSourceType.LEFTOVER);
        assertThat(result.getDishId()).isEqualTo(200L);
        assertThat(result.getFoodName()).isEqualTo("红烧肉");
        assertThat(result.getQuantity()).isEqualTo(100.0);
        assertThat(result.getCalories()).isEqualTo(200);
        assertThat(result.getProtein()).isEqualTo(10.0);

        // 验证剩菜重量更新：300 - 100 = 200
        assertThat(leftoverDish.getCurrentQuantityGram()).isEqualTo(200);
        verify(leftoverDishRepository).save(leftoverDish);

        // 验证事件发布
        verify(eventPublisher).publishEvent(any(NutritionLogCreatedEvent.class));
    }

    @Test
    void testCreateFromLeftover_ExceedsQuantity() {
        // Given: 剩菜300g，尝试吃500g
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.of(leftoverDish));
        // 注意：不需要mock familyMember，因为验证会在查询member之前执行

        // When & Then: 应该在验证重量时就抛出异常，不会执行到查询member
        assertThatThrownBy(() -> nutritionLogService.createFromLeftover(1L, 1L, 500, LocalDateTime.now()))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("食用重量(500克)超过剩余重量(300克)");
        
        // 验证：不应该调用familyMemberRepository（因为提前验证失败）
        verify(familyMemberRepository, never()).findById(anyLong());
    }

    @Test
    void testCreateFromLeftover_LeftoverNotFound() {
        // Given
        when(leftoverDishRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> nutritionLogService.createFromLeftover(1L, 1L, 100, LocalDateTime.now()))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("剩菜不存在");
    }

    @Test
    void testCreateManual_Success() {
        // Given
        ManualNutritionLogRequest request = new ManualNutritionLogRequest();
        request.setFamilyMemberId(1L);
        request.setEatenAt(LocalDateTime.now());
        request.setFoodName("苹果");
        request.setQuantity(200.0);
        request.setUnit("g");
        request.setEnergy(80);
        request.setProtein(0.5);
        request.setFat(0.3);
        request.setCarbohydrates(20.0);
        request.setMealType(MealType.SNACK);

        when(familyMemberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(nutritionLogRepository.save(any(NutritionLog.class))).thenAnswer(invocation -> {
            NutritionLog log = invocation.getArgument(0);
            log.setId(1L);
            return log;
        });

        // When
        NutritionLog result = nutritionLogService.createManual(request);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getSourceType()).isEqualTo(LogSourceType.MANUAL);
        assertThat(result.getDishId()).isNull();
        assertThat(result.getFoodName()).isEqualTo("苹果");
        assertThat(result.getMealType()).isEqualTo(MealType.SNACK);
        assertThat(result.getCalories()).isEqualTo(80);
        assertThat(result.getProtein()).isEqualTo(0.5);

        // 验证事件发布
        verify(eventPublisher).publishEvent(any(NutritionLogCreatedEvent.class));
    }

    @Test
    void testCreateManual_AutoDetermineMealType() {
        // Given: 不指定mealType，应该根据时间自动判断
        ManualNutritionLogRequest request = new ManualNutritionLogRequest();
        request.setFamilyMemberId(1L);
        request.setEatenAt(LocalDateTime.of(2024, 1, 1, 12, 0)); // 12点，应该是LUNCH
        request.setFoodName("苹果");
        request.setEnergy(80);

        when(familyMemberRepository.findById(1L)).thenReturn(Optional.of(member));
        when(nutritionLogRepository.save(any(NutritionLog.class))).thenAnswer(invocation -> {
            NutritionLog log = invocation.getArgument(0);
            log.setId(1L);
            return log;
        });

        // When
        NutritionLog result = nutritionLogService.createManual(request);

        // Then: 应该自动判断为LUNCH
        assertThat(result.getMealType()).isEqualTo(MealType.LUNCH);
    }

    @Test
    void testCreateManual_MemberNotFound() {
        // Given
        ManualNutritionLogRequest request = new ManualNutritionLogRequest();
        request.setFamilyMemberId(999L);
        request.setFoodName("苹果");

        when(familyMemberRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> nutritionLogService.createManual(request))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("家庭成员不存在");
    }
}

