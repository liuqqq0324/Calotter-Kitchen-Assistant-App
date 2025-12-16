package com.calotter.inventory.repository;

import com.calotter.common.core.domain.entity.StandardIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StandardIngredientRepository extends JpaRepository<StandardIngredient, Long> {
    
    /**
     * 通过名称精确查找标准食材
     */
    Optional<StandardIngredient> findByName(String name);
    
    /**
     * 通过名称模糊查找标准食材（不区分大小写）
     */
    @Query("SELECT s FROM StandardIngredient s WHERE LOWER(s.name) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<StandardIngredient> findByNameContainingIgnoreCase(@Param("name") String name);
}
