package com.souschef.dto.recipe;

import lombok.Data;

@Data
public class RecipeIngredientResponse {
    private String name;
    private Double amountValue;
    private String amountUnit;
    private Boolean isOptional;
}

