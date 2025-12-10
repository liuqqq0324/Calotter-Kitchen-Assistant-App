package com.calotter.homepage.service.impl;

import com.calotter.common.core.utils.MapstructUtils;
import com.calotter.homepage.domain.IntakeRecord;
import com.calotter.homepage.domain.vo.IntakeRecordVo;
import com.calotter.homepage.mapper.IntakeRecordMapper;
import com.calotter.homepage.service.IIntakeService;
import com.calotter.homepage.service.INutritionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Intake Service Implementation
 * 摄入记录管理服务实现类
 *
 * @author Auto Generated
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class IntakeServiceImpl implements IIntakeService {

    private final IntakeRecordMapper intakeRecordMapper;
    private final INutritionService nutritionService;

    @Override
    public TodayIntakesResponse getTodayIntakes(Long userId, String source) {
        LocalDate today = LocalDate.now();
        List<IntakeRecordVo> records;

        if ("recipe".equals(source)) {
            records = intakeRecordMapper.selectByUserIdAndDateAndSourceType(userId, today, "recipe");
        } else if ("manual".equals(source)) {
            records = intakeRecordMapper.selectByUserIdAndDateAndSourceType(userId, today, "manual");
        } else {
            records = intakeRecordMapper.selectByUserIdAndDate(userId, today);
        }

        TodayIntakesResponse response = new TodayIntakesResponse();
        response.date = today;
        response.source = source;

        List<TodayIntakesResponse.IntakeItem> items = records.stream()
                .map(this::convertToIntakeItem)
                .collect(Collectors.toList());

        response.items = items;
        return response;
    }

    @Override
    public UpdateIntakeResponse updateIntakePercentage(Long userId, Long intakeId, BigDecimal consumedPercentage) {
        IntakeRecordVo recordVo = intakeRecordMapper.selectVoById(intakeId);
        if (recordVo == null) {
            throw new RuntimeException("Intake record not found");
        }

        IntakeRecord record = MapstructUtils.convert(recordVo, IntakeRecord.class);
        if (!record.getUserId().equals(userId)) {
            throw new RuntimeException("Unauthorized: intake record does not belong to user");
        }

        record.setConsumedPercentage(consumedPercentage);
        record.calculateEffectiveNutrition();
        intakeRecordMapper.updateById(record);

        UpdateIntakeResponse response = new UpdateIntakeResponse();
        response.intake = convertToUpdateIntakeItem(record);

        // Get weekly summary
        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = nutritionService.getWeeklyNutritionSummary(userId);
        UpdateIntakeResponse.WeeklySummary summary = new UpdateIntakeResponse.WeeklySummary();
        summary.weekStart = weeklySummary.weekStart;
        summary.weekEnd = weeklySummary.weekEnd;

        UpdateIntakeResponse.NutritionValues consumed = new UpdateIntakeResponse.NutritionValues();
        consumed.energy = weeklySummary.consumed.energy;
        consumed.fat = weeklySummary.consumed.fat;
        consumed.carbohydrates = weeklySummary.consumed.carbohydrates;
        consumed.protein = weeklySummary.consumed.protein;
        summary.consumed = consumed;

        response.weeklySummary = summary;
        return response;
    }

    @Override
    public AddManualIntakeResponse addManualIntake(Long userId, LocalDate date, String foodName, String portionDescription) {
        IntakeRecord record = new IntakeRecord();
        record.setUserId(userId);
        record.setDate(date != null ? date : LocalDate.now());
        record.setSourceType("manual");
        record.setManualFoodName(foodName);
        record.setPortionDescription(portionDescription);

        // Estimate nutrition values
        BigDecimal estimatedEnergy = estimateEnergyFromFoodName(foodName);
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

        intakeRecordMapper.insert(record);

        AddManualIntakeResponse response = new AddManualIntakeResponse();
        AddManualIntakeResponse.IntakeItem item = new AddManualIntakeResponse.IntakeItem();
        item.intakeId = record.getId();
        item.sourceType = record.getSourceType();
        item.date = record.getDate();
        item.manualFoodName = record.getManualFoodName();
        item.portionDescription = record.getPortionDescription();

        AddManualIntakeResponse.NutritionValues nutrition = new AddManualIntakeResponse.NutritionValues();
        nutrition.energy = record.getEffectiveEnergy();
        nutrition.fat = record.getEffectiveFat();
        nutrition.carbohydrates = record.getEffectiveCarbohydrates();
        nutrition.protein = record.getEffectiveProtein();
        item.effectiveNutrition = nutrition;

        response.intake = item;

        // Get weekly summary
        INutritionService.WeeklyNutritionSummaryResponse weeklySummary = nutritionService.getWeeklyNutritionSummary(userId);
        AddManualIntakeResponse.WeeklySummary summary = new AddManualIntakeResponse.WeeklySummary();
        summary.weekStart = weeklySummary.weekStart;
        summary.weekEnd = weeklySummary.weekEnd;

        AddManualIntakeResponse.NutritionValues consumed = new AddManualIntakeResponse.NutritionValues();
        consumed.energy = weeklySummary.consumed.energy;
        consumed.fat = weeklySummary.consumed.fat;
        consumed.carbohydrates = weeklySummary.consumed.carbohydrates;
        consumed.protein = weeklySummary.consumed.protein;
        summary.consumed = consumed;

        response.weeklySummary = summary;
        return response;
    }

    private TodayIntakesResponse.IntakeItem convertToIntakeItem(IntakeRecordVo vo) {
        TodayIntakesResponse.IntakeItem item = new TodayIntakesResponse.IntakeItem();
        item.intakeId = vo.getId();
        item.sourceType = vo.getSourceType();

        if ("recipe".equals(vo.getSourceType())) {
            item.recipeId = vo.getRecipeId();
            item.recipeTitle = vo.getRecipeTitle();
        } else {
            item.manualFoodName = vo.getManualFoodName();
        }

        item.consumedPercentage = vo.getConsumedPercentage();

        TodayIntakesResponse.NutritionValues baseNutrition = new TodayIntakesResponse.NutritionValues();
        baseNutrition.energy = vo.getBaseEnergy();
        baseNutrition.fat = vo.getBaseFat();
        baseNutrition.carbohydrates = vo.getBaseCarbohydrates();
        baseNutrition.protein = vo.getBaseProtein();
        item.baseNutrition = baseNutrition;

        TodayIntakesResponse.NutritionValues effectiveNutrition = new TodayIntakesResponse.NutritionValues();
        effectiveNutrition.energy = vo.getEffectiveEnergy();
        effectiveNutrition.fat = vo.getEffectiveFat();
        effectiveNutrition.carbohydrates = vo.getEffectiveCarbohydrates();
        effectiveNutrition.protein = vo.getEffectiveProtein();
        item.effectiveNutrition = effectiveNutrition;

        return item;
    }

    private UpdateIntakeResponse.IntakeItem convertToUpdateIntakeItem(IntakeRecord record) {
        UpdateIntakeResponse.IntakeItem item = new UpdateIntakeResponse.IntakeItem();
        item.intakeId = record.getId();
        item.sourceType = record.getSourceType();
        item.recipeId = record.getRecipeId();
        item.recipeTitle = record.getRecipeTitle();
        item.date = record.getDate();
        item.consumedPercentage = record.getConsumedPercentage();

        UpdateIntakeResponse.NutritionValues baseNutrition = new UpdateIntakeResponse.NutritionValues();
        baseNutrition.energy = record.getBaseEnergy();
        baseNutrition.fat = record.getBaseFat();
        baseNutrition.carbohydrates = record.getBaseCarbohydrates();
        baseNutrition.protein = record.getBaseProtein();
        item.baseNutrition = baseNutrition;

        UpdateIntakeResponse.NutritionValues effectiveNutrition = new UpdateIntakeResponse.NutritionValues();
        effectiveNutrition.energy = record.getEffectiveEnergy();
        effectiveNutrition.fat = record.getEffectiveFat();
        effectiveNutrition.carbohydrates = record.getEffectiveCarbohydrates();
        effectiveNutrition.protein = record.getEffectiveProtein();
        item.effectiveNutrition = effectiveNutrition;

        return item;
    }

    private BigDecimal estimateEnergyFromFoodName(String foodName) {
        String lowerName = foodName.toLowerCase();

        if (lowerName.contains("rice")) {
            return BigDecimal.valueOf(130);
        } else if (lowerName.contains("chicken")) {
            return BigDecimal.valueOf(165);
        } else if (lowerName.contains("egg")) {
            return BigDecimal.valueOf(155);
        } else if (lowerName.contains("noodle") || lowerName.contains("pasta")) {
            return BigDecimal.valueOf(131);
        } else {
            return BigDecimal.valueOf(200);
        }
    }
}
