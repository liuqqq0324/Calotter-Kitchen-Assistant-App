namespace SousChefBackend.DTOs.Auth;

public class LoginResponse
{
    public long UserId { get; set; }
    
    // 🔥 [新增]
    public int KitchenId { get; set; } 
    
    public TokenInfo Token { get; set; } = new();
}

public class TokenInfo
{
    public string AccessToken { get; set; } = string.Empty;
    public int ExpiresIn { get; set; } = 3600; // 默认 1 小时
}