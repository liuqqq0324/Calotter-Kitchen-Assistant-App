namespace SousChefBackend.DTOs.Auth;

public class LoginResponse
{
    public long UserId { get; set; }
    public TokenInfo Token { get; set; } = new();
}

public class TokenInfo
{
    public string AccessToken { get; set; } = string.Empty;
    public int ExpiresIn { get; set; } = 3000; // seconds
}

