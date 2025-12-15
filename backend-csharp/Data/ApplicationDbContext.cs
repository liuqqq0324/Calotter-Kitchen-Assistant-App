using Microsoft.EntityFrameworkCore;
using SousChefBackend.Models;

namespace SousChefBackend.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    // 1. 用户系统
    public DbSet<User> Users { get; set; }
    public DbSet<UserPreference> UserPreferences { get; set; }
    public DbSet<UserTaboo> UserTaboos { get; set; }
    public DbSet<UserAllergy> UserAllergies { get; set; }

    // 2. 厨房系统
    public DbSet<Kitchen> Kitchens { get; set; }
    public DbSet<InventoryItem> InventoryItems { get; set; }
    public DbSet<MyCookware> MyCookwares { get; set; }
    public DbSet<MySeasoning> MySeasonings { get; set; }

    // 3. 标准库 & AI
    public DbSet<StandardIngredient> StandardIngredients { get; set; }
    public DbSet<StandardCookware> StandardCookwares { get; set; }
    public DbSet<StandardSeasoning> StandardSeasonings { get; set; }
    
    public DbSet<AiGenerationSession> AiGenerationSessions { get; set; }
    public DbSet<GeneratedRecipeOption> GeneratedRecipeOptions { get; set; }
    public DbSet<GeneratedRecipe> GeneratedRecipes { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // --- 用户索引 ---
        modelBuilder.Entity<User>(entity => {
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // --- 关系配置: User <-> Kitchen ---
        modelBuilder.Entity<User>()
            .HasOne(u => u.Kitchen)
            .WithOne(k => k.User)
            .HasForeignKey<Kitchen>(k => k.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // --- 标准库索引 ---
        modelBuilder.Entity<StandardIngredient>().HasIndex(s => s.Name).IsUnique();

        // --- 种子数据 (Seeding) ---
        SeedData(modelBuilder);
    }

    private void SeedData(ModelBuilder modelBuilder)
    {
        // 1. 食材
        modelBuilder.Entity<StandardIngredient>().HasData(
             new StandardIngredient { Id = 1, Name = "Beef Steak", Category = "Meat", BaseUnit = "g" },
             new StandardIngredient { Id = 2, Name = "Chicken Breast", Category = "Meat", BaseUnit = "g" },
             new StandardIngredient { Id = 3, Name = "Pork Belly", Category = "Meat", BaseUnit = "g" },
             new StandardIngredient { Id = 4, Name = "Egg", Category = "Dairy", BaseUnit = "piece" },
             new StandardIngredient { Id = 5, Name = "Tomato", Category = "Vegetable", BaseUnit = "g" },
             new StandardIngredient { Id = 6, Name = "Potato", Category = "Vegetable", BaseUnit = "g" },
             new StandardIngredient { Id = 7, Name = "Onion", Category = "Vegetable", BaseUnit = "g" },
             new StandardIngredient { Id = 8, Name = "Rice", Category = "Grains", BaseUnit = "g" },
             new StandardIngredient { Id = 9, Name = "Peanut", Category = "Nuts", BaseUnit = "g" },
             new StandardIngredient { Id = 10, Name = "Carrot", Category = "Vegetable", BaseUnit = "g" },
             new StandardIngredient { Id = 11, Name = "Milk", Category = "Dairy", BaseUnit = "ml" },
             new StandardIngredient { Id = 12, Name = "Cheese", Category = "Dairy", BaseUnit = "g" }
        );

        // 2. 炊具
        modelBuilder.Entity<StandardCookware>().HasData(
            new StandardCookware { Id = 1, Name = "Stove Top", AiCode = "stove" },
            new StandardCookware { Id = 2, Name = "Oven", AiCode = "oven" },
            new StandardCookware { Id = 3, Name = "Microwave", AiCode = "microwave" },
            new StandardCookware { Id = 4, Name = "Air Fryer", AiCode = "air_fryer" },
            new StandardCookware { Id = 5, Name = "Rice Cooker", AiCode = "rice_cooker" },
            new StandardCookware { Id = 6, Name = "Pressure Cooker", AiCode = "pressure_cooker" },
            new StandardCookware { Id = 7, Name = "Blender", AiCode = "blender" }
        );

        // 3. 调料
        modelBuilder.Entity<StandardSeasoning>().HasData(
            new StandardSeasoning { Id = 1, Name = "Salt", AiCode = "salt" },
            new StandardSeasoning { Id = 2, Name = "Sugar", AiCode = "sugar" },
            new StandardSeasoning { Id = 3, Name = "Soy Sauce", AiCode = "soy_sauce" },
            new StandardSeasoning { Id = 4, Name = "Black Pepper", AiCode = "black_pepper" },
            new StandardSeasoning { Id = 5, Name = "Olive Oil", AiCode = "oil" },
            new StandardSeasoning { Id = 6, Name = "Vinegar", AiCode = "vinegar" },
            new StandardSeasoning { Id = 7, Name = "Chili Powder", AiCode = "chili_powder" },
            new StandardSeasoning { Id = 8, Name = "Garlic Powder", AiCode = "garlic_powder" }
        );

    }
}