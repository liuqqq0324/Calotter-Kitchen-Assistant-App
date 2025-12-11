package com.souschef.repository;

import com.souschef.entity.IntakeRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface IntakeRecordRepository extends JpaRepository<IntakeRecord, Integer> {
    
    /**
     * Find intake records for a user on a specific date
     */
    List<IntakeRecord> findByUserIdAndDate(Long userId, LocalDate date);
    
    /**
     * Find intake records for a user on a specific date by source type
     */
    List<IntakeRecord> findByUserIdAndDateAndSourceType(Long userId, LocalDate date, String sourceType);
    
    /**
     * Find intake records for a user within a date range
     */
    @Query("SELECT ir FROM IntakeRecord ir WHERE ir.userId = :userId " +
           "AND ir.date >= :startDate AND ir.date <= :endDate")
    List<IntakeRecord> findByUserIdAndDateRange(
        @Param("userId") Long userId,
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate
    );
    
    /**
     * Sum effective nutrition values for a user within a date range
     */
    @Query("SELECT " +
           "COALESCE(SUM(ir.effectiveEnergy), 0), " +
           "COALESCE(SUM(ir.effectiveFat), 0), " +
           "COALESCE(SUM(ir.effectiveCarbohydrates), 0), " +
           "COALESCE(SUM(ir.effectiveProtein), 0) " +
           "FROM IntakeRecord ir " +
           "WHERE ir.userId = :userId AND ir.date >= :startDate AND ir.date <= :endDate")
    Object[] sumEffectiveNutritionByDateRange(
        @Param("userId") Long userId,
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate
    );
}
