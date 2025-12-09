package com.calotter.user;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@MapperScan("com.calotter.user.mapper")
@SpringBootApplication
public class CalotterUserApplication {

    public static void main(String[] args) {
        SpringApplication.run(CalotterUserApplication.class, args);
    }

}
