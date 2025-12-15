package com.calotter.health.repository;

import com.calotter.health.domain.entity.NutritionLog;
import com.calotter.user.domain.entity.FamilyMember;
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
     * 根据家庭成员和日期范围查询营养日志
     */
    List<NutritionLog> findByFamilyMemberAndLogDateBetween(
            FamilyMember member, LocalDate start, LocalDate end);
    
    /**
     * 根据家庭成员查询所有营养日志
     */
    List<NutritionLog> findByFamilyMember(FamilyMember member);
    
    /**
     * 根据Dish ID查询营养日志（用于追溯）
     */
    List<NutritionLog> findByDishId(Long dishId);
}

