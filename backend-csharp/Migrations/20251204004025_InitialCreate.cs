using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace SousChefBackend.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AiGenerationSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    KitchenId = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Servings = table.Column<int>(type: "integer", nullable: false),
                    TargetMinCalories = table.Column<int>(type: "integer", nullable: true),
                    TargetMaxCalories = table.Column<int>(type: "integer", nullable: true),
                    DishCount = table.Column<int>(type: "integer", nullable: false),
                    MaxCookingTimeMin = table.Column<int>(type: "integer", nullable: true),
                    DifficultyTarget = table.Column<string>(type: "text", nullable: false),
                    InventorySnapshotJson = table.Column<string>(type: "text", nullable: false),
                    PreferencesSnapshotJson = table.Column<string>(type: "text", nullable: false),
                    CookersSnapshotJson = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AiGenerationSessions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "GeneratedRecipes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Title = table.Column<string>(type: "text", nullable: false),
                    ShortDescription = table.Column<string>(type: "text", nullable: false),
                    Servings = table.Column<int>(type: "integer", nullable: false),
                    CookingTimeMin = table.Column<int>(type: "integer", nullable: false),
                    Difficulty = table.Column<string>(type: "text", nullable: false),
                    TotalCaloriesEstimate = table.Column<double>(type: "double precision", nullable: false),
                    UsedCookwaresJson = table.Column<string>(type: "text", nullable: false),
                    StepsJson = table.Column<string>(type: "text", nullable: false),
                    IngredientsJson = table.Column<string>(type: "text", nullable: false),
                    GeneratedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GeneratedRecipes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "StandardCookwares",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    AiCode = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StandardCookwares", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "StandardIngredients",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    Category = table.Column<string>(type: "text", nullable: false),
                    BaseUnit = table.Column<string>(type: "text", nullable: false),
                    ImageUrl = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StandardIngredients", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "StandardSeasonings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    AiCode = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StandardSeasonings", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "users",
                columns: table => new
                {
                    user_id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    username = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    email = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    password_hash = table.Column<string>(type: "text", nullable: false),
                    age = table.Column<int>(type: "integer", nullable: true),
                    gender = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    height = table.Column<int>(type: "integer", nullable: true),
                    weight = table.Column<int>(type: "integer", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_users", x => x.user_id);
                });

            migrationBuilder.CreateTable(
                name: "GeneratedRecipeOptions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    AiGenerationSessionId = table.Column<int>(type: "integer", nullable: false),
                    MenuId = table.Column<int>(type: "integer", nullable: false),
                    Title = table.Column<string>(type: "text", nullable: false),
                    Description = table.Column<string>(type: "text", nullable: false),
                    TotalCalories = table.Column<double>(type: "double precision", nullable: false),
                    CookingTime = table.Column<int>(type: "integer", nullable: false),
                    Difficulty = table.Column<string>(type: "text", nullable: false),
                    IngredientsJson = table.Column<string>(type: "text", nullable: false),
                    StepsJson = table.Column<string>(type: "text", nullable: false),
                    Servings = table.Column<int>(type: "integer", nullable: false),
                    UsedCookwaresJson = table.Column<string>(type: "text", nullable: false),
                    IsSelected = table.Column<bool>(type: "boolean", nullable: false),
                    IsSaved = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GeneratedRecipeOptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GeneratedRecipeOptions_AiGenerationSessions_AiGenerationSes~",
                        column: x => x.AiGenerationSessionId,
                        principalTable: "AiGenerationSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Kitchens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Kitchens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Kitchens_users_UserId",
                        column: x => x.UserId,
                        principalTable: "users",
                        principalColumn: "user_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_allergies",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    user_id = table.Column<long>(type: "bigint", nullable: false),
                    allergy = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_allergies", x => x.id);
                    table.ForeignKey(
                        name: "FK_user_allergies_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "user_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_preferences",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    user_id = table.Column<long>(type: "bigint", nullable: false),
                    preference_type = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    preference_value = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_preferences", x => x.id);
                    table.ForeignKey(
                        name: "FK_user_preferences_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "user_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "user_taboos",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    user_id = table.Column<long>(type: "bigint", nullable: false),
                    taboo = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_user_taboos", x => x.id);
                    table.ForeignKey(
                        name: "FK_user_taboos_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "user_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "InventoryItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    KitchenId = table.Column<int>(type: "integer", nullable: false),
                    StandardIngredientId = table.Column<int>(type: "integer", nullable: false),
                    Quantity = table.Column<double>(type: "double precision", nullable: false),
                    Unit = table.Column<string>(type: "text", nullable: false),
                    ExpiryDate = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InventoryItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_InventoryItems_Kitchens_KitchenId",
                        column: x => x.KitchenId,
                        principalTable: "Kitchens",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_InventoryItems_StandardIngredients_StandardIngredientId",
                        column: x => x.StandardIngredientId,
                        principalTable: "StandardIngredients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MyCookwares",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    KitchenId = table.Column<int>(type: "integer", nullable: false),
                    StandardCookwareId = table.Column<int>(type: "integer", nullable: false),
                    IsAvailable = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MyCookwares", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MyCookwares_Kitchens_KitchenId",
                        column: x => x.KitchenId,
                        principalTable: "Kitchens",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MyCookwares_StandardCookwares_StandardCookwareId",
                        column: x => x.StandardCookwareId,
                        principalTable: "StandardCookwares",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MySeasonings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    KitchenId = table.Column<int>(type: "integer", nullable: false),
                    StandardSeasoningId = table.Column<int>(type: "integer", nullable: false),
                    IsAvailable = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MySeasonings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MySeasonings_Kitchens_KitchenId",
                        column: x => x.KitchenId,
                        principalTable: "Kitchens",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MySeasonings_StandardSeasonings_StandardSeasoningId",
                        column: x => x.StandardSeasoningId,
                        principalTable: "StandardSeasonings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "StandardCookwares",
                columns: new[] { "Id", "AiCode", "Name" },
                values: new object[,]
                {
                    { 1, "stove", "Stove Top" },
                    { 2, "oven", "Oven" },
                    { 3, "microwave", "Microwave" },
                    { 4, "air_fryer", "Air Fryer" },
                    { 5, "rice_cooker", "Rice Cooker" },
                    { 6, "pressure_cooker", "Pressure Cooker" },
                    { 7, "blender", "Blender" }
                });

            migrationBuilder.InsertData(
                table: "StandardIngredients",
                columns: new[] { "Id", "BaseUnit", "Category", "ImageUrl", "Name" },
                values: new object[,]
                {
                    { 1, "g", "Meat", "", "Beef Steak" },
                    { 2, "g", "Meat", "", "Chicken Breast" },
                    { 3, "g", "Meat", "", "Pork Belly" },
                    { 4, "piece", "Dairy", "", "Egg" },
                    { 5, "g", "Vegetable", "", "Tomato" },
                    { 6, "g", "Vegetable", "", "Potato" },
                    { 7, "g", "Vegetable", "", "Onion" },
                    { 8, "g", "Grains", "", "Rice" },
                    { 9, "g", "Nuts", "", "Peanut" },
                    { 10, "g", "Vegetable", "", "Carrot" },
                    { 11, "ml", "Dairy", "", "Milk" },
                    { 12, "g", "Dairy", "", "Cheese" }
                });

            migrationBuilder.InsertData(
                table: "StandardSeasonings",
                columns: new[] { "Id", "AiCode", "Name" },
                values: new object[,]
                {
                    { 1, "salt", "Salt" },
                    { 2, "sugar", "Sugar" },
                    { 3, "soy_sauce", "Soy Sauce" },
                    { 4, "black_pepper", "Black Pepper" },
                    { 5, "oil", "Olive Oil" },
                    { 6, "vinegar", "Vinegar" },
                    { 7, "chili_powder", "Chili Powder" },
                    { 8, "garlic_powder", "Garlic Powder" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_GeneratedRecipeOptions_AiGenerationSessionId",
                table: "GeneratedRecipeOptions",
                column: "AiGenerationSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_InventoryItems_KitchenId",
                table: "InventoryItems",
                column: "KitchenId");

            migrationBuilder.CreateIndex(
                name: "IX_InventoryItems_StandardIngredientId",
                table: "InventoryItems",
                column: "StandardIngredientId");

            migrationBuilder.CreateIndex(
                name: "IX_Kitchens_UserId",
                table: "Kitchens",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MyCookwares_KitchenId",
                table: "MyCookwares",
                column: "KitchenId");

            migrationBuilder.CreateIndex(
                name: "IX_MyCookwares_StandardCookwareId",
                table: "MyCookwares",
                column: "StandardCookwareId");

            migrationBuilder.CreateIndex(
                name: "IX_MySeasonings_KitchenId",
                table: "MySeasonings",
                column: "KitchenId");

            migrationBuilder.CreateIndex(
                name: "IX_MySeasonings_StandardSeasoningId",
                table: "MySeasonings",
                column: "StandardSeasoningId");

            migrationBuilder.CreateIndex(
                name: "IX_StandardIngredients_Name",
                table: "StandardIngredients",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_user_allergies_user_id",
                table: "user_allergies",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_user_preferences_user_id",
                table: "user_preferences",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_user_taboos_user_id",
                table: "user_taboos",
                column: "user_id");

            migrationBuilder.CreateIndex(
                name: "IX_users_email",
                table: "users",
                column: "email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_users_username",
                table: "users",
                column: "username",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "GeneratedRecipeOptions");

            migrationBuilder.DropTable(
                name: "GeneratedRecipes");

            migrationBuilder.DropTable(
                name: "InventoryItems");

            migrationBuilder.DropTable(
                name: "MyCookwares");

            migrationBuilder.DropTable(
                name: "MySeasonings");

            migrationBuilder.DropTable(
                name: "user_allergies");

            migrationBuilder.DropTable(
                name: "user_preferences");

            migrationBuilder.DropTable(
                name: "user_taboos");

            migrationBuilder.DropTable(
                name: "AiGenerationSessions");

            migrationBuilder.DropTable(
                name: "StandardIngredients");

            migrationBuilder.DropTable(
                name: "StandardCookwares");

            migrationBuilder.DropTable(
                name: "Kitchens");

            migrationBuilder.DropTable(
                name: "StandardSeasonings");

            migrationBuilder.DropTable(
                name: "users");
        }
    }
}
