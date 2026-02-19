package com.calotter.user.repository;

import com.calotter.user.domain.entity.Household;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HouseholdRepository extends JpaRepository<Household, Long> {
    Optional<Household> findByInviteCode(String inviteCode);
    List<Household> findByOwnerId(Long ownerId);
}
