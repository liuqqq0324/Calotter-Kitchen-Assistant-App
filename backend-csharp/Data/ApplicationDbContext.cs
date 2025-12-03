using Microsoft.EntityFrameworkCore;
using SousChefBackend.Models;

namespace SousChefBackend.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<UserPreference> UserPreferences { get; set; }
    public DbSet<UserTaboo> UserTaboos { get; set; }
    public DbSet<UserAllergy> UserAllergies { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Email).IsUnique();
        });

        // UserPreference configuration
        modelBuilder.Entity<UserPreference>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.PreferenceType, e.PreferenceValue }).IsUnique();
        });

        // UserTaboo configuration
        modelBuilder.Entity<UserTaboo>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Taboo }).IsUnique();
        });

        // UserAllergy configuration
        modelBuilder.Entity<UserAllergy>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Allergy }).IsUnique();
        });
    }
}

