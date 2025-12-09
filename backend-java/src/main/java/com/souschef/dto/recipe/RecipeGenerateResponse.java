package com.souschef.dto.recipe;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeGenerateResponse {
    private List<RecipeMenuResponse> menus;
}
