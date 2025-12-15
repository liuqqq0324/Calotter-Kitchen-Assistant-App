package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.CookingCompletionRequest;
import com.calotter.cooking.controller.dto.CookingCompletionResponse;
import com.calotter.cooking.controller.dto.LeftoverAction;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.service.event.CookingSessionCompletedEvent;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
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
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * CookingSessionService 单元测试
 */
@ExtendWith(MockitoExtension.class)
class CookingSessionServiceTest {

    @Mock
    private CookingSessionRepository sessionRepository;

    @Mock
    private DishService dishService;

    @Mock
    private HouseholdRepository householdRepository;

    @Mock
    private LeftoverDishRepository leftoverDishRepository;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @InjectMocks
    private CookingSessionService cookingSessionService;

    private CookingSession session;
    private Household household;
    private Dish dish;
    private CookingCompletionRequest request;

    @BeforeEach
    void setUp() {
        household = new Household();
        household.setId(1L);

        session = new CookingSession();
        session.setId(100L);
        session.setHouseholdId(1L);
        session.setStatus(CookingSession.SessionStatus.COMPLETED);

        dish = new Dish();
        dish.setId(200L);
        dish.setName("红烧肉");
        dish.setTotalCalories(2000);
        dish.setTotalProtein(100.0);
        dish.setTotalFat(150.0);
        dish.setTotalCarb(50.0);
        dish.setTotalFiber(5.0);
        dish.setTotalWeightGram(1000); // 1000g

        session.setFinalDish(dish);

        request = new CookingCompletionRequest();
        request.setSessionId(100L);
        request.setConsumedAt(LocalDateTime.now());

        CookingCompletionRequest.DinerConsumption diner1 = new CookingCompletionRequest.DinerConsumption();
        diner1.setFamilyMemberId(1L);
        diner1.setPortionPercentage(0.3); // 30%

        CookingCompletionRequest.DinerConsumption diner2 = new CookingCompletionRequest.DinerConsumption();
        diner2.setFamilyMemberId(2L);
        diner2.setPortionPercentage(0.3); // 30%

        request.setDiners(Arrays.asList(diner1, diner2));
    }

