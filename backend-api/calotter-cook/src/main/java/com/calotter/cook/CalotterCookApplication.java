package com.calotter.cook;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@MapperScan("com.calotter.cook.mapper")
@SpringBootApplication
public class CalotterCookApplication {

    public static void main(String[] args) {
        SpringApplication.run(CalotterCookApplication.class, args);
    }

}
