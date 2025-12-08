package com.souschef.repository;

import com.souschef.entity.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer> {
    
    // 根据菜系类型查询
    List<Recipe> findByCuisineType(String cuisineType);
    
    // 根据难度等级查询
    List<Recipe> findByDifficultyLevel(Integer difficultyLevel);
    
    // 根据标签查询（使用JSONB查询）
    @Query(value = "SELECT * FROM sous_chef_rms.rms_recipe WHERE tags @> :tagJson", nativeQuery = true)
    List<Recipe> findByTag(@Param("tagJson") String tagJson);
    
    // 根据总时间查询（小于等于指定时间）
    List<Recipe> findByTotalTimeMinutesLessThanEqual(Integer maxTime);
    
    // 根据每份卡路里查询（小于等于指定卡路里）
    List<Recipe> findByCaloriesPerServingLessThanEqual(Integer maxCalories);
}

