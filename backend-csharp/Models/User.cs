namespace SousChefBackend.Models;

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

public class UserPreference
{
    public int Id { get; set; }
    public int UserId { get; set; }

    // [新增] 目标热量 (可空，闭区间)
    // 如果用户不填，就是 null，AI 就不会收到限制
    public int? MinCalories { get; set; }
    public int? MaxCalories { get; set; }

    // 下面是多对多关系，通过中间表实现
    public List<UserAllergy> Allergies { get; set; } = new();
    public List<UserTaboo> Taboos { get; set; } = new();
    public List<UserCuisinePref> CuisinePrefs { get; set; } = new();
    public List<UserTastePref> TastePrefs { get; set; } = new();
}

// 关联表 1: 用户过敏 -> 指向标准食材
public class UserAllergy 
{
    public int Id { get; set; }
    public int UserPreferenceId { get; set; }
    
    // 复用 StandardIngredient
    public int StandardIngredientId { get; set; }
    public StandardIngredient StandardIngredient { get; set; }
}

// 关联表 2: 用户禁忌 -> 指向标准食材 (逻辑同上，但语义不同)
public class UserTaboo 
{
    public int Id { get; set; }
    public int UserPreferenceId { get; set; }
    public int StandardIngredientId { get; set; }
    public StandardIngredient StandardIngredient { get; set; }
}

// 关联表 3: 菜系偏好
public class UserCuisinePref
{
    public int Id { get; set; }
    public int UserPreferenceId { get; set; }
    public int StandardCuisineId { get; set; }
    public StandardCuisine StandardCuisine { get; set; }
}

// 关联表 4: 口味偏好
public class UserTastePref
{
    public int Id { get; set; }
    public int UserPreferenceId { get; set; }
    public int StandardTasteId { get; set; }
    public StandardTaste StandardTaste { get; set; }
}