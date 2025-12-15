package com.souschef.repository;

import com.souschef.entity.NutritionTarget;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface NutritionTargetRepository extends JpaRepository<NutritionTarget, Integer> {
    
    /**
     * Find nutrition target for a user in a specific week
     */
    @Query("SELECT nt FROM NutritionTarget nt WHERE nt.userId = :userId " +
           "AND nt.weekStart <= :date AND nt.weekEnd >= :date")
    Optional<NutritionTarget> findByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);
    
    /**
     * Find nutrition target for a user by week start date
     */
    Optional<NutritionTarget> findByUserIdAndWeekStart(Long userId, LocalDate weekStart);
}
