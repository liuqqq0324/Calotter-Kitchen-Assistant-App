package com.souschef.repository;

import com.souschef.entity.RecipeKitchenware;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecipeKitchenwareRepository extends JpaRepository<RecipeKitchenware, Integer> {
    
    // 根据recipe_id查询所有厨具
    @Query("SELECT rk FROM RecipeKitchenware rk WHERE rk.recipe.id = :recipeId")
    List<RecipeKitchenware> findByRecipeId(@Param("recipeId") Integer recipeId);
}

