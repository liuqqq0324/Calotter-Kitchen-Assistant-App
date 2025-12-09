package com.souschef.dto.recipe;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class RecipeMenuResponse {

    @JsonProperty("menu_id")
    private Integer menuId; // 1~5

    private List<RecipeResponse> recipes;
}
