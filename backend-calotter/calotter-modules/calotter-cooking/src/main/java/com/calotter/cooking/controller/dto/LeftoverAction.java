package com.calotter.cooking.controller.dto;

/**
 * 剩菜处理动作枚举
 * 用于CookingCompletionRequest DTO
 */
public enum LeftoverAction {
    DISCARD,        // 丢弃/吃光了
    SAVE_TO_FRIDGE  // 存入冰箱
}

