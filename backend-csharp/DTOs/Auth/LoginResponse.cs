namespace SousChefBackend.DTOs.Auth;

public class LoginResponse
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int KitchenId { get; set; } // 🔥 重点：告诉前端这个用户的厨房ID是啥
    public string Token { get; set; } = "mock-token"; // 先给个假令牌占位
}