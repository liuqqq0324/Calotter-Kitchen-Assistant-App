package com.souschef.repository;

import com.souschef.entity.UserTaboo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserTabooRepository extends JpaRepository<UserTaboo, Long> {
    List<UserTaboo> findByUserId(Long userId);
    void deleteByUserId(Long userId);
}

