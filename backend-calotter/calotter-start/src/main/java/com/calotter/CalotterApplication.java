package com.calotter;

import com.calotter.config.DotenvConfig;
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
        SpringApplication app = new SpringApplication(CalotterApplication.class);
        // 添加 DotenvConfig 初始化器，自动加载 .env 文件
        app.addInitializers(new DotenvConfig());
        app.run(args);
    }
}
