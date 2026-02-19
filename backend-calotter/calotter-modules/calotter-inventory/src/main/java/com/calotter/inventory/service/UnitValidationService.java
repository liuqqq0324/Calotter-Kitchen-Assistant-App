package com.calotter.inventory.service;

import com.calotter.common.core.domain.entity.StandardIngredient;
import com.calotter.common.core.repository.StandardIngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 单位验证服务
 * 用于验证和获取食材的允许单位
 */
@Service
@RequiredArgsConstructor
public class UnitValidationService {
    
    private final StandardIngredientRepository standardIngredientRepository;
    
    /**
     * 验证单位是否合法
     * @param standardIngredientId 标准食材ID
     * @param unit 要验证的单位
     * @throws IllegalArgumentException 如果单位不合法
     */
    public void validateUnit(Long standardIngredientId, String unit) {
        StandardIngredient standardIngredient = standardIngredientRepository.findById(standardIngredientId)
                .orElseThrow(() -> new IllegalArgumentException("标准食材不存在: " + standardIngredientId));
        
        if (!standardIngredient.isUnitAllowed(unit)) {
            throw new IllegalArgumentException(
                String.format("单位 '%s' 不合法。食材 '%s' 允许的单位为: %s", 
                    unit, standardIngredient.getName(), standardIngredient.getAllowedUnits()));
        }
    }
    
    /**
     * 获取食材的允许单位列表
     * @param standardIngredientId 标准食材ID
     * @return 允许的单位列表
     * @throws IllegalArgumentException 如果标准食材不存在
     */
    public List<String> getAllowedUnits(Long standardIngredientId) {
        StandardIngredient standardIngredient = standardIngredientRepository.findById(standardIngredientId)
                .orElseThrow(() -> new IllegalArgumentException("标准食材不存在: " + standardIngredientId));
        
        return standardIngredient.getAllowedUnits();
    }
}

