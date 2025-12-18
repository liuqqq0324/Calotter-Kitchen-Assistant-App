package com.calotter.user.repository;

import com.calotter.user.domain.entity.FamilyMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FamilyMemberRepository extends JpaRepository<FamilyMember, Long> {
    List<FamilyMember> findAllByIdIn(List<Long> ids);
    List<FamilyMember> findByHouseholdId(Long householdId);
    List<FamilyMember> findByUserId(Long userId);
}
