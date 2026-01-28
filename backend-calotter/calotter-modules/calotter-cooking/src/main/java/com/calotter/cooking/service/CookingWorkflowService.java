package com.calotter.cooking.service;

import com.calotter.cooking.controller.dto.FinishCookingRequest;
import com.calotter.cooking.controller.dto.StartCookingRequest;
import com.calotter.cooking.domain.entity.CookingSession;
import com.calotter.cooking.domain.entity.Dish;
import com.calotter.cooking.repository.CookingSessionRepository;
import com.calotter.cooking.repository.DishRepository;
import com.calotter.cooking.service.dto.MenuDTO;
import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.inventory.domain.entity.Ingredient;
import com.calotter.inventory.domain.entity.LeftoverDish;
import com.calotter.inventory.repository.IngredientRepository;
import com.calotter.inventory.repository.LeftoverDishRepository;
import com.calotter.user.domain.entity.Household;
import com.calotter.user.repository.HouseholdRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CookingWorkflowService {

    private final CookingSessionRepository sessionRepository;
    private final DishRepository dishRepository;
    private final HouseholdRepository householdRepository;
    private final LeftoverDishRepository leftoverDishRepository;
    private final IngredientRepository ingredientRepository;
    private final FavoriteRecipeService favoriteRecipeService;

    @Transactional
    public Long startCooking(StartCookingRequest req) {
        Household household = householdRepository.findById(req.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));

        CookingSession session = new CookingSession();
        session.setHouseholdId(req.getHouseholdId());
        session.setInitiatorId(req.getInitiatorId());
        session.setMenuId(req.getMenuId()); // 存储 menuId（1-3）
        session.setStatus(CookingSession.SessionStatus.PENDING);
        session.setRemainingRatio(1.0);

        List<Dish> dishes = new ArrayList<>();

        // 支持多道菜（Menu）
        if (req.getRecipes() != null && !req.getRecipes().isEmpty()) {
            // 为每道菜创建 Dish
            for (MenuDTO.RecipeDTO recipeDto : req.getRecipes()) {
                // ✅ 每次开始烹饪都创建新的 Dish 快照（保证每次都有独立 dishId）
                Dish dish = favoriteRecipeService.createDishSnapshot(
                    req.getHouseholdId(), recipeDto);
                dishes.add(dish);
            }
            session.setDishes(dishes);
            // 保留第一个作为主菜（向后兼容）
            if (!dishes.isEmpty()) {
                session.setFinalDish(dishes.get(0));
            }
        }
        // 支持单道菜（向后兼容）
        // 注意：这里的 dishId 实际是 recipeId（从收藏开始烹饪时传递的是 UserRecipe ID）
        else if (req.getDishId() != null) {
            // ✅ 重要：从收藏菜谱创建新的 Dish 快照
            // 这样才能保证"每次吃的菜都有独立 dishId"，避免同名/同ID复用导致营养归因错误。
            Dish dish = favoriteRecipeService.cookFromFavorite(req.getHouseholdId(), req.getDishId());
            dishes.add(dish);
            session.setDishes(dishes);
            session.setFinalDish(dish);
        }
        else if (req.getRecipe() != null) {
            Dish dish = favoriteRecipeService.createDishSnapshot(
                req.getHouseholdId(), req.getRecipe());
            dishes.add(dish);
            session.setDishes(dishes);
            session.setFinalDish(dish);
        }
        else {
            throw new IllegalArgumentException("必须提供 dishId、recipe 或 recipes");
        }

        session = sessionRepository.save(session);
        return session.getId();
    }

    @Transactional
    public CookingSession finishCooking(FinishCookingRequest req) {
        CookingSession session = sessionRepository.findById(req.getSessionId())
                .orElseThrow(() -> new IllegalArgumentException("会话不存在: " + req.getSessionId()));
        
        List<Dish> allDishes = session.getDishes();
        if (allDishes == null || allDishes.isEmpty()) {
            // 向后兼容：如果没有 dishes，使用 finalDish
            if (session.getFinalDish() == null) {
                throw new IllegalStateException("会话未绑定菜品");
            }
            allDishes = List.of(session.getFinalDish());
        }

        // 使用 session 中所有新创建的 dishIds
        List<Long> finalCompletedDishIds = allDishes.stream()
                .map(Dish::getId)
                .collect(Collectors.toList());
        
        List<Dish> completedDishes = allDishes;

        // 保存快照（汇总所有已完成的菜品）
        if (req.getFinalIngredients() != null) {
            session.setIngredientsSnapshot(req.getFinalIngredients());
        }
        if (req.getTotalNutrition() != null) {
            session.setTotalNutritionSnapshot(req.getTotalNutrition());
        }
        session.setCompletedDishIds(finalCompletedDishIds);
        session.setRemainingRatio(1.0);
        session.setStatus(CookingSession.SessionStatus.COOKED);
        sessionRepository.save(session);

        // 更新每个dish的总质量（如果前端提供了）
        if (req.getDishTotalWeights() != null && !req.getDishTotalWeights().isEmpty()) {
            for (FinishCookingRequest.DishTotalWeight weightInfo : req.getDishTotalWeights()) {
                Dish targetDish = null;
                
                // 优先使用dishId匹配
                if (weightInfo.getDishId() != null) {
                    targetDish = allDishes.stream()
                            .filter(d -> d.getId().equals(weightInfo.getDishId()))
                            .findFirst()
                            .orElse(null);
                }
                
                // 如果dishId匹配失败，使用recipeId（通过dish的name匹配）
                if (targetDish == null && weightInfo.getRecipeId() != null) {
                    targetDish = allDishes.stream()
                            .filter(d -> d.getName() != null && d.getName().equals(weightInfo.getRecipeId()))
                            .findFirst()
                            .orElse(null);
                }
                
                // 如果找到匹配的dish，更新总质量
                if (targetDish != null && weightInfo.getTotalWeightGram() != null && weightInfo.getTotalWeightGram() > 0) {
                    targetDish.setTotalWeightGram(weightInfo.getTotalWeightGram());
                    dishRepository.save(targetDish);
                    log.info("更新dish总质量: dishId={}, name={}, totalWeightGram={}", 
                            targetDish.getId(), targetDish.getName(), weightInfo.getTotalWeightGram());
                } else {
                    log.warn("未找到匹配的dish或总质量无效: dishId={}, recipeId={}, totalWeightGram={}", 
                            weightInfo.getDishId(), weightInfo.getRecipeId(), weightInfo.getTotalWeightGram());
                }
            }
        }

        // 扣减库存（所有已完成的菜品用到的食材）
        if (req.getFinalIngredients() != null && !req.getFinalIngredients().isEmpty()) {
            deductInventory(session.getHouseholdId(), req.getFinalIngredients());
        }

        // 为每个已完成的菜品创建 LeftoverDish（初始100%，表示全部存入冰箱）
        // 注意：Cooking 模块只负责创建记录，具体管理由 inventory 模块处理
        Household household = householdRepository.findById(session.getHouseholdId())
                .orElseThrow(() -> new IllegalArgumentException("家庭不存在"));
        
        for (Dish dish : completedDishes) {
            if (dish.getTotalWeightGram() != null && dish.getTotalWeightGram() > 0) {
                LeftoverDish leftover = new LeftoverDish();
                leftover.setHousehold(household);
                leftover.setOriginalDishId(dish.getId());
                // ✅ 保存菜品信息快照（避免查询时 JOIN 和循环依赖）
                leftover.setDishName(dish.getName());
                leftover.setCoverImage(dish.getCoverImage());
                leftover.setCategory(dish.getCategory() != null ? dish.getCategory().name() : null);
                leftover.setCaloriesPer100g(dish.getCaloriesPer100g());
                
                // ✅ 计算并保存每100g的营养素快照
                Integer totalWeight = dish.getTotalWeightGram();
                if (totalWeight > 0) {
                    leftover.setProteinPer100g(dish.getTotalProtein() != null ? 
                        (dish.getTotalProtein() * 100.0 / totalWeight) : null);
                    leftover.setFatPer100g(dish.getTotalFat() != null ? 
                        (dish.getTotalFat() * 100.0 / totalWeight) : null);
                    leftover.setCarbPer100g(dish.getTotalCarb() != null ? 
                        (dish.getTotalCarb() * 100.0 / totalWeight) : null);
                    leftover.setFiberPer100g(dish.getTotalFiber() != null ? 
                        (dish.getTotalFiber() * 100.0 / totalWeight) : null);
                }
                
                leftover.setCurrentQuantityGram(dish.getTotalWeightGram());
                leftover.setInitialQuantityGram(dish.getTotalWeightGram()); // 保存初始重量快照
                leftover.setProducedTime(req.getConsumedAt() != null ? req.getConsumedAt() : LocalDateTime.now());
                leftoverDishRepository.save(leftover);
            }
        }

        // 注意：不发布事件，健康模块需要时自己查询数据库
        // 数据已保存在 CookingSession 中（包括 diners 信息），健康模块可以按需查询

        return session;
    }

    /**
     * 扣减库存
     * 根据ingredient name匹配库存并扣减
     * 
     * 工作流：
     * 1. 找到所有同名食材（按过期日期排序，先扣快过期的）
     * 2. 依次扣减，直到满足需求
     * 3. 如果扣减后数量为 0，删除记录
     */
    private void deductInventory(Long householdId, List<FinishCookingRequest.FinalIngredient> ingredients) {
        List<Ingredient> householdIngredients = ingredientRepository.findByHouseholdIdAndQuantityGreaterThan(householdId, 0.0);
        
        for (FinishCookingRequest.FinalIngredient reqIng : ingredients) {
            String reqName = reqIng.getName();
            Double reqAmount = reqIng.getAmountValue();
            String reqUnit = reqIng.getAmountUnit();
            
            if (reqAmount == null || reqAmount <= 0) {
                continue;
            }
            
            // 🔥 标准化需求名称（统一处理连字符、空格、下划线等）
            String normalizedReqName = normalizeIngredientName(reqName);
            
            // 🔥 找到所有匹配的库存食材（同名食材可能有多个，过期日期不同）
            List<Ingredient> matchedIngredients = householdIngredients.stream()
                    .filter(ing -> {
                        String ingName = ing.getMetadata().getName();
                        // 🔥 标准化库存名称
                        String normalizedIngName = normalizeIngredientName(ingName);
                        // 简单匹配：包含关系或完全匹配（使用标准化后的名称）
                        return normalizedIngName.equals(normalizedReqName) || 
                               normalizedIngName.contains(normalizedReqName) || 
                               normalizedReqName.contains(normalizedIngName);
                    })
                    // 🔥 按过期日期排序：先扣减快过期的（FIFO - First In First Out）
                    .sorted((a, b) -> {
                        LocalDate dateA = a.getExpirationDate();
                        LocalDate dateB = b.getExpirationDate();
                        if (dateA == null && dateB == null) return 0;
                        if (dateA == null) return 1; // 没有过期日期的排在后面
                        if (dateB == null) return -1;
                        return dateA.compareTo(dateB); // 早过期的排在前面
                    })
                    .collect(Collectors.toList());
            
            if (matchedIngredients.isEmpty()) {
                log.warn("未找到匹配的库存食材: {}", reqName);
                continue;
            }
            
            // 🔥 依次扣减，直到满足需求
            Double remainingToDeduct = reqAmount;
            
            for (Ingredient ingredient : matchedIngredients) {
                if (remainingToDeduct <= 0) {
                    break; // 已经扣减完成
                }
                
                // 🔥 重要：在循环开始时重新从数据库获取实体，确保获取最新状态
                // 避免处理已被删除的实体
                Ingredient currentIngredient = ingredientRepository.findById(ingredient.getId())
                        .orElse(null);
                
                if (currentIngredient == null) {
                    // 实体已被删除（可能在其他迭代中），跳过
                    log.debug("食材 {} 已被删除，跳过处理", ingredient.getMetadata().getName());
                    continue;
                }
                
                Double currentQuantity = currentIngredient.getQuantity();
                String currentUnit = currentIngredient.getUnit();
                
                // 单位转换：将需求数量转换为当前食材的单位
                // 🔥 传入 StandardIngredient 以便使用 averageGramPerUnit 进行 pcs ↔ g 转换
                Double amountToDeduct = convertUnit(remainingToDeduct, reqUnit, currentUnit, currentIngredient.getMetadata());
                
                if (amountToDeduct == null) {
                    log.warn("单位转换失败: {} {} -> {}，跳过该食材: {}", 
                            remainingToDeduct, reqUnit, currentUnit, 
                            currentIngredient.getMetadata().getName());
                    continue; // 尝试下一个同名食材
                }
                
                if (currentQuantity > 0) {
                    if (amountToDeduct >= currentQuantity) {
                        // 🔥 扣减数量 >= 当前库存，将数量设为 0 并删除记录
                        Double deducted = currentQuantity;
                        
                        // 更新剩余需要扣减的数量（需要反向单位转换回 reqUnit）
                        // 🔥 传入 StandardIngredient 以便使用 averageGramPerUnit 进行 pcs ↔ g 转换
                        Double deductedInReqUnit = convertUnit(deducted, currentUnit, reqUnit, currentIngredient.getMetadata());
                        if (deductedInReqUnit != null) {
                            remainingToDeduct -= deductedInReqUnit;
                        } else {
                            // 如果反向转换失败，使用原始数量（简化处理）
                            remainingToDeduct -= deducted;
                        }
                        
                        // 🔥 使用 deleteById 而不是 delete，避免传递已删除的实体对象
                        Long ingredientId = currentIngredient.getId();
                        ingredientRepository.deleteById(ingredientId);
                        
                        log.info("库存已用完并删除: {} (扣减了 {} {}，剩余需求: {} {})", 
                                currentIngredient.getMetadata().getName(), 
                                deducted, currentUnit,
                                remainingToDeduct > 0 ? remainingToDeduct : 0, reqUnit);
                    } else {
                        // 正常扣减
                        currentIngredient.setQuantity(currentQuantity - amountToDeduct);
                        ingredientRepository.save(currentIngredient);
                        remainingToDeduct = 0.0; // 已完全满足需求
                        
                        log.info("扣减库存: {} {} -> {} {} (扣减了 {} {})", 
                                currentIngredient.getMetadata().getName(), 
                                currentQuantity, 
                                currentIngredient.getQuantity(), 
                                currentUnit,
                                amountToDeduct, currentUnit);
                    }
                }
            }
            
            // 🔥 如果还有剩余需求未满足，记录警告
            if (remainingToDeduct > 0) {
                log.warn("库存不足: {} 还需要 {} {}，但所有同名食材已用完", 
                        reqName, remainingToDeduct, reqUnit);
            }
        }
    }
    
    /**
     * 标准化食材名称
     * 统一处理连字符、空格、下划线等，提高名称匹配的准确性
     * 
     * 例如：
     * - "Red-Pepper" → "red pepper"
     * - "Red Pepper" → "red pepper"
     * - "Red_Pepper" → "red pepper"
     * - "  Red   Pepper  " → "red pepper"
     * 
     * @param name 原始名称
     * @return 标准化后的名称
     */
    private String normalizeIngredientName(String name) {
        if (name == null || name.isEmpty()) {
            return "";
        }
        return name.toLowerCase()
                   .trim()
                   .replace("-", " ")      // 连字符转空格
                   .replace("_", " ")      // 下划线转空格
                   .replaceAll("\\s+", " "); // 多个空格合并为一个空格
    }
    
    /**
     * 单位转换（重载版本，支持使用 StandardIngredient 的新单位转换方法）
     * ✅ 使用新的 StandardIngredient 方法进行单位转换
     * 
     * @param amount 数量
     * @param fromUnit 源单位
     * @param toUnit 目标单位
     * @param metadata 标准食材信息（用于单位转换）
     * @return 转换后的数量，如果无法转换则返回 null
     */
    private Double convertUnit(Double amount, String fromUnit, String toUnit, StandardIngredient metadata) {
        if (fromUnit == null || toUnit == null || amount == null) {
            return null;
        }
        
        // ✅ 使用新的 StandardIngredient 方法进行单位转换
        if (metadata != null) {
            try {
                // 使用 convertBetweenUnits 方法在两个单位之间转换
                return metadata.convertBetweenUnits(amount, fromUnit, toUnit);
            } catch (IllegalArgumentException | IllegalStateException e) {
                log.warn("单位转换失败（使用 StandardIngredient 方法）: {} {} -> {}: {}", 
                    amount, fromUnit, toUnit, e.getMessage());
                // 如果新方法失败，回退到旧的转换逻辑
            }
        }
        
        // 回退到基础转换方法（用于通用单位转换，如 g <-> kg, ml <-> L）
        return convertUnit(amount, fromUnit, toUnit);
    }
    
    /**
     * 单位转换（基础版本）
     * 支持常见的重量、体积和数量单位转换
     * 
     * 转换策略：
     * 1. 相同单位直接返回
     * 2. 重量单位：g ↔ kg ↔ oz ↔ lb
     * 3. 体积单位：ml ↔ l ↔ cup ↔ tbsp ↔ tsp
     * 4. 数量单位：pcs（相同单位）
     * 5. 特殊情况：某些液体食材的 g 和 ml 可以互换（如水、牛奶等）
     * 
     * @param amount 数量
     * @param fromUnit 源单位
     * @param toUnit 目标单位
     * @return 转换后的数量，如果无法转换则返回 null
     */
    private Double convertUnit(Double amount, String fromUnit, String toUnit) {
        if (fromUnit == null || toUnit == null || amount == null) {
            return null;
        }
        
        // 标准化单位名称（去除空格，转小写）
        String normalizedFromUnit = fromUnit.trim().toLowerCase();
        String normalizedToUnit = toUnit.trim().toLowerCase();
        
        // 相同单位直接返回
        if (normalizedFromUnit.equals(normalizedToUnit)) {
            return amount;
        }
        
        // 1. 重量单位转换
        if (isWeightUnit(normalizedFromUnit) && isWeightUnit(normalizedToUnit)) {
            return convertWeight(amount, normalizedFromUnit, normalizedToUnit);
        }
        
        // 2. 体积单位转换
        if (isVolumeUnit(normalizedFromUnit) && isVolumeUnit(normalizedToUnit)) {
            return convertVolume(amount, normalizedFromUnit, normalizedToUnit);
        }
        
        // 3. 数量单位（pcs）转换
        if (isCountUnit(normalizedFromUnit) && isCountUnit(normalizedToUnit)) {
            return amount; // 数量单位相同，直接返回
        }
        
        // 4. 特殊情况：液体食材的 g 和 ml 互换（假设密度为 1g/ml，适用于水、牛奶等）
        if ((normalizedFromUnit.equals("g") && normalizedToUnit.equals("ml")) ||
            (normalizedFromUnit.equals("ml") && normalizedToUnit.equals("g"))) {
            return amount; // 假设 1g = 1ml（简化处理，适用于大部分液体）
        }
        
        // 5. 无法转换的情况
        log.warn("单位转换不支持: {} {} -> {} (源单位类型: {}, 目标单位类型: {})", 
                amount, fromUnit, toUnit,
                getUnitType(normalizedFromUnit), getUnitType(normalizedToUnit));
        return null;
    }
    
    /**
     * 判断是否为重量单位
     */
    private boolean isWeightUnit(String unit) {
        return unit.equals("g") || unit.equals("gram") || unit.equals("grams") ||
               unit.equals("kg") || unit.equals("kilogram") || unit.equals("kilograms") ||
               unit.equals("oz") || unit.equals("ounce") || unit.equals("ounces") ||
               unit.equals("lb") || unit.equals("lbs") || unit.equals("pound") || unit.equals("pounds");
    }
    
    /**
     * 判断是否为体积单位
     */
    private boolean isVolumeUnit(String unit) {
        return unit.equals("ml") || unit.equals("milliliter") || unit.equals("milliliters") ||
               unit.equals("l") || unit.equals("liter") || unit.equals("liters") ||
               unit.equals("cup") || unit.equals("cups") ||
               unit.equals("tbsp") || unit.equals("tablespoon") || unit.equals("tablespoons") ||
               unit.equals("tsp") || unit.equals("teaspoon") || unit.equals("teaspoons");
    }
    
    /**
     * 判断是否为数量单位
     */
    private boolean isCountUnit(String unit) {
        return unit.equals("pcs") || unit.equals("pc") || unit.equals("piece") || unit.equals("pieces") ||
               unit.equals("item") || unit.equals("items") || unit.equals("unit") || unit.equals("units");
    }
    
    /**
     * 获取单位类型（用于日志）
     */
    private String getUnitType(String unit) {
        if (isWeightUnit(unit)) return "重量";
        if (isVolumeUnit(unit)) return "体积";
        if (isCountUnit(unit)) return "数量";
        return "未知";
    }
    
    /**
     * 重量单位转换
     * 基准单位：g（克）
     */
    private Double convertWeight(Double amount, String fromUnit, String toUnit) {
        // 先转换为基准单位（g）
        Double amountInGrams = toGrams(amount, fromUnit);
        if (amountInGrams == null) {
            return null;
        }
        
        // 从基准单位转换为目标单位
        return fromGrams(amountInGrams, toUnit);
    }
    
    /**
     * 将任意重量单位转换为克（g）
     */
    private Double toGrams(Double amount, String unit) {
        switch (unit) {
            case "g":
            case "gram":
            case "grams":
                return amount;
            case "kg":
            case "kilogram":
            case "kilograms":
                return amount * 1000.0;
            case "oz":
            case "ounce":
            case "ounces":
                return amount * 28.3495; // 1 oz = 28.3495 g
            case "lb":
            case "lbs":
            case "pound":
            case "pounds":
                return amount * 453.592; // 1 lb = 453.592 g
            default:
                return null;
        }
    }
    
    /**
     * 将克（g）转换为任意重量单位
     */
    private Double fromGrams(Double grams, String unit) {
        switch (unit) {
            case "g":
            case "gram":
            case "grams":
                return grams;
            case "kg":
            case "kilogram":
            case "kilograms":
                return grams / 1000.0;
            case "oz":
            case "ounce":
            case "ounces":
                return grams / 28.3495;
            case "lb":
            case "lbs":
            case "pound":
            case "pounds":
                return grams / 453.592;
            default:
                return null;
        }
    }
    
    /**
     * 体积单位转换
     * 基准单位：ml（毫升）
     */
    private Double convertVolume(Double amount, String fromUnit, String toUnit) {
        // 先转换为基准单位（ml）
        Double amountInMl = toMilliliters(amount, fromUnit);
        if (amountInMl == null) {
            return null;
        }
        
        // 从基准单位转换为目标单位
        return fromMilliliters(amountInMl, toUnit);
    }
    
    /**
     * 将任意体积单位转换为毫升（ml）
     */
    private Double toMilliliters(Double amount, String unit) {
        switch (unit) {
            case "ml":
            case "milliliter":
            case "milliliters":
                return amount;
            case "l":
            case "liter":
            case "liters":
                return amount * 1000.0;
            case "cup":
            case "cups":
                return amount * 236.588; // 1 cup (US) = 236.588 ml
            case "tbsp":
            case "tablespoon":
            case "tablespoons":
                return amount * 14.7868; // 1 tbsp (US) = 14.7868 ml
            case "tsp":
            case "teaspoon":
            case "teaspoons":
                return amount * 4.92892; // 1 tsp (US) = 4.92892 ml
            default:
                return null;
        }
    }
    
    /**
     * 将毫升（ml）转换为任意体积单位
     */
    private Double fromMilliliters(Double ml, String unit) {
        switch (unit) {
            case "ml":
            case "milliliter":
            case "milliliters":
                return ml;
            case "l":
            case "liter":
            case "liters":
                return ml / 1000.0;
            case "cup":
            case "cups":
                return ml / 236.588;
            case "tbsp":
            case "tablespoon":
            case "tablespoons":
                return ml / 14.7868;
            case "tsp":
            case "teaspoon":
            case "teaspoons":
                return ml / 4.92892;
            default:
                return null;
        }
    }

    private Integer toInt(Double v) {
        return v == null ? null : v.intValue();
    }
}
