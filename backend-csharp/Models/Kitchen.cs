using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SousChefBackend.Models;

public class Kitchen
{
    public int Id { get; set; } // 厨房ID还是用 int 没问题
    
    // 🔥 适配 User 表的主键类型 (long)
    public long UserId { get; set; } 
    public User? User { get; set; }

    // 三大金刚
    public List<InventoryItem> InventoryItems { get; set; } = new();
    public List<MyCookware> MyCookwares { get; set; } = new();
    public List<MySeasoning> MySeasonings { get; set; } = new();
}