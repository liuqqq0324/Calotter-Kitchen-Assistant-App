package com.calotter.cooking.repository;

import com.calotter.cooking.domain.entity.HouseholdFavoriteDish;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HouseholdFavoriteDishRepository extends JpaRepository<HouseholdFavoriteDish, Long> {
    /**
     * 根据家庭ID和菜谱ID查找收藏关系
     */
    Optional<HouseholdFavoriteDish> findByHouseholdIdAndRecipeId(Long householdId, Long recipeId);
    
    /**
     * 根据家庭ID查询所有收藏关系
     */
    List<HouseholdFavoriteDish> findByHouseholdId(Long householdId);
    
    /**
     * 删除收藏关系
     */
    long deleteByHouseholdIdAndRecipeId(Long householdId, Long recipeId);
    
    /**
     * 检查收藏关系是否存在
     */
    boolean existsByHouseholdIdAndRecipeId(Long householdId, Long recipeId);
}


