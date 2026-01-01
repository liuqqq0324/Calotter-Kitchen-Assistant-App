package com.calotter.cooking.domain.entity;

import com.calotter.common.core.domain.BaseEntity;
import com.calotter.cooking.service.dto.AiCookingContext;
import com.calotter.cooking.service.dto.AiRecipeResponse;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.ArrayList;
import java.util.List;

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
    @JsonIgnore  // 避免序列化大对象
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private AiCookingContext requestContext;

    // --- 核心：响应快照 (Output) ---
    // 这里存 AI 返回的 AiRecipeResponse
    @JsonIgnore  // 避免序列化大对象
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private AiRecipeResponse aiResponse;

    /**
     * 最终用料快照（JSON 字符串），用于扣库存/健康记录
     */
    @Column(columnDefinition = "text")
    private String ingredientsSnapshotJson;

    /**
     * 最终总营养快照（JSON 字符串）
     */
    @Column(columnDefinition = "text")
    private String totalNutritionSnapshotJson;
    
    // 便捷方法：设置用料快照（自动序列化为 JSON）
    public void setIngredientsSnapshot(Object ingredients) {
        if (ingredients == null) {
            this.ingredientsSnapshotJson = null;
        } else {
            try {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                this.ingredientsSnapshotJson = mapper.writeValueAsString(ingredients);
            } catch (Exception e) {
                this.ingredientsSnapshotJson = null;
            }
        }
    }
    
    // 便捷方法：获取用料快照 JSON 字符串
    public String getIngredientsSnapshot() {
        return this.ingredientsSnapshotJson;
    }
    
    // 便捷方法：设置营养快照（自动序列化为 JSON）
    public void setTotalNutritionSnapshot(Object nutrition) {
        if (nutrition == null) {
            this.totalNutritionSnapshotJson = null;
        } else {
            try {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                this.totalNutritionSnapshotJson = mapper.writeValueAsString(nutrition);
            } catch (Exception e) {
                this.totalNutritionSnapshotJson = null;
            }
        }
    }
    
    // 便捷方法：获取营养快照 JSON 字符串
    public String getTotalNutritionSnapshot() {
        return this.totalNutritionSnapshotJson;
    }

    /**
     * 剩余比例（0~1），初始化 1.0
     */
    private Double remainingRatio;

    // --- 核心：结构化Dish引用 ---
    // 支持多道菜：一个 Session 可以对应一个 Menu（多道菜）
    @JsonIgnore  // 防止 Jackson 序列化懒加载代理
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "cooking_session_dishes",
        joinColumns = @JoinColumn(name = "session_id"),
        inverseJoinColumns = @JoinColumn(name = "dish_id")
    )
    private List<Dish> dishes = new ArrayList<>();
    
    // 记录完成了哪些菜品（逗号分隔的 Dish ID 字符串，如 "1,2,3"）
    @Column(columnDefinition = "text")
    private String completedDishIdsStr;
    
    // 便捷方法：获取完成的菜品 ID 列表
    public List<Long> getCompletedDishIds() {
        if (completedDishIdsStr == null || completedDishIdsStr.isEmpty()) {
            return new ArrayList<>();
        }
        return java.util.Arrays.stream(completedDishIdsStr.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(Long::parseLong)
                .collect(java.util.stream.Collectors.toList());
    }
    
    // 便捷方法：设置完成的菜品 ID 列表
    public void setCompletedDishIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            this.completedDishIdsStr = null;
        } else {
            this.completedDishIdsStr = ids.stream()
                    .map(String::valueOf)
                    .collect(java.util.stream.Collectors.joining(","));
        }
    }
    
    // 保留用于向后兼容：作为主菜标识
    @JsonIgnore  // 防止 Jackson 序列化懒加载代理
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
