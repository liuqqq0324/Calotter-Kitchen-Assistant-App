namespace SousChefBackend.Models;

// 标准食材库 (只读字典)
public class StandardIngredient
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // 英文名: Beef
    public string Category { get; set; } = string.Empty; // Meat
    public string BaseUnit { get; set; } = "g"; // g, ml, piece
    public string ImageUrl { get; set; } = string.Empty;
}

// 标准炊具库
public class StandardCookware
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // Frying Pan
    public string AiCode { get; set; } = string.Empty; // 发给 AI 用的代码: stove
}

// 标准调料库
public class StandardSeasoning
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // Salt
    public string AiCode { get; set; } = string.Empty; // salt
}

// [新增] 标准菜系库
public class StandardCuisine
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // e.g., Chinese, Italian
    public string AiCode { get; set; } = string.Empty; // e.g., chinese, italian (对应 Python enum)
}

// [新增] 标准口味库
public class StandardTaste
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // e.g., Spicy, Sweet
    public string AiCode { get; set; } = string.Empty; // e.g., spicy, sweet
}