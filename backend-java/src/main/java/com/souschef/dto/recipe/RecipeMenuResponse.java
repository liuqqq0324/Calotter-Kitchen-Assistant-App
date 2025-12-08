package com.souschef.dto.recipe;

import lombok.Data;
import java.util.List;

@Data
public class RecipeMenuResponse {
    private Integer menuId; // 1~5
    private List<RecipeResponse> recipes;
}

