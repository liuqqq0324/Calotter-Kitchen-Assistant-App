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
        
        // 🔥 调试：检查系统环境变量
        String groqFromSystem = System.getenv("GROQ_API_KEY");
        String geminiFromSystem = System.getenv("GEMINI_API_KEY");
        System.out.println("=== DotenvConfig: System Environment Variables ===");
        System.out.println("GROQ_API_KEY from System.getenv(): " + (groqFromSystem != null ? "EXISTS (length: " + groqFromSystem.length() + ")" : "NOT SET"));
        System.out.println("GEMINI_API_KEY from System.getenv(): " + (geminiFromSystem != null ? "EXISTS (length: " + geminiFromSystem.length() + ")" : "NOT SET"));
        System.out.println("==================================================");
        
        // 查找 .env 文件
        File envFile = findEnvFile();
        
        if (envFile != null && envFile.exists()) {
            System.out.println("=== DotenvConfig: Found .env file at: " + envFile.getAbsolutePath());
            Map<String, Object> envProperties = loadEnvFile(envFile);
            if (!envProperties.isEmpty()) {
                System.out.println("=== DotenvConfig: Loaded " + envProperties.size() + " properties from .env file");
                
                // 🔥 调试：检查加载的 key
                System.out.println("=== DotenvConfig: Checking loaded keys ===");
                System.out.println("GROQ_API_KEY in .env: " + (envProperties.containsKey("GROQ_API_KEY") ? "YES (length: " + envProperties.get("GROQ_API_KEY").toString().length() + ")" : "NO"));
                System.out.println("GEMINI_API_KEY in .env: " + (envProperties.containsKey("GEMINI_API_KEY") ? "YES (length: " + envProperties.get("GEMINI_API_KEY").toString().length() + ")" : "NO"));
                System.out.println("==========================================");
                
                environment.getPropertySources().addFirst(
                    new MapPropertySource("dotenv", envProperties)
                );
            } else {
                System.out.println("=== DotenvConfig: Warning - .env file is empty or no valid properties found");
            }
        } else {
            System.out.println("=== DotenvConfig: Warning - .env file not found");
        }
    }

    /**
     * 查找 .env 文件
     * 优先查找项目根目录（backend-calotter），然后是当前工作目录
     */
    private File findEnvFile() {
        System.out.println("=== DotenvConfig: Starting to find .env file ===");
        
        // 尝试从当前工作目录查找
        String currentDir = System.getProperty("user.dir");
        System.out.println("=== DotenvConfig: Current working directory: " + currentDir);
        
        File envFile = new File(currentDir, ".env");
        System.out.println("=== DotenvConfig: Checking: " + envFile.getAbsolutePath() + " (exists: " + envFile.exists() + ")");
        
        if (envFile.exists()) {
            System.out.println("=== DotenvConfig: Found .env file at current directory");
            return envFile;
        }
        
        // 如果当前目录是 calotter-start，尝试在父目录查找
        File parentDir = new File(currentDir).getParentFile();
        if (parentDir != null) {
            envFile = new File(parentDir, ".env");
            System.out.println("=== DotenvConfig: Checking parent directory: " + envFile.getAbsolutePath() + " (exists: " + envFile.exists() + ")");
            if (envFile.exists()) {
                System.out.println("=== DotenvConfig: Found .env file at parent directory");
                return envFile;
            }
        }
        
        // 尝试从 classpath 查找（resources 目录）
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        if (classLoader.getResource(".env") != null) {
            String resourcePath = classLoader.getResource(".env").getPath();
            envFile = new File(resourcePath);
            System.out.println("=== DotenvConfig: Checking classpath: " + envFile.getAbsolutePath() + " (exists: " + envFile.exists() + ")");
            if (envFile.exists()) {
                System.out.println("=== DotenvConfig: Found .env file in classpath");
                return envFile;
            }
        }
        
        System.out.println("=== DotenvConfig: .env file not found in any location");
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
                
                // 🔥 调试日志：特别关注 API Key 相关的环境变量
                if (key.equals("GROQ_API_KEY") || key.equals("GEMINI_API_KEY")) {
                    System.out.println("=== DotenvConfig: Loaded " + key + " = " + 
                        (value.length() > 10 ? value.substring(0, 10) + "..." : value) + 
                        " (length: " + value.length() + ")");
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

