#!/usr/bin/env python3
"""
执行标准库初始化SQL脚本
Execute standard libraries initialization SQL script
"""
import sys
import os
import subprocess

# 尝试导入psycopg2，如果没有则提示安装
try:
    import psycopg2
    from psycopg2 import sql
    PSYCOPG2_AVAILABLE = True
except ImportError:
    PSYCOPG2_AVAILABLE = False

# 数据库配置（从 application.yml 读取）
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'calotter',
    'user': 'postgres',
    'password': '123'
}

def execute_sql_file_with_psql(sql_file_path):
    """使用psql命令执行SQL文件（如果可用）"""
    try:
        # 尝试使用psql命令
        cmd = [
            'psql',
            '-h', DB_CONFIG['host'],
            '-p', str(DB_CONFIG['port']),
            '-U', DB_CONFIG['user'],
            '-d', DB_CONFIG['database'],
            '-f', sql_file_path
        ]
        
        # 设置密码环境变量
        env = os.environ.copy()
        env['PGPASSWORD'] = DB_CONFIG['password']
        
        print("正在使用psql执行SQL脚本...")
        result = subprocess.run(cmd, env=env, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ SQL脚本执行成功！")
            if result.stdout:
                print(result.stdout)
            return True
        else:
            print(f"❌ 执行失败: {result.stderr}")
            return False
    except FileNotFoundError:
        return None  # psql不可用，返回None尝试其他方法
    except Exception as e:
        print(f"❌ 执行psql命令时出错: {e}")
        return False

def execute_sql_file_with_psycopg2(sql_file_path):
    """使用psycopg2执行SQL文件"""
    if not os.path.exists(sql_file_path):
        print(f"错误: SQL文件不存在: {sql_file_path}")
        return False
    
    try:
        # 连接数据库
        print(f"正在连接数据库 {DB_CONFIG['database']}...")
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True  # 自动提交
        cursor = conn.cursor()
        
        # 读取SQL文件
        print(f"正在读取SQL文件: {sql_file_path}")
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # 执行SQL（按分号分割，逐条执行）
        print("正在执行SQL脚本...")
        sql_statements = [s.strip() for s in sql_content.split(';') if s.strip() and not s.strip().startswith('--')]
        
        executed_count = 0
        for i, statement in enumerate(sql_statements, 1):
            # 跳过空语句和注释
            if not statement or statement.startswith('--'):
                continue
            
            try:
                cursor.execute(statement)
                executed_count += 1
                if executed_count % 10 == 0:
                    print(f"  已执行 {executed_count} 条SQL语句...")
            except Exception as e:
                # 如果是ON CONFLICT错误，可以忽略（幂等性）
                if 'duplicate key' in str(e).lower() or 'already exists' in str(e).lower():
                    continue
                print(f"  警告: 执行第 {i} 条语句时出错: {e}")
                print(f"  语句: {statement[:100]}...")
        
        cursor.close()
        conn.close()
        
        print(f"\n✅ 成功执行 {executed_count} 条SQL语句")
        print("标准库数据初始化完成！")
        return True
        
    except psycopg2.OperationalError as e:
        print(f"❌ 数据库连接失败: {e}")
        print("\n请检查:")
        print("  1. PostgreSQL是否正在运行")
        print("  2. 数据库配置是否正确")
        print("  3. 数据库 'calotter' 是否存在")
        return False
    except Exception as e:
        print(f"❌ 执行失败: {e}")
        import traceback
        traceback.print_exc()
        return False

def execute_sql_file(sql_file_path):
    """执行SQL文件（自动选择方法）"""
    # 方法1: 尝试使用psql命令（最快）
    result = execute_sql_file_with_psql(sql_file_path)
    if result is True:
        return True
    elif result is False:
        return False
    
    # 方法2: 使用psycopg2
    if PSYCOPG2_AVAILABLE:
        return execute_sql_file_with_psycopg2(sql_file_path)
    else:
        print("❌ 错误: 需要安装 psycopg2 或 psql")
        print("\n请选择以下方式之一:")
        print("  1. 安装 psycopg2: pip3 install psycopg2-binary")
        print("  2. 安装 PostgreSQL 客户端工具 (包含psql)")
        print("  3. 使用数据库管理工具（如pgAdmin、DBeaver）手动执行SQL文件")
        return False

if __name__ == '__main__':
    # 获取SQL文件路径
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sql_file = os.path.join(script_dir, 'init-standard-libraries.sql')
    
    # 如果提供了命令行参数，使用参数作为SQL文件路径
    if len(sys.argv) > 1:
        sql_file = sys.argv[1]
    
    print("=" * 60)
    print("标准库数据初始化脚本")
    print("Standard Libraries Data Initialization Script")
    print("=" * 60)
    print()
    
    success = execute_sql_file(sql_file)
    
    sys.exit(0 if success else 1)

