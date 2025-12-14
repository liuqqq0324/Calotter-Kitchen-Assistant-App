package com.calotter.cooking.repository;

import com.calotter.cooking.domain.entity.CookingSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CookingSessionRepository extends JpaRepository<CookingSession, Long> {
    List<CookingSession> findByHouseholdId(Long householdId);
    List<CookingSession> findByInitiatorId(Long initiatorId);
}
