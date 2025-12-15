package com.calotter.user.repository;

import com.calotter.user.domain.entity.FamilyMember;
import com.calotter.user.domain.entity.HealthGoal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HealthGoalRepository extends JpaRepository<HealthGoal, Long> {
    HealthGoal findByFamilyMemberAndStatus(FamilyMember member, Integer status);
}
