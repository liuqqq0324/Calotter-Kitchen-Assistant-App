package com.calotter.cooking.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.cooking.service.dto.AiCookingContext;
import com.calotter.cooking.service.dto.AiRecipeResponse;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * 烹饪会话记录表
 * 用于记录：谁在什么时候请求了什么，AI 生成了什么，以及用户最终选了没。
 */
@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "cooking_sessions")
public class CookingSession extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long householdId;

    @Column(nullable = false)
    private Long initiatorId; // 发起请求的用户 ID

    // --- 核心：请求快照 (Input) ---
    // 这里直接存 AiCookingContext 的 JSON
    // 优点：以后排查 Bug，直接复制这个 JSON 丢给 AI 就能复现
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private AiCookingContext requestContext;

    // --- 核心：响应快照 (Output) ---
    // 这里存 AI 返回的 AiRecipeResponse
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private AiRecipeResponse aiResponse;

    /**
     * 最终用料快照（JSON），用于扣库存/健康记录
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Object ingredientsSnapshot;

    /**
     * 最终总营养快照
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Object totalNutritionSnapshot;

    /**
     * 剩余比例（0~1），初始化 1.0
     */
    private Double remainingRatio;

    // --- 核心：结构化Dish引用 ---
    // 当AI生成配方后，创建Dish快照，这里引用结构化数据（便于查询和关联）
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "final_dish_id")
    private Dish finalDish;

    // --- 状态管理 ---
    // PENDING (生成中), COMPLETED (生成完毕), ACCEPTED (用户决定做这就吃), REJECTED (用户重新生成了)
    @Enumerated(EnumType.STRING)
    private SessionStatus status;

    // 记录用户最终选了哪道菜 (如果做完了)
    // 注意：可以保留用于快速查询，或从 finalDish.name 获取
    private String selectedDishName;

    public enum SessionStatus {
        PENDING, COMPLETED, COOKED, CANCELLED
    }
}
