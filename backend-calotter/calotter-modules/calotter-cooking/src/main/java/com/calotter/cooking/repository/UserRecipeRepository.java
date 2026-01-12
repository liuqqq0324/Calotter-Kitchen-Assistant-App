package com.calotter.cooking.repository;

import com.calotter.cooking.domain.entity.UserRecipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRecipeRepository extends JpaRepository<UserRecipe, Long> {
    /**
     * 根据家庭ID查询所有收藏菜谱
     */
    List<UserRecipe> findByHouseholdId(Long householdId);
    
    /**
     * 根据家庭ID和名称（忽略大小写）查找菜谱
     */
    Optional<UserRecipe> findFirstByHouseholdIdAndNameIgnoreCase(Long householdId, String name);
    
    /**
     * 检查菜谱是否存在且属于指定家庭
     */
    boolean existsByHouseholdIdAndId(Long householdId, Long id);
}

