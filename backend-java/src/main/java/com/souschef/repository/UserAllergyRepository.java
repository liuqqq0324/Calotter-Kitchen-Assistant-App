package com.souschef.repository;

import com.souschef.entity.UserAllergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserAllergyRepository extends JpaRepository<UserAllergy, Long> {
    List<UserAllergy> findByUserId(Long userId);
    void deleteByUserId(Long userId);
}


