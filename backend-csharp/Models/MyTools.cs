using System.ComponentModel.DataAnnotations.Schema;

namespace SousChefBackend.Models;

// 用户的炊具 (开关)
public class MyCookware
{
    public int Id { get; set; }
    public int KitchenId { get; set; }

    // 关联标准炊具
    public int StandardCookwareId { get; set; }
    public StandardCookware? StandardCookware { get; set; }

    public bool IsAvailable { get; set; } // true/false
}

// 用户的调料 (开关)
public class MySeasoning
{
    public int Id { get; set; }
    public int KitchenId { get; set; }

    // 关联标准调料
    public int StandardSeasoningId { get; set; }
    public StandardSeasoning? StandardSeasoning { get; set; }

    public bool IsAvailable { get; set; } // true/false
}