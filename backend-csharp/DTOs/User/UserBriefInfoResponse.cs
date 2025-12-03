namespace SousChefBackend.DTOs.User;

public class UserBriefInfoResponse
{
    public long UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public UserProfile? Profile { get; set; }
}

public class UserProfile
{
    public int? Age { get; set; }
    public int? Height { get; set; }
    public int? Weight { get; set; }
}

