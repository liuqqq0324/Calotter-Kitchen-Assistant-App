using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace SousChefBackend.Migrations
{
    /// <inheritdoc />
    public partial class SeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "StandardCookwares",
                columns: new[] { "Id", "AiCode", "Name" },
                values: new object[,]
                {
                    { 1, "stove", "Stove Top" },
                    { 2, "oven", "Oven" },
                    { 3, "microwave", "Microwave" },
                    { 4, "air_fryer", "Air Fryer" },
                    { 5, "rice_cooker", "Rice Cooker" }
                });

            migrationBuilder.InsertData(
                table: "StandardCuisines",
                columns: new[] { "Id", "AiCode", "Name" },
                values: new object[,]
                {
                    { 1, "chinese", "Chinese" },
                    { 2, "italian", "Italian" },
                    { 3, "japanese", "Japanese" },
                    { 4, "mexican", "Mexican" },
                    { 5, "western", "Western" }
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
                    { 9, "g", "Nuts", "", "Peanut" }
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
                    { 6, "chili_powder", "Chili Powder" }
                });

            migrationBuilder.InsertData(
                table: "StandardTastes",
                columns: new[] { "Id", "AiCode", "Name" },
                values: new object[,]
                {
                    { 1, "spicy", "Spicy" },
                    { 2, "sweet", "Sweet" },
                    { 3, "sour", "Sour" },
                    { 4, "salty", "Salty" },
                    { 5, "light", "Light" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_StandardTastes_Name",
                table: "StandardTastes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StandardIngredients_Name",
                table: "StandardIngredients",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_StandardCuisines_Name",
                table: "StandardCuisines",
                column: "Name",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_StandardTastes_Name",
                table: "StandardTastes");

            migrationBuilder.DropIndex(
                name: "IX_StandardIngredients_Name",
                table: "StandardIngredients");

            migrationBuilder.DropIndex(
                name: "IX_StandardCuisines_Name",
                table: "StandardCuisines");

            migrationBuilder.DeleteData(
                table: "StandardCookwares",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "StandardCookwares",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StandardCookwares",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "StandardCookwares",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "StandardCookwares",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "StandardCuisines",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "StandardCuisines",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StandardCuisines",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "StandardCuisines",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "StandardCuisines",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "StandardIngredients",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "StandardSeasonings",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "StandardSeasonings",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StandardSeasonings",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "StandardSeasonings",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "StandardSeasonings",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "StandardSeasonings",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "StandardTastes",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "StandardTastes",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "StandardTastes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "StandardTastes",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "StandardTastes",
                keyColumn: "Id",
                keyValue: 5);
        }
    }
}
