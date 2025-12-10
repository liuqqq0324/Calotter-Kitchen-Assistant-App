package com.souschef.service;

import com.souschef.dto.intake.AddManualIntakeRequest;
import com.souschef.dto.intake.AddManualIntakeResponse;
import com.souschef.dto.intake.TodayIntakesResponse;
import com.souschef.dto.intake.UpdateIntakeRequest;
import com.souschef.dto.intake.UpdateIntakeResponse;
import com.souschef.dto.nutrition.WeeklyNutritionSummaryResponse;
import com.souschef.entity.IntakeRecord;
import com.souschef.entity.Recipe;
import com.souschef.entity.RecipeNutrition;
import com.souschef.repository.IntakeRecordRepository;
import com.souschef.repository.RecipeNutritionRepository;
import com.souschef.repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class IntakeService {
    
    @Autowired
    private IntakeRecordRepository intakeRecordRepository;
    
    @Autowired
    private RecipeRepository recipeRepository;
    
    @Autowired
    private RecipeNutritionRepository recipeNutritionRepository;
    
    @Autowired
    private NutritionService nutritionService;
    
    /**
     * Get today's intake records by source type
     */
    public TodayIntakesResponse getTodayIntakes(Long userId, String source) {
        LocalDate today = LocalDate.now();
        List<IntakeRecord> records;
        
        if ("recipe".equals(source)) {
            records = intakeRecordRepository.findByUserIdAndDateAndSourceType(userId, today, "recipe");
        } else if ("manual".equals(source)) {
            records = intakeRecordRepository.findByUserIdAndDateAndSourceType(userId, today, "manual");
        } else {
            records = intakeRecordRepository.findByUserIdAndDate(userId, today);
        }
        
        TodayIntakesResponse response = new TodayIntakesResponse();
        response.setDate(today);
        response.setSource(source);
        
        List<TodayIntakesResponse.IntakeItem> items = records.stream()
                .map(this::convertToIntakeItem)
                .collect(Collectors.toList());
        
        response.setItems(items);
        return response;
    }
    
    /**
     * Update intake percentage
     */
    public UpdateIntakeResponse updateIntakePercentage(Long userId, Integer intakeId, UpdateIntakeRequest request) {
        Optional<IntakeRecord> recordOpt = intakeRecordRepository.findById(intakeId);
        if (recordOpt.isEmpty()) {
            throw new RuntimeException("Intake record not found");
        }
        
        IntakeRecord record = recordOpt.get();
        if (!record.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized: intake record does not belong to user");
        }
        
        record.setConsumedPercentage(request.getConsumedPercentage());
        record.calculateEffectiveNutrition();
        record = intakeRecordRepository.save(record);
        
        UpdateIntakeResponse response = new UpdateIntakeResponse();
        response.setIntake(convertToUpdateIntakeItem(record));
        
        // Get weekly summary
        WeeklyNutritionSummaryResponse weeklySummary = nutritionService.getWeeklyNutritionSummary(userId);
        UpdateIntakeResponse.WeeklySummary summary = new UpdateIntakeResponse.WeeklySummary();
        summary.setWeekStart(weeklySummary.getWeekStart());
        summary.setWeekEnd(weeklySummary.getWeekEnd());
        
        UpdateIntakeResponse.NutritionValues consumed = new UpdateIntakeResponse.NutritionValues();
        consumed.setEnergy(weeklySummary.getConsumed().getEnergy());
        consumed.setFat(weeklySummary.getConsumed().getFat());
        consumed.setCarbohydrates(weeklySummary.getConsumed().getCarbohydrates());
        consumed.setProtein(weeklySummary.getConsumed().getProtein());
        summary.setConsumed(consumed);
        
        response.setWeeklySummary(summary);
        return response;
    }
    
    /**
     * Add manual intake
     */
    public AddManualIntakeResponse addManualIntake(Long userId, AddManualIntakeRequest request) {
        IntakeRecord record = new IntakeRecord();
        record.setUserId(userId);
        record.setDate(request.getDate() != null ? request.getDate() : LocalDate.now());
        record.setSourceType("manual");
        record.setManualFoodName(request.getFoodName());
        record.setPortionDescription(request.getPortionDescription());
        
        // For manual intake, we need to estimate nutrition values
        // This is a simplified version - in production, you might want to use a food database API
        BigDecimal estimatedEnergy = estimateEnergyFromFoodName(request.getFoodName());
        BigDecimal estimatedFat = estimatedEnergy.multiply(BigDecimal.valueOf(0.3))
                .divide(BigDecimal.valueOf(9), 2, java.math.RoundingMode.HALF_UP);
        BigDecimal estimatedCarbs = estimatedEnergy.multiply(BigDecimal.valueOf(0.5))
                .divide(BigDecimal.valueOf(4), 2, java.math.RoundingMode.HALF_UP);
        BigDecimal estimatedProtein = estimatedEnergy.multiply(BigDecimal.valueOf(0.2))
                .divide(BigDecimal.valueOf(4), 2, java.math.RoundingMode.HALF_UP);
        
        record.setBaseEnergy(estimatedEnergy);
        record.setBaseFat(estimatedFat);
        record.setBaseCarbohydrates(estimatedCarbs);
        record.setBaseProtein(estimatedProtein);
        record.setConsumedPercentage(BigDecimal.valueOf(100));
        record.calculateEffectiveNutrition();
        
        record = intakeRecordRepository.save(record);
        
        AddManualIntakeResponse response = new AddManualIntakeResponse();
        AddManualIntakeResponse.IntakeItem item = new AddManualIntakeResponse.IntakeItem();
        item.setIntakeId(record.getId());
        item.setSourceType(record.getSourceType());
        item.setDate(record.getDate());
        item.setManualFoodName(record.getManualFoodName());
        item.setPortionDescription(record.getPortionDescription());
        
        AddManualIntakeResponse.NutritionValues nutrition = new AddManualIntakeResponse.NutritionValues();
        nutrition.setEnergy(record.getEffectiveEnergy());
        nutrition.setFat(record.getEffectiveFat());
        nutrition.setCarbohydrates(record.getEffectiveCarbohydrates());
        nutrition.setProtein(record.getEffectiveProtein());
        item.setEffectiveNutrition(nutrition);
        
        response.setIntake(item);
        
        // Get weekly summary
        WeeklyNutritionSummaryResponse weeklySummary = nutritionService.getWeeklyNutritionSummary(userId);
        AddManualIntakeResponse.WeeklySummary summary = new AddManualIntakeResponse.WeeklySummary();
        summary.setWeekStart(weeklySummary.getWeekStart());
        summary.setWeekEnd(weeklySummary.getWeekEnd());
        
        AddManualIntakeResponse.NutritionValues consumed = new AddManualIntakeResponse.NutritionValues();
        consumed.setEnergy(weeklySummary.getConsumed().getEnergy());
        consumed.setFat(weeklySummary.getConsumed().getFat());
        consumed.setCarbohydrates(weeklySummary.getConsumed().getCarbohydrates());
        consumed.setProtein(weeklySummary.getConsumed().getProtein());
        summary.setConsumed(consumed);
        
        response.setWeeklySummary(summary);
        return response;
    }
    
    /**
     * Convert IntakeRecord to TodayIntakesResponse.IntakeItem
     */
    private TodayIntakesResponse.IntakeItem convertToIntakeItem(IntakeRecord record) {
        TodayIntakesResponse.IntakeItem item = new TodayIntakesResponse.IntakeItem();
        item.setIntakeId(record.getId());
        item.setSourceType(record.getSourceType());
        
        if ("recipe".equals(record.getSourceType())) {
            item.setRecipeId(record.getRecipeId());
            item.setRecipeTitle(record.getRecipeTitle());
        } else {
            item.setManualFoodName(record.getManualFoodName());
        }
        
        item.setConsumedPercentage(record.getConsumedPercentage());
        
        TodayIntakesResponse.NutritionValues baseNutrition = new TodayIntakesResponse.NutritionValues();
        baseNutrition.setEnergy(record.getBaseEnergy());
        baseNutrition.setFat(record.getBaseFat());
        baseNutrition.setCarbohydrates(record.getBaseCarbohydrates());
        baseNutrition.setProtein(record.getBaseProtein());
        item.setBaseNutrition(baseNutrition);
        
        TodayIntakesResponse.NutritionValues effectiveNutrition = new TodayIntakesResponse.NutritionValues();
        effectiveNutrition.setEnergy(record.getEffectiveEnergy());
        effectiveNutrition.setFat(record.getEffectiveFat());
        effectiveNutrition.setCarbohydrates(record.getEffectiveCarbohydrates());
        effectiveNutrition.setProtein(record.getEffectiveProtein());
        item.setEffectiveNutrition(effectiveNutrition);
        
        return item;
    }
    
    /**
     * Convert IntakeRecord to UpdateIntakeResponse.IntakeItem
     */
    private UpdateIntakeResponse.IntakeItem convertToUpdateIntakeItem(IntakeRecord record) {
        UpdateIntakeResponse.IntakeItem item = new UpdateIntakeResponse.IntakeItem();
        item.setIntakeId(record.getId());
        item.setSourceType(record.getSourceType());
        item.setRecipeId(record.getRecipeId());
        item.setRecipeTitle(record.getRecipeTitle());
        item.setDate(record.getDate());
        item.setConsumedPercentage(record.getConsumedPercentage());
        
        UpdateIntakeResponse.NutritionValues baseNutrition = new UpdateIntakeResponse.NutritionValues();
        baseNutrition.setEnergy(record.getBaseEnergy());
        baseNutrition.setFat(record.getBaseFat());
        baseNutrition.setCarbohydrates(record.getBaseCarbohydrates());
        baseNutrition.setProtein(record.getBaseProtein());
        item.setBaseNutrition(baseNutrition);
        
        UpdateIntakeResponse.NutritionValues effectiveNutrition = new UpdateIntakeResponse.NutritionValues();
        effectiveNutrition.setEnergy(record.getEffectiveEnergy());
        effectiveNutrition.setFat(record.getEffectiveFat());
        effectiveNutrition.setCarbohydrates(record.getEffectiveCarbohydrates());
        effectiveNutrition.setProtein(record.getEffectiveProtein());
        item.setEffectiveNutrition(effectiveNutrition);
        
        return item;
    }
    
    /**
     * Estimate energy from food name (simplified - in production use food database)
     */
    private BigDecimal estimateEnergyFromFoodName(String foodName) {
        // This is a very simplified estimation
        // In production, you should use a food database API like USDA FoodData Central
        String lowerName = foodName.toLowerCase();
        
        if (lowerName.contains("rice")) {
            return BigDecimal.valueOf(130); // per 100g
        } else if (lowerName.contains("chicken")) {
            return BigDecimal.valueOf(165); // per 100g
        } else if (lowerName.contains("egg")) {
            return BigDecimal.valueOf(155); // per 100g
        } else if (lowerName.contains("noodle") || lowerName.contains("pasta")) {
            return BigDecimal.valueOf(131); // per 100g
        } else {
            // Default estimation: 200 kcal per serving
            return BigDecimal.valueOf(200);
        }
    }
    
    /**
     * Create intake record from recipe
     * This method can be called when a user records consuming a recipe
     */
    public IntakeRecord createIntakeFromRecipe(Long userId, Integer recipeId, LocalDate date, BigDecimal consumedPercentage) {
        Optional<Recipe> recipeOpt = recipeRepository.findById(recipeId);
        if (recipeOpt.isEmpty()) {
            throw new RuntimeException("Recipe not found");
        }
        
        Recipe recipe = recipeOpt.get();
        
        // Get nutrition information
        Optional<RecipeNutrition> nutritionOpt = recipeNutritionRepository.findByRecipeId(recipeId);
        
        BigDecimal energy, fat, carbs, protein;
        
        if (nutritionOpt.isPresent()) {
            RecipeNutrition nutrition = nutritionOpt.get();
            energy = nutrition.getEnergy();
            fat = nutrition.getFat();
            carbs = nutrition.getCarbohydrates();
            protein = nutrition.getProtein();
        } else {
            // Fallback: estimate from calories_per_serving
            if (recipe.getCaloriesPerServing() != null) {
                energy = BigDecimal.valueOf(recipe.getCaloriesPerServing());
                // Estimate macronutrients (simplified)
                fat = energy.multiply(BigDecimal.valueOf(0.25)).divide(BigDecimal.valueOf(9), 2, java.math.RoundingMode.HALF_UP);
                carbs = energy.multiply(BigDecimal.valueOf(0.5)).divide(BigDecimal.valueOf(4), 2, java.math.RoundingMode.HALF_UP);
                protein = energy.multiply(BigDecimal.valueOf(0.25)).divide(BigDecimal.valueOf(4), 2, java.math.RoundingMode.HALF_UP);
            } else {
                // Default values
                energy = BigDecimal.valueOf(200);
                fat = BigDecimal.valueOf(10);
                carbs = BigDecimal.valueOf(25);
                protein = BigDecimal.valueOf(10);
            }
        }
        
        IntakeRecord record = new IntakeRecord();
        record.setUserId(userId);
        record.setDate(date);
        record.setSourceType("recipe");
        record.setRecipeId(recipeId);
        record.setRecipeTitle(recipe.getName());
        record.setBaseEnergy(energy);
        record.setBaseFat(fat);
        record.setBaseCarbohydrates(carbs);
        record.setBaseProtein(protein);
        record.setConsumedPercentage(consumedPercentage != null ? consumedPercentage : BigDecimal.valueOf(100));
        record.calculateEffectiveNutrition();
        
        return intakeRecordRepository.save(record);
    }
}
