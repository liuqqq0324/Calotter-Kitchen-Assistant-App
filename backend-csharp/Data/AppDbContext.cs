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

    protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);

    // =========================================================
    // 1. 索引配置 (保证名字不重复)
    // =========================================================
    modelBuilder.Entity<StandardIngredient>().HasIndex(s => s.Name).IsUnique();
    modelBuilder.Entity<StandardCuisine>().HasIndex(s => s.Name).IsUnique();
    modelBuilder.Entity<StandardTaste>().HasIndex(s => s.Name).IsUnique();

    // =========================================================
    // 2. 填充数据 (Seeding)
    // =========================================================

    // A. 标准食材库 (简单搞几个测试用)
    modelBuilder.Entity<StandardIngredient>().HasData(
        new StandardIngredient { Id = 1, Name = "Beef Steak", Category = "Meat", BaseUnit = "g" },
        new StandardIngredient { Id = 2, Name = "Chicken Breast", Category = "Meat", BaseUnit = "g" },
        new StandardIngredient { Id = 3, Name = "Pork Belly", Category = "Meat", BaseUnit = "g" },
        new StandardIngredient { Id = 4, Name = "Egg", Category = "Dairy", BaseUnit = "piece" },
        new StandardIngredient { Id = 5, Name = "Tomato", Category = "Vegetable", BaseUnit = "g" },
        new StandardIngredient { Id = 6, Name = "Potato", Category = "Vegetable", BaseUnit = "g" },
        new StandardIngredient { Id = 7, Name = "Onion", Category = "Vegetable", BaseUnit = "g" },
        new StandardIngredient { Id = 8, Name = "Rice", Category = "Grains", BaseUnit = "g" },
        new StandardIngredient { Id = 9, Name = "Peanut", Category = "Nuts", BaseUnit = "g" } // 典型的过敏源
    );

    // B. 标准炊具库
    modelBuilder.Entity<StandardCookware>().HasData(
        new StandardCookware { Id = 1, Name = "Stove Top", AiCode = "stove" },
        new StandardCookware { Id = 2, Name = "Oven", AiCode = "oven" },
        new StandardCookware { Id = 3, Name = "Microwave", AiCode = "microwave" },
        new StandardCookware { Id = 4, Name = "Air Fryer", AiCode = "air_fryer" },
        new StandardCookware { Id = 5, Name = "Rice Cooker", AiCode = "rice_cooker" }
    );

    // C. 标准调料库
    modelBuilder.Entity<StandardSeasoning>().HasData(
        new StandardSeasoning { Id = 1, Name = "Salt", AiCode = "salt" },
        new StandardSeasoning { Id = 2, Name = "Sugar", AiCode = "sugar" },
        new StandardSeasoning { Id = 3, Name = "Soy Sauce", AiCode = "soy_sauce" },
        new StandardSeasoning { Id = 4, Name = "Black Pepper", AiCode = "black_pepper" },
        new StandardSeasoning { Id = 5, Name = "Olive Oil", AiCode = "oil" },
        new StandardSeasoning { Id = 6, Name = "Chili Powder", AiCode = "chili_powder" }
    );

    // D. [新增] 标准菜系库 (AI 认识的)
    modelBuilder.Entity<StandardCuisine>().HasData(
        new StandardCuisine { Id = 1, Name = "Chinese", AiCode = "chinese" },
        new StandardCuisine { Id = 2, Name = "Italian", AiCode = "italian" },
        new StandardCuisine { Id = 3, Name = "Japanese", AiCode = "japanese" },
        new StandardCuisine { Id = 4, Name = "Mexican", AiCode = "mexican" },
        new StandardCuisine { Id = 5, Name = "Western", AiCode = "western" }
    );

    // E. [新增] 标准口味库
    modelBuilder.Entity<StandardTaste>().HasData(
        new StandardTaste { Id = 1, Name = "Spicy", AiCode = "spicy" },
        new StandardTaste { Id = 2, Name = "Sweet", AiCode = "sweet" },
        new StandardTaste { Id = 3, Name = "Sour", AiCode = "sour" },
        new StandardTaste { Id = 4, Name = "Salty", AiCode = "salty" },
        new StandardTaste { Id = 5, Name = "Light", AiCode = "light" }
    );
}
}