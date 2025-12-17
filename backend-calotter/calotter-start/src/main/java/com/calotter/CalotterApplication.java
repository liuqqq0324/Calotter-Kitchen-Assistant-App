package com.calotter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Calotter 应用启动类
 */
@SpringBootApplication
@EnableScheduling
public class CalotterApplication {

    public static void main(String[] args) {
        SpringApplication.run(CalotterApplication.class, args);
    }
}
