using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SousChefBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddMissingRecipeFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Servings",
                table: "GeneratedRecipeOptions",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "UsedCookwaresJson",
                table: "GeneratedRecipeOptions",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Servings",
                table: "GeneratedRecipeOptions");

            migrationBuilder.DropColumn(
                name: "UsedCookwaresJson",
                table: "GeneratedRecipeOptions");
        }
    }
}
