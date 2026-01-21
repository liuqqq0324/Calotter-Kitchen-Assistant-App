package com.calotter.cooking.domain.enums;

/**
 * 烹饪分类枚举
 * 用于标识菜品的烹饪方式分类
 */
public enum CookingCategory {
    /**
     * 爆炒/煎 (Stir-fry/Pan-fry) - 快速，锅气
     */
    STIR_FRY_PAN_FRY,
    
    /**
     * 蒸/煮 (Steam/Boil) - 健康，清淡
     */
    STEAM_BOIL,
    
    /**
     * 炖/焖 (Braise/Stew) - 耗时，浓郁
     */
    BRAISE_STEW,
    
    /**
     * 凉拌/沙拉 (Cold/Salad) - 前菜，夏天
     */
    COLD_SALAD,
    
    /**
     * 汤羹 (Soup)
     */
    SOUP,
    
    /**
     * 烤箱/空气炸锅 (Roast/Bake) - 懒人
     */
    ROAST_BAKE
}

