package com.calotter.config;

import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Dotenv 配置类
 * 自动加载项目根目录下的 .env 文件到 Spring Environment
 */
public class DotenvConfig implements ApplicationContextInitializer<ConfigurableApplicationContext> {

    @Override
    public void initialize(ConfigurableApplicationContext applicationContext) {
        ConfigurableEnvironment environment = applicationContext.getEnvironment();
        
        // 查找 .env 文件
        File envFile = findEnvFile();
        
        if (envFile != null && envFile.exists()) {
            Map<String, Object> envProperties = loadEnvFile(envFile);
            if (!envProperties.isEmpty()) {
                environment.getPropertySources().addFirst(
                    new MapPropertySource("dotenv", envProperties)
                );
            }
        }
    }

    /**
     * 查找 .env 文件
     * 优先查找项目根目录（backend-calotter），然后是当前工作目录
     */
    private File findEnvFile() {
        // 尝试从当前工作目录查找
        String currentDir = System.getProperty("user.dir");
        File envFile = new File(currentDir, ".env");
        
        if (envFile.exists()) {
            return envFile;
        }
        
        // 如果当前目录是 calotter-start，尝试在父目录查找
        File parentDir = new File(currentDir).getParentFile();
        if (parentDir != null) {
            envFile = new File(parentDir, ".env");
            if (envFile.exists()) {
                return envFile;
            }
        }
        
        // 尝试从 classpath 查找（resources 目录）
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        if (classLoader.getResource(".env") != null) {
            String resourcePath = classLoader.getResource(".env").getPath();
            envFile = new File(resourcePath);
            if (envFile.exists()) {
                return envFile;
            }
        }
        
        return null;
    }

    /**
     * 加载 .env 文件内容
     */
    private Map<String, Object> loadEnvFile(File envFile) {
        Map<String, Object> properties = new HashMap<>();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(envFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                
                // 跳过空行和注释
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                
                // 解析 KEY=VALUE 格式
                int equalsIndex = line.indexOf('=');
                if (equalsIndex > 0) {
                    String key = line.substring(0, equalsIndex).trim();
                    String value = line.substring(equalsIndex + 1).trim();
                    
                    // 移除引号（如果有）
                    if ((value.startsWith("\"") && value.endsWith("\"")) ||
                        (value.startsWith("'") && value.endsWith("'"))) {
                        value = value.substring(1, value.length() - 1);
                    }
                    
                    properties.put(key, value);
                }
            }
        } catch (IOException e) {
            System.err.println("Warning: Failed to load .env file: " + e.getMessage());
        }
        
        return properties;
    }
}

