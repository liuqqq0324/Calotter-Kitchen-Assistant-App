namespace SousChefBackend.Models;

// 记录每一次向 LLM 发起的请求 (Session)
public class AiGenerationSession
{
    public int Id { get; set; }
    public int KitchenId { get; set; } // 谁发起的
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // ==================
    // Request 快照 (发送给 AI 的参数)
    // ==================
    
    public int Servings { get; set; } // 用餐人数
    
    // 这次请求的特定卡路里限制 (可能覆盖用户的默认设置)
    public int? TargetMinCalories { get; set; } 
    public int? TargetMaxCalories { get; set; }

    // 🔥 关键：库存快照 (JSON)
    // 存: [{"name": "Beef", "qty": 500, "unit": "g"}, ...]
    public string InventorySnapshotJson { get; set; } = string.Empty;

    // 🔥 关键：偏好快照 (JSON)
    // 存: { "cuisines": ["Sichuan"], "tastes": ["Spicy"], "allergies": ["Peanut"] }
    // 为什么不存外键？因为用户这次可能想尝试不一样的口味，覆盖默认设置。
    public string PreferencesSnapshotJson { get; set; } = string.Empty;

    // ==================
    // Response 结果 (AI 返回的 5 个选项)
    // ==================
    public List<GeneratedRecipeOption> GeneratedOptions { get; set; } = new();
}

// AI 返回的 5 个候选菜单中的每一个
public class GeneratedRecipeOption
{
    public int Id { get; set; }
    
    // 归属于哪次请求
    public int AiGenerationSessionId { get; set; } 

    // 菜单的基本信息
    public int MenuId { get; set; } // 1-5
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public double TotalCalories { get; set; }
    public int CookingTime { get; set; }
    public string Difficulty { get; set; } = string.Empty;

    // 详情 (JSONB)
    public string IngredientsJson { get; set; } 
    public string StepsJson { get; set; }

    // 用户操作状态
    public bool IsSelected { get; set; } = false; // 用户是否最终选择了这一道去做
    public bool IsSaved { get; set; } = false;    // 用户是否收藏了这一道
}