package com.calotter.homepage;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * Calotter Homepage Application
 * 营养追踪和摄入管理服务
 *
 * @author Auto Generated
 */
@MapperScan("com.calotter.homepage.mapper")
@SpringBootApplication
@EnableDiscoveryClient
public class CalotterHomepageApplication {

    public static void main(String[] args) {
        SpringApplication.run(CalotterHomepageApplication.class, args);
    }

}
