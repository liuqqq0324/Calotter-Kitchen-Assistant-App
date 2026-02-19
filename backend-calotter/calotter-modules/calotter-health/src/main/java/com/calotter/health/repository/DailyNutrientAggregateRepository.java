package com.calotter.health.repository;

import com.calotter.health.domain.entity.DailyNutrientAggregate;
import com.calotter.user.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * 日营养聚合Repository
 */
@Repository
public interface DailyNutrientAggregateRepository extends JpaRepository<DailyNutrientAggregate, Long> {
    
    /**
     * 根据用户和日期查询日聚合记录
     */
    Optional<DailyNutrientAggregate> findByUserAndDate(
            User user, LocalDate date);
    
    /**
     * 根据用户和日期范围查询日聚合记录
     */
    List<DailyNutrientAggregate> findByUserAndDateBetween(
            User user, LocalDate start, LocalDate end);
}

