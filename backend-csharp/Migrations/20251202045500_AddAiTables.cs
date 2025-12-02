using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace SousChefBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddAiTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserAllergy_StandardIngredients_StandardIngredientId",
                table: "UserAllergy");

            migrationBuilder.DropForeignKey(
                name: "FK_UserAllergy_UserPreferences_UserPreferenceId",
                table: "UserAllergy");

            migrationBuilder.DropForeignKey(
                name: "FK_UserCuisinePref_StandardCuisine_StandardCuisineId",
                table: "UserCuisinePref");

            migrationBuilder.DropForeignKey(
                name: "FK_UserCuisinePref_UserPreferences_UserPreferenceId",
                table: "UserCuisinePref");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTaboo_StandardIngredients_StandardIngredientId",
                table: "UserTaboo");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTaboo_UserPreferences_UserPreferenceId",
                table: "UserTaboo");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTastePref_StandardTaste_StandardTasteId",
                table: "UserTastePref");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTastePref_UserPreferences_UserPreferenceId",
                table: "UserTastePref");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserTastePref",
                table: "UserTastePref");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserTaboo",
                table: "UserTaboo");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserCuisinePref",
                table: "UserCuisinePref");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserAllergy",
                table: "UserAllergy");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StandardTaste",
                table: "StandardTaste");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StandardCuisine",
                table: "StandardCuisine");

            migrationBuilder.RenameTable(
                name: "UserTastePref",
                newName: "UserTastePrefs");

            migrationBuilder.RenameTable(
                name: "UserTaboo",
                newName: "UserTaboos");

            migrationBuilder.RenameTable(
                name: "UserCuisinePref",
                newName: "UserCuisinePrefs");

            migrationBuilder.RenameTable(
                name: "UserAllergy",
                newName: "UserAllergies");

            migrationBuilder.RenameTable(
                name: "StandardTaste",
                newName: "StandardTastes");

            migrationBuilder.RenameTable(
                name: "StandardCuisine",
                newName: "StandardCuisines");

            migrationBuilder.RenameIndex(
                name: "IX_UserTastePref_UserPreferenceId",
                table: "UserTastePrefs",
                newName: "IX_UserTastePrefs_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserTastePref_StandardTasteId",
                table: "UserTastePrefs",
                newName: "IX_UserTastePrefs_StandardTasteId");

            migrationBuilder.RenameIndex(
                name: "IX_UserTaboo_UserPreferenceId",
                table: "UserTaboos",
                newName: "IX_UserTaboos_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserTaboo_StandardIngredientId",
                table: "UserTaboos",
                newName: "IX_UserTaboos_StandardIngredientId");

            migrationBuilder.RenameIndex(
                name: "IX_UserCuisinePref_UserPreferenceId",
                table: "UserCuisinePrefs",
                newName: "IX_UserCuisinePrefs_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserCuisinePref_StandardCuisineId",
                table: "UserCuisinePrefs",
                newName: "IX_UserCuisinePrefs_StandardCuisineId");

            migrationBuilder.RenameIndex(
                name: "IX_UserAllergy_UserPreferenceId",
                table: "UserAllergies",
                newName: "IX_UserAllergies_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserAllergy_StandardIngredientId",
                table: "UserAllergies",
                newName: "IX_UserAllergies_StandardIngredientId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserTastePrefs",
                table: "UserTastePrefs",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserTaboos",
                table: "UserTaboos",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserCuisinePrefs",
                table: "UserCuisinePrefs",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserAllergies",
                table: "UserAllergies",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StandardTastes",
                table: "StandardTastes",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StandardCuisines",
                table: "StandardCuisines",
                column: "Id");

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
                    InventorySnapshotJson = table.Column<string>(type: "text", nullable: false),
                    PreferencesSnapshotJson = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AiGenerationSessions", x => x.Id);
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

            migrationBuilder.CreateIndex(
                name: "IX_GeneratedRecipeOptions_AiGenerationSessionId",
                table: "GeneratedRecipeOptions",
                column: "AiGenerationSessionId");

            migrationBuilder.AddForeignKey(
                name: "FK_UserAllergies_StandardIngredients_StandardIngredientId",
                table: "UserAllergies",
                column: "StandardIngredientId",
                principalTable: "StandardIngredients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserAllergies_UserPreferences_UserPreferenceId",
                table: "UserAllergies",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserCuisinePrefs_StandardCuisines_StandardCuisineId",
                table: "UserCuisinePrefs",
                column: "StandardCuisineId",
                principalTable: "StandardCuisines",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserCuisinePrefs_UserPreferences_UserPreferenceId",
                table: "UserCuisinePrefs",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTaboos_StandardIngredients_StandardIngredientId",
                table: "UserTaboos",
                column: "StandardIngredientId",
                principalTable: "StandardIngredients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTaboos_UserPreferences_UserPreferenceId",
                table: "UserTaboos",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTastePrefs_StandardTastes_StandardTasteId",
                table: "UserTastePrefs",
                column: "StandardTasteId",
                principalTable: "StandardTastes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTastePrefs_UserPreferences_UserPreferenceId",
                table: "UserTastePrefs",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserAllergies_StandardIngredients_StandardIngredientId",
                table: "UserAllergies");

            migrationBuilder.DropForeignKey(
                name: "FK_UserAllergies_UserPreferences_UserPreferenceId",
                table: "UserAllergies");

            migrationBuilder.DropForeignKey(
                name: "FK_UserCuisinePrefs_StandardCuisines_StandardCuisineId",
                table: "UserCuisinePrefs");

            migrationBuilder.DropForeignKey(
                name: "FK_UserCuisinePrefs_UserPreferences_UserPreferenceId",
                table: "UserCuisinePrefs");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTaboos_StandardIngredients_StandardIngredientId",
                table: "UserTaboos");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTaboos_UserPreferences_UserPreferenceId",
                table: "UserTaboos");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTastePrefs_StandardTastes_StandardTasteId",
                table: "UserTastePrefs");

            migrationBuilder.DropForeignKey(
                name: "FK_UserTastePrefs_UserPreferences_UserPreferenceId",
                table: "UserTastePrefs");

            migrationBuilder.DropTable(
                name: "GeneratedRecipeOptions");

            migrationBuilder.DropTable(
                name: "AiGenerationSessions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserTastePrefs",
                table: "UserTastePrefs");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserTaboos",
                table: "UserTaboos");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserCuisinePrefs",
                table: "UserCuisinePrefs");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserAllergies",
                table: "UserAllergies");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StandardTastes",
                table: "StandardTastes");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StandardCuisines",
                table: "StandardCuisines");

            migrationBuilder.RenameTable(
                name: "UserTastePrefs",
                newName: "UserTastePref");

            migrationBuilder.RenameTable(
                name: "UserTaboos",
                newName: "UserTaboo");

            migrationBuilder.RenameTable(
                name: "UserCuisinePrefs",
                newName: "UserCuisinePref");

            migrationBuilder.RenameTable(
                name: "UserAllergies",
                newName: "UserAllergy");

            migrationBuilder.RenameTable(
                name: "StandardTastes",
                newName: "StandardTaste");

            migrationBuilder.RenameTable(
                name: "StandardCuisines",
                newName: "StandardCuisine");

            migrationBuilder.RenameIndex(
                name: "IX_UserTastePrefs_UserPreferenceId",
                table: "UserTastePref",
                newName: "IX_UserTastePref_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserTastePrefs_StandardTasteId",
                table: "UserTastePref",
                newName: "IX_UserTastePref_StandardTasteId");

            migrationBuilder.RenameIndex(
                name: "IX_UserTaboos_UserPreferenceId",
                table: "UserTaboo",
                newName: "IX_UserTaboo_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserTaboos_StandardIngredientId",
                table: "UserTaboo",
                newName: "IX_UserTaboo_StandardIngredientId");

            migrationBuilder.RenameIndex(
                name: "IX_UserCuisinePrefs_UserPreferenceId",
                table: "UserCuisinePref",
                newName: "IX_UserCuisinePref_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserCuisinePrefs_StandardCuisineId",
                table: "UserCuisinePref",
                newName: "IX_UserCuisinePref_StandardCuisineId");

            migrationBuilder.RenameIndex(
                name: "IX_UserAllergies_UserPreferenceId",
                table: "UserAllergy",
                newName: "IX_UserAllergy_UserPreferenceId");

            migrationBuilder.RenameIndex(
                name: "IX_UserAllergies_StandardIngredientId",
                table: "UserAllergy",
                newName: "IX_UserAllergy_StandardIngredientId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserTastePref",
                table: "UserTastePref",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserTaboo",
                table: "UserTaboo",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserCuisinePref",
                table: "UserCuisinePref",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserAllergy",
                table: "UserAllergy",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StandardTaste",
                table: "StandardTaste",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StandardCuisine",
                table: "StandardCuisine",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_UserAllergy_StandardIngredients_StandardIngredientId",
                table: "UserAllergy",
                column: "StandardIngredientId",
                principalTable: "StandardIngredients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserAllergy_UserPreferences_UserPreferenceId",
                table: "UserAllergy",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserCuisinePref_StandardCuisine_StandardCuisineId",
                table: "UserCuisinePref",
                column: "StandardCuisineId",
                principalTable: "StandardCuisine",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserCuisinePref_UserPreferences_UserPreferenceId",
                table: "UserCuisinePref",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTaboo_StandardIngredients_StandardIngredientId",
                table: "UserTaboo",
                column: "StandardIngredientId",
                principalTable: "StandardIngredients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTaboo_UserPreferences_UserPreferenceId",
                table: "UserTaboo",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTastePref_StandardTaste_StandardTasteId",
                table: "UserTastePref",
                column: "StandardTasteId",
                principalTable: "StandardTaste",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserTastePref_UserPreferences_UserPreferenceId",
                table: "UserTastePref",
                column: "UserPreferenceId",
                principalTable: "UserPreferences",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
