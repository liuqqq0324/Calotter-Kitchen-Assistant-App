namespace SousChefBackend.DTOs.User;

public class UserTaboosResponse
{
    public long UserId { get; set; }
    public List<string> Taboos { get; set; } = new();
}

