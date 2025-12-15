package com.calotter.cooking.repository;

import com.calotter.cooking.domain.entity.Dish;
import com.calotter.user.domain.entity.Household;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Dish 数据访问接口
 */
@Repository
public interface DishRepository extends JpaRepository<Dish, Long> {
    
    /**
     * 根据家庭查询所有Dish
     */
    List<Dish> findByHousehold(Household household);
    
    /**
     * 根据家庭ID查询所有Dish
     */
    List<Dish> findByHouseholdId(Long householdId);
    
    /**
     * 根据ID和家庭查询Dish（用于权限验证）
     */
    Optional<Dish> findByIdAndHousehold(Long id, Household household);
}

