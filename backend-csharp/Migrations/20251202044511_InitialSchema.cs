using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace SousChefBackend.Migrations
{
    /// <inheritdoc />
    public partial class InitialSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Kitchens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Kitchens", x => x.Id);
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
                name: "StandardCuisine",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    AiCode = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StandardCuisine", x => x.Id);
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
                name: "StandardTaste",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "text", nullable: false),
                    AiCode = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StandardTaste", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "UserPreferences",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    MinCalories = table.Column<int>(type: "integer", nullable: true),
                    MaxCalories = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserPreferences", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Username = table.Column<string>(type: "text", nullable: false),
                    Email = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
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

            migrationBuilder.CreateTable(
                name: "UserAllergy",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserPreferenceId = table.Column<int>(type: "integer", nullable: false),
                    StandardIngredientId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserAllergy", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserAllergy_StandardIngredients_StandardIngredientId",
                        column: x => x.StandardIngredientId,
                        principalTable: "StandardIngredients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserAllergy_UserPreferences_UserPreferenceId",
                        column: x => x.UserPreferenceId,
                        principalTable: "UserPreferences",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserCuisinePref",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserPreferenceId = table.Column<int>(type: "integer", nullable: false),
                    StandardCuisineId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserCuisinePref", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserCuisinePref_StandardCuisine_StandardCuisineId",
                        column: x => x.StandardCuisineId,
                        principalTable: "StandardCuisine",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserCuisinePref_UserPreferences_UserPreferenceId",
                        column: x => x.UserPreferenceId,
                        principalTable: "UserPreferences",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserTaboo",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserPreferenceId = table.Column<int>(type: "integer", nullable: false),
                    StandardIngredientId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserTaboo", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserTaboo_StandardIngredients_StandardIngredientId",
                        column: x => x.StandardIngredientId,
                        principalTable: "StandardIngredients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserTaboo_UserPreferences_UserPreferenceId",
                        column: x => x.UserPreferenceId,
                        principalTable: "UserPreferences",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserTastePref",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserPreferenceId = table.Column<int>(type: "integer", nullable: false),
                    StandardTasteId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserTastePref", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserTastePref_StandardTaste_StandardTasteId",
                        column: x => x.StandardTasteId,
                        principalTable: "StandardTaste",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserTastePref_UserPreferences_UserPreferenceId",
                        column: x => x.UserPreferenceId,
                        principalTable: "UserPreferences",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_InventoryItems_KitchenId",
                table: "InventoryItems",
                column: "KitchenId");

            migrationBuilder.CreateIndex(
                name: "IX_InventoryItems_StandardIngredientId",
                table: "InventoryItems",
                column: "StandardIngredientId");

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
                name: "IX_UserAllergy_StandardIngredientId",
                table: "UserAllergy",
                column: "StandardIngredientId");

            migrationBuilder.CreateIndex(
                name: "IX_UserAllergy_UserPreferenceId",
                table: "UserAllergy",
                column: "UserPreferenceId");

            migrationBuilder.CreateIndex(
                name: "IX_UserCuisinePref_StandardCuisineId",
                table: "UserCuisinePref",
                column: "StandardCuisineId");

            migrationBuilder.CreateIndex(
                name: "IX_UserCuisinePref_UserPreferenceId",
                table: "UserCuisinePref",
                column: "UserPreferenceId");

            migrationBuilder.CreateIndex(
                name: "IX_UserTaboo_StandardIngredientId",
                table: "UserTaboo",
                column: "StandardIngredientId");

            migrationBuilder.CreateIndex(
                name: "IX_UserTaboo_UserPreferenceId",
                table: "UserTaboo",
                column: "UserPreferenceId");

            migrationBuilder.CreateIndex(
                name: "IX_UserTastePref_StandardTasteId",
                table: "UserTastePref",
                column: "StandardTasteId");

            migrationBuilder.CreateIndex(
                name: "IX_UserTastePref_UserPreferenceId",
                table: "UserTastePref",
                column: "UserPreferenceId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "InventoryItems");

            migrationBuilder.DropTable(
                name: "MyCookwares");

            migrationBuilder.DropTable(
                name: "MySeasonings");

            migrationBuilder.DropTable(
                name: "UserAllergy");

            migrationBuilder.DropTable(
                name: "UserCuisinePref");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "UserTaboo");

            migrationBuilder.DropTable(
                name: "UserTastePref");

            migrationBuilder.DropTable(
                name: "StandardCookwares");

            migrationBuilder.DropTable(
                name: "Kitchens");

            migrationBuilder.DropTable(
                name: "StandardSeasonings");

            migrationBuilder.DropTable(
                name: "StandardCuisine");

            migrationBuilder.DropTable(
                name: "StandardIngredients");

            migrationBuilder.DropTable(
                name: "StandardTaste");

            migrationBuilder.DropTable(
                name: "UserPreferences");
        }
    }
}
