package com.calotter.inventory;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@MapperScan("com.calotter.inventory.mapper")
@SpringBootApplication
public class CalotterInventoryApplication {

    public static void main(String[] args) {
        SpringApplication.run(CalotterInventoryApplication.class, args);
    }

}
