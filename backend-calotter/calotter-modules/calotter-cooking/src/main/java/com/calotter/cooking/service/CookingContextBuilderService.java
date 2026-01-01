package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.CookingGenerationRequest;
import com.calotter.cooking.service.dto.*;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.repository.HouseholdSpiceRepository;
import com.calotter.inventory.repository.HouseholdUtensilRepository;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.user.domain.entity.User;
import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.repository.UserRepository;
import com.calotter.user.repository.HealthGoalRepository;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CookingContextBuilderService {

    private final UserRepository userRepo;
    private final IngredientRepository ingredientRepo;
    private final HealthGoalRepository healthGoalRepo;
    private final HouseholdUtensilRepository utensilRepo;
    private final HouseholdSpiceRepository spiceRepo;

    // 常量定义：User.preferences JSON 中的 Key
    private static final String PREF_KEY_DISLIKE = "DISLIKE";
    private static final String PREF_KEY_TASTE = "TASTE";
    private static final String PREF_KEY_CUISINE = "CUISINE";

    /**
     * 主入口：构建 AI 请求上下文
     */
    public AiCookingContext buildContext(CookingGenerationRequest req) {
        // 1. 获取基础数据
        List<User> users = userRepo.findAllById(req.getUserIds());
        if (users.isEmpty()) {
            throw new RuntimeException("No users found for IDs: " + req.getUserIds());
        }
        // 从第一个用户的当前家庭获取 householdId
        User firstUser = users.get(0);
        Long householdId = firstUser.getCurrentHouseholdId();
        if (householdId == null) {
            throw new RuntimeException("User " + firstUser.getId() + " has no active household");
        }

        // 2. 处理食客与目标 (合并家人 + 客人)
        DinerProfileAndGoal combinedData = processDinersAndGoals(users, req.getGuests(), req.getTargetCuisines());

        // 3. 处理库存 (分类处理临期品)
        KitchenSnapshot inventory = processInventory(householdId);

        // 4. 处理任务设置
        TaskSettings task = TaskSettings.builder()
                .dishCount(req.getDishCount())
                .maxTimeMinutes(req.getMaxTimeMinutes())
                .difficulty(req.getDifficulty())
                .targetCuisines(req.getTargetCuisines())
                .build();

        // 5. 组装最终上下文
        return AiCookingContext.builder()
                .settings(task)
                .compositeGoal(combinedData.getCompositeGoal())
                .dinerProfile(combinedData.getDinerProfile())
                .kitchenInventory(inventory)
                .build();
    }

    // ================= 内部逻辑实现 =================

    /**
     * 核心逻辑 A：处理所有用餐者的画像与营养目标
     */
    private DinerProfileAndGoal processDinersAndGoals(List<User> users,
                                                      List<CookingGenerationRequest.GuestInfo> guests,
                                                      List<String> overrideCuisines) {

        List<DinerProfile.DinerSlot> roster = new ArrayList<>();
        Set<String> globalAvoidance = new HashSet<>();

        // 统计器：用于计算共同偏好和冲突
        Map<String, Integer> dislikeCounter = new HashMap<>();
        Map<String, Integer> tasteCounter = new HashMap<>();
        Map<String, Integer> cuisineCounter = new HashMap<>();

        // 营养累加器
        int totalMinCal = 0, totalMaxCal = 0, totalP = 0, totalF = 0, totalC = 0, totalFib = 0;
        
        // 假设本餐占全天热量的比例 (可配置)
        Double ratio = 0.35; 

        // --- 1. 处理家人 (Users) ---
        for (User u : users) {
            // 1.1 收集硬性限制 (过敏 + 饮食风格)
            if (u.getAllergies() != null) {
                u.getAllergies().forEach(a -> globalAvoidance.add(a.getName()));
            }
            if (u.getDietaryStyles() != null) {
                globalAvoidance.addAll(u.getDietaryStyles());
            }

            // 1.2 收集软性偏好并计数
            if (u.getPreferences() != null) {
                countPreferences(u.getPreferences(), PREF_KEY_DISLIKE, dislikeCounter);
                countPreferences(u.getPreferences(), PREF_KEY_TASTE, tasteCounter);
                countPreferences(u.getPreferences(), PREF_KEY_CUISINE, cuisineCounter);
            }

            // 1.3 提取个人忌口 (用于 Roster)
            List<String> personalDislikes = u.getPreferences() != null ?
                    u.getPreferences().getOrDefault(PREF_KEY_DISLIKE, new ArrayList<>()) : new ArrayList<>();

            // 1.4 计算单人营养目标
            HealthGoal g = healthGoalRepo.findByUserAndStatus(u, 1); // 1=Active
            int pCal;
            
            if (g != null) {
                // 有目标：按比例计算
                pCal = (int) (g.getDailyCalories() * ratio);
                totalMinCal += (int) (pCal * 0.9);
                totalMaxCal += (int) (pCal * 1.1);
                totalP += (int) (g.getProtein() * ratio);
                totalF += (int) (g.getFat() * ratio);
                totalC += (int) (g.getCarb() * ratio);
                totalFib += (int) (g.getFiber() * ratio);
            } else {
                // 无目标：使用成年人默认值 (兜底逻辑)
                pCal = 600;
                totalMinCal += 550;
                totalMaxCal += 650;
                totalP += 25; totalF += 20; totalC += 70; totalFib += 8;
            }

            // 1.5 加入花名册
            roster.add(DinerProfile.DinerSlot.builder()
                    .dinerId("U-" + u.getId()) // ID 格式: U-101
                    .displayName(u.getDisplayname() != null ? u.getDisplayname() : u.getUsername())
                    .targetCalories(pCal)
                    .personalDislikes(personalDislikes)
                    .build());
        }

        // --- 2. 处理客人 (Guests) ---
        if (guests != null && !guests.isEmpty()) {
            int guestIdx = 1;
            for (CookingGenerationRequest.GuestInfo g : guests) {
                // 2.1 收集硬性限制
                if (g.getAllergies() != null) {
                    globalAvoidance.addAll(g.getAllergies());
                }

                // 2.2 收集软性偏好 (客人偏好也参与投票)
                if (g.getPreferences() != null) {
                    countPreferences(g.getPreferences(), PREF_KEY_DISLIKE, dislikeCounter);
                    countPreferences(g.getPreferences(), PREF_KEY_TASTE, tasteCounter);
                    countPreferences(g.getPreferences(), PREF_KEY_CUISINE, cuisineCounter);
                }

                List<String> gDislikes = g.getPreferences() != null ?
                        g.getPreferences().getOrDefault(PREF_KEY_DISLIKE, new ArrayList<>()) : new ArrayList<>();

                // 2.3 估算客人营养 (默认值)
                int gCal = 700;
                totalMinCal += 600;
                totalMaxCal += 800;
                totalP += 25; totalF += 25; totalC += 80; totalFib += 10;

                // 2.4 加入花名册
                roster.add(DinerProfile.DinerSlot.builder()
                        .dinerId("G-" + (guestIdx++)) // ID 格式: G-1
                        .displayName(g.getName() == null ? "Guest" : g.getName())
                        .targetCalories(gCal)
                        .personalDislikes(gDislikes)
                        .build());
            }
        }

        // --- 3. 生成冲突报告 ---
        int totalHeadCount = roster.size();
        List<String> universalDislikes = new ArrayList<>();
        Map<String, String> conflictDetails = new HashMap<>();
        List<String> commonLikedCuisines = new ArrayList<>();

        // 分析忌口 (Dislikes)
        dislikeCounter.forEach((item, count) -> {
            if (count == totalHeadCount) {
                // 所有人都不吃 -> 全局屏蔽
                universalDislikes.add(item);
            } else {
                // 部分人不吃 -> 记录冲突
                conflictDetails.put(item, "PARTIAL_DISLIKE: " + count + "/" + totalHeadCount + " people dislike this.");
            }
        });

        // 分析菜系 (Cuisines)
        if (overrideCuisines == null || overrideCuisines.isEmpty()) {
            // 如果没有临时覆盖，则取众数 (半数以上喜欢)
            cuisineCounter.forEach((cuisine, count) -> {
                if (count >= (double) totalHeadCount / 2) {
                    commonLikedCuisines.add(cuisine);
                }
            });
        } else {
            // 如果用户指定了想吃啥，直接覆盖
            commonLikedCuisines.addAll(overrideCuisines);
        }
        
        // 也可以在这里处理 TASTE (辣/甜等) 的冲突逻辑，逻辑类似，此处略以保持简洁

        // --- 4. 组装返回对象 ---
        DinerProfile profile = DinerProfile.builder()
                .globalStrictAvoidance(new ArrayList<>(globalAvoidance))
                .roster(roster)
                .preferenceConflicts(DinerProfile.PreferenceConflictReport.builder()
                        .universalDislikes(universalDislikes)
                        .conflictDetails(conflictDetails)
                        .commonLikedTastes(new ArrayList<>()) // 可以后续扩展
                        .build())
                .build();

        CompositeNutritionalGoal.Range<Integer> calorieRange = CompositeNutritionalGoal.Range.<Integer>builder()
                .min(totalMinCal)
                .max(totalMaxCal)
                .build();
        
        CompositeNutritionalGoal goal = CompositeNutritionalGoal.builder()
                .totalCalories(calorieRange)
                .totalProtein(totalP)
                .totalFat(totalF)
                .totalCarb(totalC)
                .totalFiber(totalFib)
                .build();

        return DinerProfileAndGoal.builder()
                .dinerProfile(profile)
                .compositeGoal(goal)
                .build();
    }

    /**
     * 核心逻辑 B：处理厨房库存
     */
    private KitchenSnapshot processInventory(Long householdId) {
        // 1. 查食材 (仅查询 Quantity > 0 的)
        List<Ingredient> ingredients = ingredientRepo.findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);

        List<KitchenSnapshot.Item> priority = new ArrayList<>();
        List<KitchenSnapshot.Item> common = new ArrayList<>();
        LocalDate today = LocalDate.now();

        for (Ingredient ing : ingredients) {
            // 计算剩余天数
            String expireStatus;
            if (ing.getExpirationDate() == null) {
                expireStatus = "NORMAL";
            } else {
                long daysLeft = ChronoUnit.DAYS.between(today, ing.getExpirationDate());
                // 逻辑：过期时间 <= 3天 标记为紧急
                expireStatus = daysLeft <= 3 ? "URGENT" : "NORMAL";
            }
            
            // 构建 Item DTO
            KitchenSnapshot.Item item = KitchenSnapshot.Item.builder()
                    .name(ing.getMetadata().getName()) // 使用标准名
                    .quantity(ing.getQuantity().toString()) // 转字符串
                    .unit(ing.getUnit())
                    .expireStatus(expireStatus)
                    .build();

            // 根据过期状态添加到对应列表
            if ("URGENT".equals(expireStatus)) {
                priority.add(item);
            } else {
                common.add(item);
            }
        }

        // 2. 查调料
        List<String> availableSpices = spiceRepo.findByHouseholdIdAndIsAvailableTrue(householdId)
                .stream()
                .map(s -> s.getMetadata().getName())
                .collect(Collectors.toList());

        // 3. 查厨具
        List<String> availableUtensils = utensilRepo.findByHouseholdIdAndIsAvailableTrue(householdId)
                .stream()
                .map(u -> u.getMetadata().getName())
                .collect(Collectors.toList());

        return KitchenSnapshot.builder()
                .priorityIngredients(priority)
                .commonIngredients(common)
                .availableSpices(availableSpices)
                .availableUtensils(availableUtensils)
                .build();
    }

    /**
     * 辅助方法：统计 Preferences Map 中的频率
     */
    private void countPreferences(Map<String, List<String>> prefs, String key, Map<String, Integer> counter) {
        if (prefs != null && prefs.containsKey(key)) {
            List<String> values = prefs.get(key);
            if (values != null) {
                values.forEach(val -> counter.put(val, counter.getOrDefault(val, 0) + 1));
            }
        }
    }

    // --- 内部传输对象 (仅用于此 Service 内部传递双返回值) ---
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    private static class DinerProfileAndGoal {
        private CompositeNutritionalGoal compositeGoal;
        private DinerProfile dinerProfile;
    }
}
