package com.souschef.repository;

import com.souschef.entity.Kitchen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface KitchenRepository extends JpaRepository<Kitchen, Integer> {
    Optional<Kitchen> findByUserId(Long userId);
}


