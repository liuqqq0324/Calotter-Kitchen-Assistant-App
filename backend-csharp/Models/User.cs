using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SousChefBackend.Models;

[Table("users")]
public class User
{
    [Key]
    [Column("user_id")]
    public long UserId { get; set; }

    [Required]
    [MaxLength(100)]
    [Column("username")]
    public string Username { get; set; } = string.Empty;

    [Required]
    [MaxLength(255)]
    [Column("email")]
    public string Email { get; set; } = string.Empty;

    [Required]
    [Column("password_hash")]
    public string PasswordHash { get; set; } = string.Empty;

    [Column("age")] public int? Age { get; set; }
    [MaxLength(20)] [Column("gender")] public string? Gender { get; set; }
    [Column("height")] public int? Height { get; set; }
    [Column("weight")] public int? Weight { get; set; }

    [Column("created_at")] public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    [Column("updated_at")] public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // 朋友定义的偏好关系
    public virtual ICollection<UserPreference> Preferences { get; set; } = new List<UserPreference>();
    public virtual ICollection<UserTaboo> Taboos { get; set; } = new List<UserTaboo>();
    public virtual ICollection<UserAllergy> Allergies { get; set; } = new List<UserAllergy>();

    // 🔥 [我们植入的核心] 厨房关联 (一对一)
    public virtual Kitchen? Kitchen { get; set; }
}

// ... (保留下面的 UserPreference, UserTaboo, UserAllergy 类定义，保持不变) ...
// 为了篇幅我不重复粘贴 UserPreference 等类，请保留你文件里原有的

[Table("user_preferences")]
public class UserPreference
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    [Required]
    [Column("user_id")]
    public long UserId { get; set; }

    [Required]
    [MaxLength(100)]
    [Column("preference_type")]
    public string PreferenceType { get; set; } = string.Empty; // "dietaryType", "cuisineTypes", "spiceLevel", "cookingTimePreference"

    [Required]
    [MaxLength(255)]
    [Column("preference_value")]
    public string PreferenceValue { get; set; } = string.Empty;

    [ForeignKey("UserId")]
    public virtual User User { get; set; } = null!;
}

[Table("user_taboos")]
public class UserTaboo
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    [Required]
    [Column("user_id")]
    public long UserId { get; set; }

    [Required]
    [MaxLength(100)]
    [Column("taboo")]
    public string Taboo { get; set; } = string.Empty;

    [ForeignKey("UserId")]
    public virtual User User { get; set; } = null!;
}

[Table("user_allergies")]
public class UserAllergy
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    [Required]
    [Column("user_id")]
    public long UserId { get; set; }

    [Required]
    [MaxLength(100)]
    [Column("allergy")]
    public string Allergy { get; set; } = string.Empty;

    [ForeignKey("UserId")]
    public virtual User User { get; set; } = null!;
}