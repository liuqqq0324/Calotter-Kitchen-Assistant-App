package com.calotter.health.domain.enums;

/**
 * 营养日志来源类型枚举
 */
public enum LogSourceType {
    APP_COOKING,  // 来自本App的烹饪会话
    LEFTOVER,     // 来自冰箱剩菜
    MANUAL,       // 用户手动输入
    EXTERNAL      // 扫码或其他来源
}

