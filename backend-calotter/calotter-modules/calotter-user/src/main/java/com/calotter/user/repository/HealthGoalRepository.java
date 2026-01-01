package com.calotter.user.repository;

import com.calotter.user.domain.entity.HealthGoal;
import com.calotter.user.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HealthGoalRepository extends JpaRepository<HealthGoal, Long> {
    HealthGoal findByUserAndStatus(User user, Integer status);
}
