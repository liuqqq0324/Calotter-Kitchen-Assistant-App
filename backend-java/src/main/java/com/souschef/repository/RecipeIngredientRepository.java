package com.souschef.repository;

import com.souschef.entity.RecipeIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, Integer> {
    
    // 根据recipe_id查询所有食材
    @Query("SELECT ri FROM RecipeIngredient ri WHERE ri.recipe.id = :recipeId ORDER BY ri.sort")
    List<RecipeIngredient> findByRecipeId(@Param("recipeId") Integer recipeId);
    
    // 根据ingredient_id查询所有使用该食材的食谱
    @Query("SELECT ri FROM RecipeIngredient ri WHERE ri.ingredient.id = :ingredientId")
    List<RecipeIngredient> findByIngredientId(@Param("ingredientId") Integer ingredientId);
}

