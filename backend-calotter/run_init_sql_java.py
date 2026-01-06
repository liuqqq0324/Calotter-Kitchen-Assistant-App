#!/usr/bin/env python3
"""
使用Java JDBC执行SQL脚本（无需Python依赖）
Execute SQL script using Java JDBC (no Python dependencies required)
"""
import sys
import os
import subprocess
import tempfile

# 数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'calotter',
    'user': 'postgres',
    'password': '123'
}

def find_postgresql_jdbc_jar():
    """查找PostgreSQL JDBC驱动JAR文件"""
    # 可能的路径
    possible_paths = [
        os.path.expanduser('~/.m2/repository/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar'),
        os.path.expanduser('~/.m2/repository/org/postgresql/postgresql/42.6.0/postgresql-42.6.0.jar'),
        os.path.expanduser('~/.m2/repository/org/postgresql/postgresql/42.5.0/postgresql-42.5.0.jar'),
        '/opt/homebrew/lib/postgresql.jar',
        '/usr/local/lib/postgresql.jar',
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
    
    return None

def create_java_executor(sql_file_path):
    """创建Java类来执行SQL"""
    # 转义路径中的反斜杠和引号
    escaped_path = sql_file_path.replace('\\', '/').replace("'", "\\'")
    
    java_code = f'''
import java.sql.*;
import java.nio.file.*;
import java.util.stream.Collectors;

class ExecuteSQL {{
    public static void main(String[] args) {{
        String jdbcUrl = "jdbc:postgresql://{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}";
        String username = "{DB_CONFIG['user']}";
        String password = "{DB_CONFIG['password']}";
        String sqlFile = "{escaped_path}";
        
        try {{
            // 加载驱动
            Class.forName("org.postgresql.Driver");
            
            // 连接数据库
            Connection conn = DriverManager.getConnection(jdbcUrl, username, password);
            conn.setAutoCommit(true);
            
            // 检查表是否存在
            DatabaseMetaData meta = conn.getMetaData();
            String[] tables = {{"ref_standard_allergens", "ref_standard_ingredients", 
                              "ref_standard_spices", "ref_standard_utensils"}};
            
            boolean allTablesExist = true;
            for (String table : tables) {{
                ResultSet rs = meta.getTables(null, null, table, null);
                if (!rs.next()) {{
                    System.err.println("⚠️  警告: 表 '" + table + "' 不存在");
                    allTablesExist = false;
                }}
                rs.close();
            }}
            
            if (!allTablesExist) {{
                System.err.println("\\n❌ 错误: 部分表不存在，请先运行后端应用让JPA自动创建表");
                System.err.println("   或者检查数据库连接和表结构");
                System.err.println("\\n📋 执行步骤:");
                System.err.println("   1. 先启动后端应用（会自动创建表结构）:");
                System.err.println("      cd calotter-start");
                System.err.println("      mvn spring-boot:run");
                System.err.println("   2. 等待应用启动完成（看到 'Started CalotterApplication' 消息）");
                System.err.println("   3. 停止应用（Ctrl+C）");
                System.err.println("   4. 然后再运行此脚本初始化数据:");
                System.err.println("      python3 run_init_sql_java.py");
                System.err.println("\\n💡 或者使用数据库管理工具手动执行SQL文件");
                conn.close();
                System.exit(1);
            }}
            
            System.out.println("✅ 所有必需的表已存在，开始执行SQL...");
            
            // 读取SQL文件
            String sqlContent = Files.lines(Paths.get(sqlFile))
                .collect(Collectors.joining("\\n"));
            
            // 使用更智能的SQL分割（处理DO $$块）
            Statement stmt = conn.createStatement();
            int executed = 0;
            StringBuilder currentStatement = new StringBuilder();
            boolean inDollarQuote = false;
            String dollarTag = null;
            
            String[] lines = sqlContent.split("\\n");
            for (String line : lines) {{
                String trimmed = line.trim();
                
                // 跳过注释行
                if (trimmed.isEmpty() || trimmed.startsWith("--")) {{
                    continue;
                }}
                
                currentStatement.append(line).append("\\n");
                
                // 检测DO $$块开始
                if (trimmed.matches("DO\\\\s+\\\\$\\\\$[\\\\w]*")) {{
                    inDollarQuote = true;
                    dollarTag = trimmed.replaceAll("DO\\\\s+\\\\$\\\\$", "").trim();
                    if (dollarTag.isEmpty()) {{
                        dollarTag = "$$";
                    }} else {{
                        dollarTag = "$" + dollarTag + "$";
                    }}
                    continue;
                }}
                
                // 检测$$块结束
                if (inDollarQuote && trimmed.endsWith(dollarTag + ";")) {{
                    inDollarQuote = false;
                    dollarTag = null;
                    // 执行完整的DO块
                    String statement = currentStatement.toString().trim();
                    if (!statement.isEmpty()) {{
                        try {{
                            stmt.execute(statement);
                            executed++;
                            if (executed % 10 == 0) {{
                                System.out.println("已执行 " + executed + " 条SQL语句...");
                            }}
                        }} catch (SQLException e) {{
                            String msg = e.getMessage();
                            // 忽略重复键错误、序列不存在错误（幂等性）
                            if (!msg.contains("duplicate key") && 
                                !msg.contains("already exists") &&
                                !msg.contains("does not exist") &&
                                !msg.contains("_id_seq")) {{
                                System.err.println("警告: " + msg);
                            }}
                        }}
                    }}
                    currentStatement.setLength(0);
                    continue;
                }}
                
                // 如果不在$$块中，检查是否遇到分号（语句结束）
                if (!inDollarQuote && trimmed.endsWith(";")) {{
                    String statement = currentStatement.toString().trim();
                    if (!statement.isEmpty()) {{
                        try {{
                            stmt.execute(statement);
                            executed++;
                            if (executed % 10 == 0) {{
                                System.out.println("已执行 " + executed + " 条SQL语句...");
                            }}
                        }} catch (SQLException e) {{
                            String msg = e.getMessage();
                            // 忽略重复键错误、序列不存在错误（幂等性）
                            if (!msg.contains("duplicate key") && 
                                !msg.contains("already exists") &&
                                !msg.contains("does not exist") &&
                                !msg.contains("_id_seq")) {{
                                System.err.println("警告: " + msg);
                            }}
                        }}
                    }}
                    currentStatement.setLength(0);
                }}
            }}
            
            stmt.close();
            conn.close();
            
            System.out.println("\\n✅ 成功执行 " + executed + " 条SQL语句");
            System.out.println("标准库数据初始化完成！");
            
        }} catch (Exception e) {{
            System.err.println("❌ 执行失败: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }}
    }}
}}
'''
    return java_code

def execute_with_java(sql_file_path):
    """使用Java执行SQL"""
    # 查找JDBC驱动
    jdbc_jar = find_postgresql_jdbc_jar()
    if not jdbc_jar:
        print("❌ 未找到PostgreSQL JDBC驱动")
        print("请先运行后端项目，Maven会自动下载JDBC驱动到 ~/.m2/repository/")
        return False
    
    # 创建临时目录和Java文件
    temp_dir = tempfile.mkdtemp()
    java_file = os.path.join(temp_dir, 'ExecuteSQL.java')
    
    try:
        # 写入Java代码
        with open(java_file, 'w', encoding='utf-8') as f:
            f.write(create_java_executor(sql_file_path))
        
        # 编译Java文件
        print("正在编译Java执行器...")
        compile_result = subprocess.run(
            ['javac', '-cp', jdbc_jar, java_file],
            capture_output=True,
            text=True,
            cwd=temp_dir
        )
        
        if compile_result.returncode != 0:
            print(f"❌ 编译失败: {compile_result.stderr}")
            return False
        
        # 执行Java类
        print("正在执行SQL脚本...")
        exec_result = subprocess.run(
            ['java', '-cp', f'{temp_dir}:{jdbc_jar}', 'ExecuteSQL'],
            capture_output=True,
            text=True
        )
        
        print(exec_result.stdout)
        if exec_result.stderr:
            print(exec_result.stderr)
        
        return exec_result.returncode == 0
        
    except FileNotFoundError:
        print("❌ 未找到Java编译器 (javac) 或Java运行时 (java)")
        print("请确保已安装Java JDK")
        return False
    except Exception as e:
        print(f"❌ 执行失败: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        # 清理临时文件
        try:
            import shutil
            shutil.rmtree(temp_dir, ignore_errors=True)
        except:
            pass

if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sql_file = os.path.join(script_dir, 'init-standard-libraries.sql')
    
    if len(sys.argv) > 1:
        sql_file = sys.argv[1]
    
    if not os.path.exists(sql_file):
        print(f"❌ 错误: SQL文件不存在: {sql_file}")
        sys.exit(1)
    
    print("=" * 60)
    print("标准库数据初始化脚本 (使用Java JDBC)")
    print("Standard Libraries Data Initialization Script")
    print("=" * 60)
    print()
    
    success = execute_with_java(sql_file)
    sys.exit(0 if success else 1)

