using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SousChefBackend.Migrations
{
    /// <inheritdoc />
    public partial class AddMissingAiFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CookersSnapshotJson",
                table: "AiGenerationSessions",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DifficultyTarget",
                table: "AiGenerationSessions",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "DishCount",
                table: "AiGenerationSessions",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "MaxCookingTimeMin",
                table: "AiGenerationSessions",
                type: "integer",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CookersSnapshotJson",
                table: "AiGenerationSessions");

            migrationBuilder.DropColumn(
                name: "DifficultyTarget",
                table: "AiGenerationSessions");

            migrationBuilder.DropColumn(
                name: "DishCount",
                table: "AiGenerationSessions");

            migrationBuilder.DropColumn(
                name: "MaxCookingTimeMin",
                table: "AiGenerationSessions");
        }
    }
}
