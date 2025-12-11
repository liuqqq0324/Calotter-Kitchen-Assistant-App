package com.souschef.repository;

import com.souschef.entity.RecipeNutrition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RecipeNutritionRepository extends JpaRepository<RecipeNutrition, Integer> {
    
    /**
     * Find nutrition information by recipe ID
     */
    Optional<RecipeNutrition> findByRecipeId(Integer recipeId);
}
