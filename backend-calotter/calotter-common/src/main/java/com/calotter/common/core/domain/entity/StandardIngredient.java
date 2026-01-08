package com.calotter.common.core.domain.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;
import java.util.Arrays;

/**
 * 标准食材库
 */
@Data
@Entity
@Table(name = "ref_standard_ingredients")
public class StandardIngredient {
    
    @Id
    private Long id; // 手动分配 ID (e.g. 1001)

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String category; // MEAT, VEG

    // 营养素 (每100g 或 每100ml，基于 standardUnit)
    private Integer calories;
    private Double protein;
    private Double fat;
    private Double carb;
    private Double fiber;

    /**
     * ✅ 新增：单位规范化字段
     * primary_unit: 主单位（如 pcs, g, ml）
     * secondary_unit: 次单位（如 g, kg, L）
     * unit_conversion_factor: 单位转换系数，1 primary_unit = unit_conversion_factor secondary_unit
     * standard_unit: 标准单位（g 或 ml），用于营养计算
     */
    @Column(nullable = false)
    private String primaryUnit;

    @Column(nullable = false)
    private String secondaryUnit;

    @Column(nullable = false)
    private Double unitConversionFactor;

    @Column(nullable = false)
    private String standardUnit;

    /**
     * 🔄 保留但标记为 deprecated（向后兼容）
     * 如果 primaryUnit = pcs 且 standardUnit = g，则此值等于 unitConversionFactor
     * 用于 Ingredient 中 quantity * averageGramPerUnit 计算总摄入
     */
    @Deprecated
    private Integer averageGramPerUnit;

    // 保质期 (天)
    private Integer shelfLifePantry;
    private Integer shelfLifeFridge;
    private Integer shelfLifeFreezer;

