// Models/GeneratedRecipe.cs

public class GeneratedRecipe
{
    public int Id { get; set; }
    // 对应 output_schema 里的 menus -> recipes
    public string Title { get; set; }
    public string ShortDescription { get; set; }
    public int Servings { get; set; }
    public int CookingTimeMin { get; set; }
    public string Difficulty { get; set; } // easy, medium, hard
    public double TotalCaloriesEstimate { get; set; }
    
    // 步骤 (存 JSONB)
    // 对应 Python output: steps array
    public string StepsJson { get; set; } 
    
    // 食材 (存 JSONB 或者关联表)
    // 对应 Python output: ingredients array
    public string IngredientsJson { get; set; } 
    
    public DateTime GeneratedAt { get; set; } = DateTime.Now;
}