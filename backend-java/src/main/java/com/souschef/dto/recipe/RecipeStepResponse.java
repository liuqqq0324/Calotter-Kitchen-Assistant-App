package com.souschef.dto.recipe;

import lombok.Data;

@Data
public class RecipeStepResponse {
    private Integer stepNumber;
    private String instruction;
    private Integer stepTimeMin;
}

