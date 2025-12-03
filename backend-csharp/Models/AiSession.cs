namespace SousChefBackend.Models;

public class AiGenerationSession
{
    public int Id { get; set; }
    public int KitchenId { get; set; } 
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // ==================
    // Request 快照 - 基础信息
    // ==================
    public int Servings { get; set; } // 用餐人数
    public int? TargetMinCalories { get; set; } 
    public int? TargetMaxCalories { get; set; }

    // ==================
    // Request 快照 - 生成设置 (补全这里!)
    // ==================
    // 对应 generation_settings.dish_count
    public int DishCount { get; set; } = 1; 

    // 对应 generation_settings.max_cooking_time_min
    public int? MaxCookingTimeMin { get; set; } 

    // 对应 generation_settings.difficulty_target (easy, medium, hard)
    public string DifficultyTarget { get; set; } = "medium";

    // ==================
    // Request 快照 - 复杂对象 (JSON)
    // ==================
    
    // 对应 inventory
    public string InventorySnapshotJson { get; set; } = string.Empty;

    // 对应 diet_preferences (Cuisine, Taste, Allergy, Taboo)
    public string PreferencesSnapshotJson { get; set; } = string.Empty;

    // 🔥 [新增] 对应 cookers
    // 存: ["stove", "oven", "air_fryer"]
    public string CookersSnapshotJson { get; set; } = "[]"; 

    // ==================
    // Response 结果
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

    // 🔥 [新增] AI 实际生成的份量 (可能跟请求的不一样)
    public int Servings { get; set; } 

    // 🔥 [新增] 这道菜实际用到的炊具
    public string UsedCookwaresJson { get; set; } = "[]";

    // 用户操作状态
    public bool IsSelected { get; set; } = false; // 用户是否最终选择了这一道去做
    public bool IsSaved { get; set; } = false;    // 用户是否收藏了这一道
}