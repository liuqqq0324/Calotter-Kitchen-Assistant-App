using Microsoft.EntityFrameworkCore;
using SousChefBackend.Models; // 👈 确保这里引用了你放 Model 的文件夹

namespace SousChefBackend.Data; // 👈 这里的命名空间名字要和你的项目一致

// 继承 DbContext，这是 EF Core 的核心基类
public class AppDbContext : DbContext
{
    // 构造函数：接收配置（比如连接字符串）传给父类
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    // =========================================================
    // 这里把你的 Model 变成数据库里的表 (DbSet)
    // =========================================================

    // 1. 厨房核心
    public DbSet<Kitchen> Kitchens { get; set; }
    
    // 2. 三大物资 (你的新 Model)
    public DbSet<InventoryItem> InventoryItems { get; set; }
    public DbSet<MyCookware> MyCookwares { get; set; }
    public DbSet<MySeasoning> MySeasonings { get; set; } // 记得我们新建的调料表

    // 3. 标准库 (AI 用的字典)
    public DbSet<StandardIngredient> StandardIngredients { get; set; }
    public DbSet<StandardCookware> StandardCookwares { get; set; }
    public DbSet<StandardSeasoning> StandardSeasonings { get; set; }

    // [新增] 标准库补充
    public DbSet<StandardCuisine> StandardCuisines { get; set; }
    public DbSet<StandardTaste> StandardTastes { get; set; }

    // [新增] 用户偏好关联
    public DbSet<UserAllergy> UserAllergies { get; set; }
    public DbSet<UserTaboo> UserTaboos { get; set; }
    public DbSet<UserCuisinePref> UserCuisinePrefs { get; set; }
    public DbSet<UserTastePref> UserTastePrefs { get; set; }

    // [新增] AI 会话记录
    public DbSet<AiGenerationSession> AiGenerationSessions { get; set; }
    public DbSet<GeneratedRecipeOption> GeneratedRecipeOptions { get; set; }

    // 4. 用户相关 (简化版)
    public DbSet<User> Users { get; set; }
    public DbSet<UserPreference> UserPreferences { get; set; }
}