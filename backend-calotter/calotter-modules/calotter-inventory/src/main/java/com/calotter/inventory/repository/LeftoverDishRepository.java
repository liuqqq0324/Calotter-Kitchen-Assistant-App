package com.calotter.inventory.repository;

import com.calotter.inventory.domain.entity.LeftoverDish;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface LeftoverDishRepository extends JpaRepository<LeftoverDish, Long> {
    List<LeftoverDish> findByHouseholdId(Long householdId);
    
    /**
     * 根据家庭ID和制作日期查询剩菜
     * @param householdId 家庭ID
     * @param startDate 开始日期（当天00:00:00）
     * @param endDate 结束日期（当天23:59:59）
     * @return 剩菜列表
     */
    @Query("SELECT l FROM LeftoverDish l WHERE l.household.id = :householdId " +
           "AND l.producedTime >= :startDate AND l.producedTime < :endDate")
    List<LeftoverDish> findByHouseholdIdAndProducedTimeBetween(
            @Param("householdId") Long householdId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
}
