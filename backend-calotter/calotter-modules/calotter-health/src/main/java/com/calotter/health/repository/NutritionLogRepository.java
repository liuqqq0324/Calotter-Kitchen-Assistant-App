package com.calotter.health.repository;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.user.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

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
     * 根据用户和日期查询营养日志
     */
    List<NutritionLog> findByUserAndLogDate(User user, LocalDate logDate);
    
    /**
     * 根据用户、日期和来源类型查询营养日志
     */
    List<NutritionLog> findByUserAndLogDateAndSourceType(
            User user, LocalDate logDate, com.calotter.health.domain.enums.LogSourceType sourceType);
    
    /**
     * 根据用户查询所有营养日志
     */
    List<NutritionLog> findByUser(User user);
    
    /**
     * 根据Dish ID查询营养日志（用于追溯）
     */
    List<NutritionLog> findByDishId(Long dishId);
    
    /**
     * 根据ID和用户查询营养日志（用于权限校验）
     */
    Optional<NutritionLog> findByIdAndUser(Long id, User user);
    
    /**
     * 计算指定日期范围内的营养汇总
     * 返回 Map 包含: consumedEnergy, consumedFat, consumedCarbohydrates, consumedProtein
     */
    @Query("SELECT " +
           "COALESCE(SUM(log.energy), 0) as consumedEnergy, " +
           "COALESCE(SUM(log.fat), 0.0) as consumedFat, " +
           "COALESCE(SUM(log.carbohydrates), 0.0) as consumedCarbohydrates, " +
           "COALESCE(SUM(log.protein), 0.0) as consumedProtein " +
           "FROM NutritionLog log " +
           "WHERE log.user = :user AND log.logDate BETWEEN :start AND :end")
    Object[] sumNutritionByDateRange(
            @Param("user") User user,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end);
}

