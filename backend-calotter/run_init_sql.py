#!/usr/bin/env python3
"""
运行 init-standard-libraries.sql 脚本
执行标准库数据初始化
"""

import sys
import os
import psycopg2
from psycopg2 import sql

# 数据库配置（从 docker-compose.yml 和 application.yml 获取）
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'calotter',
    'user': 'postgres',
    'password': '123'
}

def run_sql_file(sql_file_path):
    """执行 SQL 文件"""
    try:
        # 读取 SQL 文件
        print(f"📖 读取 SQL 文件: {sql_file_path}")
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # 连接到数据库
        print(f"🔌 连接到数据库: {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}")
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True  # 自动提交，因为 SQL 文件包含事务控制
        
        # 创建游标
        cursor = conn.cursor()
        
        # 执行 SQL（使用 execute 执行整个文件内容）
        print("⚙️  执行 SQL 脚本...")
        cursor.execute(sql_content)
        
        # 获取所有结果（包括 NOTICE 消息）
        try:
            results = cursor.fetchall()
            if results:
                for row in results:
                    print(f"   {row}")
        except psycopg2.ProgrammingError:
            # 如果没有返回结果（如 INSERT/UPDATE），这是正常的
            pass
        
        # 验证数据插入
        print("\n📊 验证数据插入...")
        cursor.execute("SELECT COUNT(*) FROM ref_standard_ingredients")
        ingredient_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM ref_standard_spices")
        spice_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM ref_standard_utensils")
        utensil_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM ref_standard_allergens")
        allergen_count = cursor.fetchone()[0]
        
        print(f"   ✅ 标准食材: {ingredient_count} 条")
        print(f"   ✅ 标准调料: {spice_count} 条")
        print(f"   ✅ 标准厨具: {utensil_count} 条")
        print(f"   ✅ 标准过敏原: {allergen_count} 条")
        
        # 关闭连接
        cursor.close()
        conn.close()
        
        print("✅ SQL 脚本执行成功！")
        return True
        
    except FileNotFoundError:
        print(f"❌ 错误: 找不到文件 {sql_file_path}")
        return False
    except psycopg2.OperationalError as e:
        print(f"❌ 数据库连接错误: {e}")
        print("\n💡 提示:")
        print("   1. 确保 PostgreSQL 正在运行")
        print("   2. 如果使用 Docker，运行: docker-compose up -d")
        print("   3. 检查数据库配置是否正确")
        return False
    except psycopg2.Error as e:
        print(f"❌ SQL 执行错误: {e}")
        return False
    except Exception as e:
        print(f"❌ 未知错误: {e}")
        return False

def main():
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sql_file = os.path.join(script_dir, 'init-standard-libraries.sql')
    
    # 检查文件是否存在
    if not os.path.exists(sql_file):
        print(f"❌ 错误: 找不到 SQL 文件: {sql_file}")
        sys.exit(1)
    
    print("=" * 60)
    print("标准库数据初始化脚本")
    print("=" * 60)
    print()
    
    # 执行 SQL 文件
    success = run_sql_file(sql_file)
    
    print()
    if success:
        print("=" * 60)
        print("✅ 初始化完成！")
        print("=" * 60)
        sys.exit(0)
    else:
        print("=" * 60)
        print("❌ 初始化失败！")
        print("=" * 60)
        sys.exit(1)

if __name__ == '__main__':
    main()

