namespace SousChefBackend.DTOs.Auth;

public class LoginRequest
{
    public string Identifier { get; set; } = string.Empty; // Username or Email
    public string Password { get; set; } = string.Empty;
}

