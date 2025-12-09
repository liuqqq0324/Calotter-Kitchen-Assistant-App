package com.calotter.recipe;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@MapperScan("com.calotter.recipe.mapper")
@SpringBootApplication
public class CalotterRecipeApplication {

    public static void main(String[] args) {
        SpringApplication.run(CalotterRecipeApplication.class, args);
    }

}