    @Enumerated(EnumType.STRING)
    private StorageLocation defaultLocation;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "ingredient_allergens",
        joinColumns = @JoinColumn(name = "ingredient_id"),
        inverseJoinColumns = @JoinColumn(name = "allergen_id")
    )
    private List<RefAllergen> containedAllergens;
    
    /**
     * ✅ 验证单位是否合法
     * @param unit 要验证的单位
     * @return 如果单位合法返回 true，否则返回 false
     */
    public boolean isUnitAllowed(String unit) {
        if (unit == null || primaryUnit == null || secondaryUnit == null) {
            return false;
        }
        String normalizedUnit = unit.trim().toLowerCase();
        return primaryUnit.toLowerCase().equals(normalizedUnit) 
            || secondaryUnit.toLowerCase().equals(normalizedUnit);
    }
    
    /**
     * ✅ 获取允许的单位列表
     * @return 允许的单位列表
     */
    public List<String> getAllowedUnits() {
        if (primaryUnit == null || secondaryUnit == null) {
            return List.of();
        }
        return Arrays.asList(primaryUnit, secondaryUnit);
    }
    
    /**
     * ✅ 转换为标准单位（用于营养计算）
     * @param quantity 数量
     * @param unit 单位
     * @return 转换为标准单位后的数量
     * @throws IllegalArgumentException 如果单位不合法
     */
    public Double convertToStandardUnit(Double quantity, String unit) {
        if (quantity == null || unit == null) {
            throw new IllegalArgumentException("数量和单位不能为空");
        }
        
        String normalizedUnit = unit.trim().toLowerCase();
        
        if (!isUnitAllowed(normalizedUnit)) {
            throw new IllegalArgumentException(
                String.format("单位 '%s' 不合法。食材 '%s' 允许的单位为: %s", 
                    unit, name, getAllowedUnits()));
        }
        
        // 如果已经是标准单位，直接返回
        if (standardUnit != null && standardUnit.toLowerCase().equals(normalizedUnit)) {
            return quantity;
        }
        
        // 转换逻辑：
        // 如果 primaryUnit 是标准单位，则需要将 secondaryUnit -> primaryUnit
        // 如果 secondaryUnit 是标准单位，则需要将 primaryUnit -> secondaryUnit
        
        if (primaryUnit != null && primaryUnit.toLowerCase().equals(standardUnit != null ? standardUnit.toLowerCase() : "")) {
            // 标准单位是 primaryUnit
            if (secondaryUnit != null && secondaryUnit.toLowerCase().equals(normalizedUnit)) {
                // secondaryUnit -> primaryUnit (标准单位)
                // 例如：g -> pcs，需要除以转换系数
                // 1 secondaryUnit = 1/unitConversionFactor primaryUnit
                if (unitConversionFactor == null || unitConversionFactor == 0) {
                    throw new IllegalStateException("单位转换系数无效");
                }
                return quantity / unitConversionFactor;
            }
        } else if (secondaryUnit != null && secondaryUnit.toLowerCase().equals(standardUnit != null ? standardUnit.toLowerCase() : "")) {
            // 标准单位是 secondaryUnit
            if (primaryUnit != null && primaryUnit.toLowerCase().equals(normalizedUnit)) {
                // primaryUnit -> secondaryUnit (标准单位)
                // 例如：pcs -> g，需要乘以转换系数
                // 1 primaryUnit = unitConversionFactor secondaryUnit
                if (unitConversionFactor == null) {
                    throw new IllegalStateException("单位转换系数无效");
                }
                return quantity * unitConversionFactor;
            }
        }
        
        // 如果两个单位都不是标准单位，可能需要更复杂的转换
        // 这里简化处理：假设标准单位总是 primaryUnit 或 secondaryUnit 之一
        throw new IllegalStateException(
            String.format("标准单位 '%s' 必须是 primaryUnit 或 secondaryUnit 之一", standardUnit));
    }
    
    /**
     * ✅ 在两个单位之间转换
     * @param quantity 数量
     * @param fromUnit 源单位
     * @param toUnit 目标单位
     * @return 转换后的数量
     * @throws IllegalArgumentException 如果单位不合法
     */
    public Double convertBetweenUnits(Double quantity, String fromUnit, String toUnit) {
        if (quantity == null || fromUnit == null || toUnit == null) {
            throw new IllegalArgumentException("参数不能为空");
        }
        
        String normalizedFromUnit = fromUnit.trim().toLowerCase();
        String normalizedToUnit = toUnit.trim().toLowerCase();
        
        if (!isUnitAllowed(normalizedFromUnit) || !isUnitAllowed(normalizedToUnit)) {
            throw new IllegalArgumentException(
                String.format("单位不合法。允许的单位为: %s", getAllowedUnits()));
        }
        
        // 相同单位直接返回
        if (normalizedFromUnit.equals(normalizedToUnit)) {
            return quantity;
        }
        
        // 转换：先转换为标准单位，再转换为目标单位
        Double inStandardUnit = convertToStandardUnit(quantity, normalizedFromUnit);
        
        // 从标准单位转换为目标单位（反向转换）
        if (primaryUnit != null && primaryUnit.toLowerCase().equals(standardUnit != null ? standardUnit.toLowerCase() : "")) {
            // 标准单位是 primaryUnit
            if (secondaryUnit != null && secondaryUnit.toLowerCase().equals(normalizedToUnit)) {
                // primaryUnit -> secondaryUnit: 乘以转换系数
                if (unitConversionFactor == null) {
                    throw new IllegalStateException("单位转换系数无效");
                }
                return inStandardUnit * unitConversionFactor;
            }
        } else if (secondaryUnit != null && secondaryUnit.toLowerCase().equals(standardUnit != null ? standardUnit.toLowerCase() : "")) {
            // 标准单位是 secondaryUnit
            if (primaryUnit != null && primaryUnit.toLowerCase().equals(normalizedToUnit)) {
                // secondaryUnit -> primaryUnit: 除以转换系数
                if (unitConversionFactor == null || unitConversionFactor == 0) {
                    throw new IllegalStateException("单位转换系数无效");
                }
                return inStandardUnit / unitConversionFactor;
            }
        }
        
        // 如果目标单位就是标准单位，直接返回
        if (standardUnit != null && standardUnit.toLowerCase().equals(normalizedToUnit)) {
            return inStandardUnit;
        }
        
        return quantity; // 如果已经是标准单位且目标也是标准单位，直接返回
    }
    
    /**
     * 🔄 向后兼容方法（可选）
     * @return averageGramPerUnit 的值，如果 primaryUnit = pcs 且 standardUnit = g，则返回转换系数
     */
    @Deprecated
    public Integer getAverageGramPerUnit() {
        // 如果 primaryUnit = pcs 且 standardUnit = g，则返回转换系数
        if (primaryUnit != null && primaryUnit.equalsIgnoreCase("pcs") 
            && standardUnit != null && standardUnit.equalsIgnoreCase("g")
            && unitConversionFactor != null) {
            return unitConversionFactor.intValue();
        }
        return averageGramPerUnit; // 返回旧值
    }
    
    public enum StorageLocation {
        FRIDGE, FREEZER, PANTRY
    }
}
