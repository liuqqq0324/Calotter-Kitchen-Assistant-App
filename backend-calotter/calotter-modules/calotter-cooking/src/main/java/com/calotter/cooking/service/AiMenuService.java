package com.calotter.cooking.service;

import com.calotter.common.core.domain.PreferenceStandardLibrary;
import com.calotter.cooking.controller.dto.RecipeGenerationFilter;
import com.calotter.cooking.service.ai.AiMenuGenerationService;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.HouseholdSpice;
import com.calotter.inventory.domain.entity.HouseholdUtensil;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.HouseholdSpiceRepository;
import com.calotter.inventory.repository.HouseholdUtensilRepository;
import com.calotter.user.domain.entity.User;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.repository.HouseholdRepository;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.repository.HealthGoalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AiMenuService {

    private final IngredientRepository ingredientRepository;
    private final HouseholdSpiceRepository spiceRepository;
    private final HouseholdUtensilRepository utensilRepository;
    private final HouseholdRepository householdRepository;
    private final UserRepository userRepository;
    private final HealthGoalRepository healthGoalRepository;
    
    // 注入 AI 菜单生成服务（根据配置自动选择 Mock/Gemini/Groq）
    private final AiMenuGenerationService aiMenuGenerationService;

    /**
     * 调用 AI 生成 5 套菜单
     */
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter, Long householdId) {
        // 如果提供了householdId，自动填充inventory、cookers、seasonings
        if (householdId != null) {
            enrichFilterFromHousehold(filter, householdId);
        }
        
        // 使用注入的服务（Mock/Gemini/Groq）
        return aiMenuGenerationService.generateMenus(filter);
    }

    /**
     * 获取默认 Filter（基于用户的偏好和健康目标）
     */
    public RecipeGenerationFilter getDefaultFilter(Long householdId) {
        RecipeGenerationFilter filter = new RecipeGenerationFilter();
        
        // 1. 验证家庭存在
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在: " + householdId));
        
        // 2. 获取家庭成员（User列表）- 使用Repository查询避免懒加载问题
        List<User> members = userRepository.findByJoinedHouseholdsId(householdId);
        
        // 如果没有成员，至少包含所有者
        if (members == null || members.isEmpty()) {
            // 如果查询结果为空，尝试添加所有者
            User owner = userRepository.findById(household.getOwnerId()).orElse(null);
            if (owner != null) {
                members = new ArrayList<>(List.of(owner));
                log.info("家庭 {} 没有成员，使用所有者作为默认成员", householdId);
            } else {
                log.warn("家庭 {} 没有成员且所有者不存在，使用默认值", householdId);
                members = new ArrayList<>();
            }
        }
        
        // 3. 收集过敏信息
        List<String> allergies = new ArrayList<>();
        List<String> avoidIngredients = new ArrayList<>();
        List<String> cuisinePreferences = new ArrayList<>();
        List<String> tastePreferences = new ArrayList<>();
        
        // 4. 计算卡路里目标（从健康目标）
        Double avgCalorieTarget = null;
        int activeGoalCount = 0;
        int totalCalories = 0;
        
        for (User member : members) {
            // 收集过敏（User.allergies是List<RefAllergen>）
            if (member.getAllergies() != null) {
                member.getAllergies().forEach(a -> allergies.add(a.getName()));
            }
            
            // 收集偏好（User.preferences是Map<String, List<String>>）
            if (member.getPreferences() != null) {
                List<String> cuisines = member.getPreferences().getOrDefault(PreferenceStandardLibrary.PREF_KEY_CUISINE, new ArrayList<>());
                cuisinePreferences.addAll(cuisines);
                
                List<String> tastes = member.getPreferences().getOrDefault(PreferenceStandardLibrary.PREF_KEY_TASTE, new ArrayList<>());
                tastePreferences.addAll(tastes);
            }
            
            // 收集硬性饮食禁忌和避免食材（从 dietaryStyles Map）
            if (member.getDietaryStyles() != null) {
                // 提取硬性饮食禁忌（TABOO）
                List<String> taboos = member.getDietaryStyles().getOrDefault(PreferenceStandardLibrary.PREF_KEY_TABOO, new ArrayList<>());
                avoidIngredients.addAll(taboos);
                
                // 提取不喜欢吃的食材（AVOID_INGREDIENT）
                List<String> avoidIngs = member.getDietaryStyles().getOrDefault(PreferenceStandardLibrary.PREF_KEY_AVOID_INGREDIENT, new ArrayList<>());
                avoidIngredients.addAll(avoidIngs);
            }
            
            // 计算卡路里目标（使用User而不是FamilyMember）
            HealthGoal goal = healthGoalRepository.findByUserAndStatus(member, 1); // 1=Active
            if (goal != null && goal.getDailyCalories() != null) {
                totalCalories += goal.getDailyCalories();
                activeGoalCount++;
            }
        }
        
        // 计算平均卡路里目标（每人）
        if (activeGoalCount > 0) {
            avgCalorieTarget = (double) totalCalories / activeGoalCount;
        } else if (!members.isEmpty()) {
            // 如果没有健康目标，使用默认值（成年人平均）
            avgCalorieTarget = 600.0; // 默认每人600卡
        }
        
        // 5. 设置 dietPreferences
        RecipeGenerationFilter.DietPreferences dietPrefs = new RecipeGenerationFilter.DietPreferences();
        dietPrefs.setAllergies(allergies.stream().distinct().collect(Collectors.toList()));
        dietPrefs.setAvoidIngredients(avoidIngredients.stream().distinct().collect(Collectors.toList()));
        dietPrefs.setCuisinePreferences(cuisinePreferences.stream().distinct().collect(Collectors.toList()));
        dietPrefs.setTastePreferences(tastePreferences.stream().distinct().collect(Collectors.toList()));
        filter.setDietPreferences(dietPrefs);
        
        // 6. 设置卡路里目标
        if (avgCalorieTarget != null) {
            RecipeGenerationFilter.CalorieTarget calorieTarget = new RecipeGenerationFilter.CalorieTarget();
            calorieTarget.setMinTotalKcal(avgCalorieTarget);
            calorieTarget.setMaxTotalKcal(avgCalorieTarget);
            filter.setCalorieTarget(calorieTarget);
        }
        
        // 7. 设置默认值
        filter.setServings(members.isEmpty() ? 1 : members.size());
        filter.setGenerationSettings(new RecipeGenerationFilter.GenerationSettings());
        filter.getGenerationSettings().setDishCount(1);
        
        // 8. 自动填充库存、厨具、调料
        enrichFilterFromHousehold(filter, householdId);
        
        return filter;
    }

    /**
     * 从household自动填充filter的inventory、cookers、seasonings
     */
    private void enrichFilterFromHousehold(RecipeGenerationFilter filter, Long householdId) {
        // 填充inventory（如果为空）
        if (filter.getInventory() == null || filter.getInventory().isEmpty()) {
            List<Ingredient> ingredients = ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);
            List<RecipeGenerationFilter.InventoryItem> inventoryItems = ingredients.stream()
                    .map(ing -> {
                        RecipeGenerationFilter.InventoryItem item = new RecipeGenerationFilter.InventoryItem();
                        item.setName(ing.getMetadata().getName());
                        item.setAmountValue(ing.getQuantity());
                        item.setAmountUnit(ing.getUnit());
                        if (ing.getExpirationDate() != null) {
                            item.setExpiresAt(ing.getExpirationDate().format(DateTimeFormatter.ISO_LOCAL_DATE));
                        }
                        return item;
                    })
                    .collect(Collectors.toList());
            filter.setInventory(inventoryItems);
            log.info("自动填充inventory: {} 项", inventoryItems.size());
        }

        // 填充cookers（如果为空）
        if (filter.getCookers() == null || filter.getCookers().isEmpty()) {
            List<HouseholdUtensil> utensils = utensilRepository.findByHouseholdIdAndIsAvailableTrue(householdId);
            List<String> cookerNames = utensils.stream()
                    .map(u -> u.getMetadata().getName())
                    .collect(Collectors.toList());
            filter.setCookers(cookerNames);
            log.info("自动填充cookers: {} 项", cookerNames.size());
        }

        // 填充seasonings（如果为空）
        if (filter.getSeasonings() == null || filter.getSeasonings().isEmpty()) {
            List<HouseholdSpice> spices = spiceRepository.findByHouseholdIdAndIsAvailableTrue(householdId);
            List<String> spiceNames = spices.stream()
                    .map(s -> s.getMetadata().getName())
                    .collect(Collectors.toList());
            filter.setSeasonings(spiceNames);
            log.info("自动填充seasonings: {} 项", spiceNames.size());
        }
    }

}
