package com.calotter.user.service.ai;

import com.calotter.user.domain.entity.HealthGoal;

import java.math.BigDecimal;

/**
 * AI 营养建议服务接口
 * 根据用户身体信息和健康目标，生成个性化的营养建议
 */
public interface AiNutritionRecommendationService {
    
    /**
     * 获取营养建议
     * 
     * @param height 身高（厘米）
     * @param weight 体重（千克）
     * @param age 年龄
     * @param gender 性别（1=男, 2=女）
     * @param bmi BMI值
     * @param goalType 目标类型
     * @param activityLevel 活动水平
     * @return 营养建议
     */
    NutritionRecommendation getNutritionRecommendation(
            Integer height,
            BigDecimal weight,
            Integer age,
            Integer gender,
            BigDecimal bmi,
            HealthGoal.GoalType goalType,
            Double activityLevel
    );
    
    /**
     * 营养建议数据
     */
    class NutritionRecommendation {
        private Integer dailyCalories;
        private Integer protein;
        private Integer fat;
        private Integer carb;
        private Integer fiber;
        
        public Integer getDailyCalories() {
            return dailyCalories;
        }
        
        public void setDailyCalories(Integer dailyCalories) {
            this.dailyCalories = dailyCalories;
        }
        
        public Integer getProtein() {
            return protein;
        }
        
        public void setProtein(Integer protein) {
            this.protein = protein;
        }
        
        public Integer getFat() {
            return fat;
        }
        
        public void setFat(Integer fat) {
            this.fat = fat;
        }
        
        public Integer getCarb() {
            return carb;
        }
        
        public void setCarb(Integer carb) {
            this.carb = carb;
        }
        
        public Integer getFiber() {
            return fiber;
        }
        
        public void setFiber(Integer fiber) {
            this.fiber = fiber;
        }
    }
}

