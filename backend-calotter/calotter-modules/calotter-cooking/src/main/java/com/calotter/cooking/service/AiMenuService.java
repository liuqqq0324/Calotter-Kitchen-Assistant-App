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


import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
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
    
    // 注入 AI 菜单生成服务（使用 Spring AI Gemini）
    private final AiMenuGenerationService aiMenuGenerationService;
    private final RecipeFilterValidationService recipeFilterValidationService;

    /**
     * 调用 AI 生成 3 套菜单
     */
    public List<MenuDTO> generateMenus(RecipeGenerationFilter filter, Long householdId) {
        // 如果提供了householdId，自动填充inventory、cookers、seasonings
        if (householdId != null) {
            enrichFilterFromHousehold(filter, householdId);
        }

        // ✅ 先处理 allergies：确保正确处理 null、空数组和 ["none"] 的情况（必须在验证之前）
        if (filter != null && filter.getDietPreferences() != null) {
            RecipeGenerationFilter.DietPreferences dp = filter.getDietPreferences();
            List<String> allergies = dp.getAllergies();
            
            // ✅ 如果 allergies 为 null，初始化为空数组（防御性编程）
            if (allergies == null) {
                allergies = new ArrayList<>();
                dp.setAllergies(allergies);
                log.info("Allergies 为 null，已初始化为空数组");
            }
            // ✅ 如果 allergies 为空数组 []，保持不变（这是正确的，表示没有过敏）
            else if (allergies.isEmpty()) {
                log.debug("Allergies 为空数组，保持不变");
            }
            // ✅ 处理包含 "none" 的情况
            else {
                // 检查是否只包含 "none" 或者包含 "none"
                if (allergies.size() == 1 && "none".equalsIgnoreCase(allergies.get(0))) {
                    // 只有 ["none"]，置为空数组
                    dp.setAllergies(new ArrayList<>());
                    log.info("Allergies 包含 ['none']，已置为空数组");
                } else if (allergies.stream().anyMatch(a -> "none".equalsIgnoreCase(a))) {
                    // 包含 "none" 但还有其他值，移除 "none" 并保留其他值
                    List<String> filtered = allergies.stream()
                        .filter(a -> !"none".equalsIgnoreCase(a))
                        .collect(Collectors.toList());
                    dp.setAllergies(filtered);
                    log.info("Allergies 包含 'none'，已移除 'none'，保留其他值: {}", filtered);
                }
            }
        }

        // ✅ 校验：限制 allergies/avoid/dietHabits 必须来自标准库（在清理 "none" 之后）
        recipeFilterValidationService.validate(filter);

        // ✅ 添加日志：追踪 filter 数据
        if (filter != null && filter.getDietPreferences() != null) {
            RecipeGenerationFilter.DietPreferences dp = filter.getDietPreferences();
            log.info("=== Filter Data Before AI Call ===");
            log.info("Allergies: {}", dp.getAllergies());
            log.info("Diet Habits: {}", dp.getDietHabits());
            log.info("Avoid Ingredients: {}", dp.getAvoidIngredients());
            log.info("===================================");
        }
        
        // ✅ 不再合并 dietHabits 到 avoidIngredients，保持独立字段
        // dietHabits 是硬性饮食习惯（如 vegetarian），应该单独处理
        // avoidIngredients 是软性避免食材（具体食材名称）
        
        // 使用注入的服务（Spring AI Gemini）
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
        List<String> dietHabits = new ArrayList<>();
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
            
            // 收集硬性饮食习惯和避免食材（从 dietaryStyles Map）
            if (member.getDietaryStyles() != null) {
                // 提取硬性饮食习惯（DIET_HABITS）
                List<String> memberDietHabits = member.getDietaryStyles()
                        .getOrDefault(PreferenceStandardLibrary.PREF_KEY_DIET_HABITS, new ArrayList<>());
                dietHabits.addAll(memberDietHabits);
                
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
        dietPrefs.setDietHabits(dietHabits.stream().distinct().collect(Collectors.toList()));
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
     * 物理熔断：过敏原(DB)、Vegan/Vegetarian(Category)、标签(dietary_tags)
     */
    private void enrichFilterFromHousehold(RecipeGenerationFilter filter, Long householdId) {
        List<String> habits = (filter.getDietPreferences() != null && filter.getDietPreferences().getDietHabits() != null)
                ? filter.getDietPreferences().getDietHabits()
                : new ArrayList<>();

        boolean isVegan = hasHabit(habits, "vegan");
        boolean isVegetarian = hasHabit(habits, "vegetarian");

        // 用户偏好 -> 需过滤的数据库标签
        Set<String> forbiddenTags = buildForbiddenTagsFromHabits(habits);

        List<String> userAllergenNames = (filter.getDietPreferences() != null && filter.getDietPreferences().getAllergies() != null)
                ? filter.getDietPreferences().getAllergies().stream()
                        .filter(a -> a != null && !"none".equalsIgnoreCase(a))
                        .map(String::toLowerCase)
                        .collect(Collectors.toList())
                : new ArrayList<>();

        // ==========================================
        // 2. 库存食材 - 物理过滤
        // ==========================================
        if ((filter.getUrgentInventory() == null || filter.getUrgentInventory().isEmpty()) &&
                (filter.getRegularInventory() == null || filter.getRegularInventory().isEmpty())) {

            List<Ingredient> ingredients = ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);
            LocalDate today = LocalDate.now();
            LocalDate threeDaysLater = today.plusDays(3);
            List<RecipeGenerationFilter.InventoryItem> urgentItems = new ArrayList<>();
            List<RecipeGenerationFilter.InventoryItem> regularItems = new ArrayList<>();

            for (Ingredient ing : ingredients) {
                if (ing.getExpirationDate() != null && ing.getExpirationDate().isBefore(today)) continue;

                var std = ing.getMetadata();
                if (std == null) continue;

                String category = std.getCategory() != null ? std.getCategory().toUpperCase() : "";
                String name = (std.getName() != null ? std.getName() : "").toLowerCase();

                // A. 过敏原
                var allergens = std.getContainedAllergens();
                if (allergens != null && !userAllergenNames.isEmpty()) {
                    if (allergens.stream().anyMatch(a -> a != null && a.getName() != null && userAllergenNames.contains(a.getName().toLowerCase()))) {
                        log.debug("🚫 [过敏] 剔除: {}", std.getName());
                        continue;
                    }
                }

                // B. Vegan/Vegetarian (Category)
                if (isVegan && ("MEAT".equals(category) || "DAIRY".equals(category) || std.hasDietaryTag("ANIMAL_PRODUCT"))) continue;
                if (isVegetarian && "MEAT".equals(category)) continue;

                // C. Lactose Free (Category + 植物奶例外)
                if (hasHabit(habits, "lactose_free") && isDairyWithLactose(category, name)) {
                    log.debug("🚫 [无乳糖] 剔除: {}", std.getName());
                    continue;
                }

                // D. 标签过滤
                if (hasForbiddenTag(std.getDietaryTags(), forbiddenTags)) {
                    log.debug("🚫 [标签] 剔除: {} (Tags: {})", std.getName(), std.getDietaryTags());
                    continue;
                }

                RecipeGenerationFilter.InventoryItem item = new RecipeGenerationFilter.InventoryItem();
                item.setName(std.getName());
                item.setAmountValue(ing.getQuantity());
                item.setAmountUnit(ing.getUnit());

                if (ing.getExpirationDate() != null && !ing.getExpirationDate().isAfter(threeDaysLater)) {
                    urgentItems.add(item);
                } else {
                    regularItems.add(item);
                }
            }

            filter.setUrgentInventory(urgentItems);
            filter.setRegularInventory(regularItems);
            log.info("自动填充库存: {} 项即将过期, {} 项普通库存", urgentItems.size(), regularItems.size());
        }

        if (filter.getInventory() == null || filter.getInventory().isEmpty()) {
            List<RecipeGenerationFilter.InventoryItem> allItems = new ArrayList<>();
            if (filter.getUrgentInventory() != null) allItems.addAll(filter.getUrgentInventory());
            if (filter.getRegularInventory() != null) allItems.addAll(filter.getRegularInventory());
            filter.setInventory(allItems);
        }

        // ==========================================
        // 3. 调料 - 标签过滤
        // ==========================================
        List<HouseholdSpice> spices = spiceRepository.findByHouseholdIdAndIsAvailableTrue(householdId);
        List<String> safeSpices = new ArrayList<>();

        for (HouseholdSpice spice : spices) {
            var metadata = spice.getMetadata();
            if (metadata == null) continue;

            var spiceAllergens = metadata.getContainedAllergens();
            if (spiceAllergens != null && !userAllergenNames.isEmpty()) {
                if (spiceAllergens.stream().anyMatch(a -> a != null && a.getName() != null && userAllergenNames.contains(a.getName().toLowerCase()))) continue;
            }

            if (hasForbiddenTag(metadata.getDietaryTags(), forbiddenTags)) continue;
            if (hasHabit(habits, "halal") && metadata.hasDietaryTag("ALCOHOL")) continue;

            safeSpices.add(metadata.getName());
        }
        filter.setSeasonings(safeSpices);
        log.info("自动填充seasonings: {} 项", safeSpices.size());

        List<HouseholdUtensil> utensils = utensilRepository.findByHouseholdIdAndIsAvailableTrue(householdId);
        filter.setCookers(utensils.stream().map(u -> u.getMetadata().getName()).collect(Collectors.toList()));
        log.info("自动填充cookers: {} 项", filter.getCookers() != null ? filter.getCookers().size() : 0);
    }

    private boolean hasHabit(List<String> habits, String key) {
        if (habits == null) return false;
        String norm = key.toLowerCase().replace(" ", "_").replace("-", "_");
        return habits.stream().anyMatch(h -> h != null && norm.equals(h.toLowerCase().replace(" ", "_").replace("-", "_")));
    }

    private Set<String> buildForbiddenTagsFromHabits(List<String> habits) {
        Set<String> tags = new HashSet<>();
        if (hasHabit(habits, "halal")) { tags.add("PORK"); tags.add("ALCOHOL"); }
        if (hasHabit(habits, "low_sodium")) tags.add("HIGH_SODIUM");
        if (hasHabit(habits, "low_sugar") || hasHabit(habits, "low_calorie")) tags.add("HIGH_SUGAR");
        if (hasHabit(habits, "low_fat") || hasHabit(habits, "low_calorie")) tags.add("HIGH_FAT");
        if (hasHabit(habits, "gluten_free")) tags.add("GLUTEN");
        if (hasHabit(habits, "soy_free")) tags.add("SOY");
        if (hasHabit(habits, "nut_free")) tags.add("NUT");
        return tags;
    }

    private boolean hasForbiddenTag(List<String> itemTags, Set<String> forbiddenTags) {
        if (forbiddenTags == null || forbiddenTags.isEmpty()) return false;
        if (itemTags == null || itemTags.isEmpty()) return false;
        return itemTags.stream().anyMatch(forbiddenTags::contains);
    }

    private boolean isDairyWithLactose(String category, String name) {
        if (!"DAIRY".equals(category)) return false;
        if (name != null && (name.contains("lactose free") || name.contains("oat milk") || name.contains("almond milk") || name.contains("soy milk") || name.contains("coconut milk"))) return false;
        return true;
    }

}
