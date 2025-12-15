package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.FinishCookingRequest;
import com.calotter.cooking.controller.dto.StartCookingRequest;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.event.CookingSessionCompletedEvent;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CookingWorkflowService {

    private final CookingSessionRepository sessionRepository;
    private final DishRepository dishRepository;
    private final HouseholdRepository householdRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final FavoriteRecipeService favoriteRecipeService;

    @Transactional
    public Long startCooking(StartCookingRequest req) {
        Household household = householdRepository.findById(req.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        Dish dish;
        if (req.getDishId() != null) {
            dish = dishRepository.findById(req.getDishId())
                    .orElseThrow(() -> new IllegalArgumentException("菜品不存在: " + req.getDishId()));
        } else if (req.getRecipe() != null) {
            dish = favoriteRecipeService.ensureDish(req.getHouseholdId(), req.getRecipe(), false);
        } else {
            throw new IllegalArgumentException("必须提供 dishId 或 recipe");
        }

        CookingSession session = new CookingSession();
        session.setHouseholdId(req.getHouseholdId());
        session.setInitiatorId(req.getInitiatorId());
        session.setFinalDish(dish);
        session.setStatus(CookingSession.SessionStatus.PENDING);
        session.setRemainingRatio(1.0);
        session = sessionRepository.save(session);
        return session.getId();
    }

    @Transactional
    public CookingSession finishCooking(FinishCookingRequest req) {
        CookingSession session = sessionRepository.findById(req.getSessionId())
                .orElseThrow(() -> new IllegalArgumentException("会话不存在: " + req.getSessionId()));
        if (session.getFinalDish() == null) {
            throw new IllegalStateException("会话未绑定菜品");
        }
        Dish dish = session.getFinalDish();

        // 保存快照
        session.setIngredientsSnapshot(req.getFinalIngredients());
        session.setTotalNutritionSnapshot(req.getTotalNutrition());
        session.setRemainingRatio(1.0);
        session.setStatus(CookingSession.SessionStatus.COOKED);
        sessionRepository.save(session);

        // 生成 Leftover (初始=100%)
        if (dish.getTotalWeightGram() != null && dish.getTotalWeightGram() > 0) {
            LeftoverDish leftover = new LeftoverDish();
            leftover.setHousehold(householdRepository.findById(session.getHouseholdId())
                    .orElseThrow(() -> new IllegalArgumentException("家庭不存在")));
            leftover.setOriginalDishId(dish.getId());
            leftover.setCurrentQuantityGram(dish.getTotalWeightGram());
            leftover.setInitialQuantityGram(dish.getTotalWeightGram());
            leftover.setProducedTime(LocalDateTime.now());
            leftoverDishRepository.save(leftover);
        }

        // 发布事件给健康模块
        CookingSessionCompletedEvent.DishNutritionSnapshot snapshot =
                new CookingSessionCompletedEvent.DishNutritionSnapshot(
                        toInt(req.getTotalNutrition().getCalories()),
                        toInt(req.getTotalNutrition().getProtein()),
                        toInt(req.getTotalNutrition().getFat()),
                        toInt(req.getTotalNutrition().getCarbs()),
                        dish.getTotalWeightGram()
                );
        CookingSessionCompletedEvent event = new CookingSessionCompletedEvent(
                this,
                dish.getId(),
                dish.getName(),
                snapshot,
                List.of(), // 此处未传个人分餐，保留兼容
                LocalDateTime.now(),
                "DINNER"
        );
        eventPublisher.publishEvent(event);

        return session;
    }

    private Integer toInt(Double v) {
        return v == null ? null : v.intValue();
    }
}