    @Test
    void testCompleteSession_WithoutLeftover() {
        // Given: 60%被吃，40%剩余但不保存（丢弃）
        CookingCompletionRequest.LeftoverStrategy strategy = new CookingCompletionRequest.LeftoverStrategy();
        strategy.setAction(LeftoverAction.DISCARD);
        request.setLeftoverHandling(strategy);

        when(sessionRepository.findById(100L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);

        // When
        CookingCompletionResponse response = cookingSessionService.completeSession(request);

        // Then
        assertThat(response.getSuccess()).isTrue();
        assertThat(response.getLogsCreated()).isEqualTo(2);
        assertThat(response.getLeftoverCreated()).isFalse();
        assertThat(response.getTotalCaloriesConsumed()).isEqualTo(1200); // 2000 * 0.6

        // 验证Session状态更新
        verify(sessionRepository).save(argThat(s -> 
            s.getStatus() == CookingSession.SessionStatus.COOKED));

        // 验证没有创建剩菜
        verify(leftoverDishRepository, never()).save(any(LeftoverDish.class));

        // 验证事件发布
        ArgumentCaptor<CookingSessionCompletedEvent> eventCaptor = 
            ArgumentCaptor.forClass(CookingSessionCompletedEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        
        CookingSessionCompletedEvent event = eventCaptor.getValue();
        assertThat(event.getDishId()).isEqualTo(200L);
        assertThat(event.getDishName()).isEqualTo("红烧肉");
        assertThat(event.getDiners()).hasSize(2);
    }

    @Test
    void testCompleteSession_WithLeftover() {
        // Given: 60%被吃，40%剩余并保存
        CookingCompletionRequest.LeftoverStrategy strategy = new CookingCompletionRequest.LeftoverStrategy();
        strategy.setAction(LeftoverAction.SAVE_TO_FRIDGE);
        request.setLeftoverHandling(strategy);

        when(sessionRepository.findById(100L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        when(leftoverDishRepository.save(any(LeftoverDish.class))).thenAnswer(invocation -> {
            LeftoverDish leftover = invocation.getArgument(0);
            leftover.setId(300L);
            return leftover;
        });

        // When
        CookingCompletionResponse response = cookingSessionService.completeSession(request);

        // Then
        assertThat(response.getSuccess()).isTrue();
        assertThat(response.getLeftoverCreated()).isTrue();

        // 验证剩菜创建：1000g * 0.4 = 400g
        ArgumentCaptor<LeftoverDish> leftoverCaptor = ArgumentCaptor.forClass(LeftoverDish.class);
        verify(leftoverDishRepository).save(leftoverCaptor.capture());
        
        LeftoverDish savedLeftover = leftoverCaptor.getValue();
        assertThat(savedLeftover.getOriginalDishId()).isEqualTo(200L);
        assertThat(savedLeftover.getCurrentQuantityGram()).isEqualTo(400);
        assertThat(savedLeftover.getHousehold()).isEqualTo(household);
    }

    @Test
    void testCompleteSession_CreateDishIfNotExists() {
        // Given: Session没有finalDish，需要创建
        session.setFinalDish(null);
        
        // Mock aiResponse
        com.calotter.cooking.service.dto.AiRecipeResponse aiResponse = 
            new com.calotter.cooking.service.dto.AiRecipeResponse();
        com.calotter.cooking.service.dto.AiRecipeResponse.GeneratedDish mainDish = 
            new com.calotter.cooking.service.dto.AiRecipeResponse.GeneratedDish();
        mainDish.setDishName("红烧肉");
        aiResponse.setDishes(java.util.Arrays.asList(mainDish));
        
        com.calotter.cooking.service.dto.AiRecipeResponse.NutritionSummary nutrition = 
            new com.calotter.cooking.service.dto.AiRecipeResponse.NutritionSummary();
        nutrition.setCalories(2000);
        nutrition.setProtein(100);
        aiResponse.setTotalNutrition(nutrition);
        
        session.setAiResponse(aiResponse);
        
        when(sessionRepository.findById(100L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(dishService.createDishFromAiResponse(any(), any())).thenReturn(dish);
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);

        request.setLeftoverHandling(null); // 不处理剩菜

        // When
        CookingCompletionResponse response = cookingSessionService.completeSession(request);

        // Then: 应该调用dishService创建Dish
        verify(dishService).createDishFromAiResponse(any(), eq(household));
        assertThat(response.getSuccess()).isTrue();
    }

    @Test
    void testCompleteSession_SessionNotFound() {
        // Given
        when(sessionRepository.findById(100L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> cookingSessionService.completeSession(request))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("烹饪会话不存在");
    }

    @Test
    void testCompleteSession_HouseholdNotFound() {
        // Given
        when(sessionRepository.findById(100L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> cookingSessionService.completeSession(request))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("家庭不存在");
    }

    @Test
    void testCompleteSession_SmallLeftoverPercentage() {
        // Given: 只剩余2%（小于5%阈值），不应该创建剩菜
        CookingCompletionRequest.DinerConsumption diner1 = new CookingCompletionRequest.DinerConsumption();
        diner1.setFamilyMemberId(1L);
        diner1.setPortionPercentage(0.98); // 98%，剩余2%

        request.setDiners(Arrays.asList(diner1));

        CookingCompletionRequest.LeftoverStrategy strategy = new CookingCompletionRequest.LeftoverStrategy();
        strategy.setAction(LeftoverAction.SAVE_TO_FRIDGE);
        request.setLeftoverHandling(strategy);

        when(sessionRepository.findById(100L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);

        // When
        CookingCompletionResponse response = cookingSessionService.completeSession(request);

        // Then: 不应该创建剩菜（因为剩余比例太小）
        assertThat(response.getLeftoverCreated()).isFalse();
        verify(leftoverDishRepository, never()).save(any(LeftoverDish.class));
    }

    @Test
    void testDetermineMealType() {
        // Given: 不同时间点的请求
        when(sessionRepository.findById(100L)).thenReturn(Optional.of(session));
        when(householdRepository.findById(1L)).thenReturn(Optional.of(household));
        when(sessionRepository.save(any(CookingSession.class))).thenReturn(session);
        request.setLeftoverHandling(null);

        // 早餐时间：7点
        request.setConsumedAt(LocalDateTime.of(2024, 1, 1, 7, 0));
        cookingSessionService.completeSession(request);
        verify(eventPublisher, atLeastOnce()).publishEvent(argThat(event -> 
            event instanceof CookingSessionCompletedEvent && 
            "BREAKFAST".equals(((CookingSessionCompletedEvent) event).getMealType())));

        // 午餐时间：12点
        request.setConsumedAt(LocalDateTime.of(2024, 1, 1, 12, 0));
        cookingSessionService.completeSession(request);
        verify(eventPublisher, atLeastOnce()).publishEvent(argThat(event -> 
            event instanceof CookingSessionCompletedEvent && 
            "LUNCH".equals(((CookingSessionCompletedEvent) event).getMealType())));

        // 晚餐时间：18点
        request.setConsumedAt(LocalDateTime.of(2024, 1, 1, 18, 0));
        cookingSessionService.completeSession(request);
        verify(eventPublisher, atLeastOnce()).publishEvent(argThat(event -> 
            event instanceof CookingSessionCompletedEvent && 
            "DINNER".equals(((CookingSessionCompletedEvent) event).getMealType())));
    }
}

