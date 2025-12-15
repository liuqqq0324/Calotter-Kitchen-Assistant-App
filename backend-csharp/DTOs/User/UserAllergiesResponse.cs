namespace SousChefBackend.DTOs.User;

public class UserAllergiesResponse
{
    public long UserId { get; set; }
    public List<string> Allergies { get; set; } = new();
}

