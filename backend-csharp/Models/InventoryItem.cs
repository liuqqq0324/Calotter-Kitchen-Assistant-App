namespace SousChefBackend.Models;

public class InventoryItem
{
    public int Id { get; set; }
    
    // 归属哪个厨房
    public int KitchenId { get; set; }
    
    // 🔥 严格模式：必须指向标准库
    public int StandardIngredientId { get; set; }
    public StandardIngredient? StandardIngredient { get; set; } // 导航属性

    // 用户只需填数量和过期时间
    public double Quantity { get; set; }
    public string Unit { get; set; } = string.Empty;
    public DateTime ExpiryDate { get; set; }
}