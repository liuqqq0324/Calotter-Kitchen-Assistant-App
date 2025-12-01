// DTOs/AI/RecipeGenerationRequest.cs

public class RecipeGenerationRequest
{
    // 对应 Python: inventory
    public List<AiInventoryItem> Inventory { get; set; } = new();

    // 对应 Python: calorie_target (可选)
    public AiCalorieTarget? CalorieTarget { get; set; }

    // 对应 Python: servings
    public int Servings { get; set; }

    // 对应 Python: diet_preferences
    public AiDietPreferences DietPreferences { get; set; } = new();

    // 对应 Python: generation_settings
    public AiGenerationSettings GenerationSettings { get; set; } = new();

    // 对应 Python: cookers (string 数组)
    public List<string> Cookers { get; set; } = new();
}

// 对应 Python inventory 里的 item
public class AiInventoryItem
{
    public string Name { get; set; } // 英文名，来自 StandardIngredient
    public double AmountValue { get; set; }
    
    // 🔥 重点：Python 只要 "g", "ml", "piece"
    // 你的 C# 逻辑里必须把 "kg" 转成 "1000g"，把 "L" 转成 "1000ml"
    public string AmountUnit { get; set; } 
    
    public string? ExpiresAt { get; set; } // "2025-12-01"
}

public class AiCalorieTarget
{
    public double MinTotalKcal { get; set; }
    public double MaxTotalKcal { get; set; }
}

public class AiDietPreferences
{
    // 对应 cuisine_preferences
    public List<string> CuisinePreferences { get; set; } = new();
    // 对应 taste_preferences
    public List<string> TastePreferences { get; set; } = new();
    // 对应 avoid_ingredients
    public List<string> AvoidIngredients { get; set; } = new();
    // 对应 allergies
    public List<string> Allergies { get; set; } = new();
}

public class AiGenerationSettings
{
    public int DishCount { get; set; }
    public int? MaxCookingTimeMin { get; set; }
    public string DifficultyTarget { get; set; } = "medium"; // easy, medium, hard
}