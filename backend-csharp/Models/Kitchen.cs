namespace SousChefBackend.Models;

public class Kitchen
{
    public int Id { get; set; }
    
    // 简单起见，先假设 User 是 1。后期再做登录关联。
    public int UserId { get; set; } 

    // 三大金刚：库存、炊具、调料
    // List = new(); 这种写法是为了防止空指针报错
    public List<InventoryItem> InventoryItems { get; set; } = new();
    public List<MyCookware> MyCookwares { get; set; } = new();
    public List<MySeasoning> MySeasonings { get; set; } = new();
}