package com.calotter.health.repository;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.user.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * 营养日志Repository
 */
@Repository
public interface NutritionLogRepository extends JpaRepository<NutritionLog, Long> {
    
    /**
     * 根据用户和日期范围查询营养日志
     */
    List<NutritionLog> findByUserAndLogDateBetween(
            User user, LocalDate start, LocalDate end);
    
    /**
     * 根据用户查询所有营养日志
     */
    List<NutritionLog> findByUser(User user);
    
    /**
     * 根据Dish ID查询营养日志（用于追溯）
     */
    List<NutritionLog> findByDishId(Long dishId);
}

