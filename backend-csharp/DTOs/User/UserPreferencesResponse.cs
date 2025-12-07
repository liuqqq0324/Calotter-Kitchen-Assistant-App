namespace SousChefBackend.DTOs.User;

public class UserPreferencesResponse
{
    public long UserId { get; set; }
    public UserPreferences Preferences { get; set; } = new();
}

public class UserPreferences
{
    public string? DietaryType { get; set; }
    public List<string> CuisineTypes { get; set; } = new();
    public string? SpiceLevel { get; set; }
    public string? CookingTimePreference { get; set; }
}

