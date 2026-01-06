#!/usr/bin/env python3
"""
执行标准库初始化SQL脚本 - 使用Java后端执行
Execute standard libraries initialization SQL script via Java backend
"""
import sys
import os
import subprocess
import json

def find_java_project_root():
    """查找Java项目根目录"""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    # 查找包含pom.xml的目录
    while current_dir != '/':
        if os.path.exists(os.path.join(current_dir, 'pom.xml')):
            return current_dir
        current_dir = os.path.dirname(current_dir)
    return None

def execute_via_maven(sql_file_path):
    """通过Maven执行SQL（如果后端正在运行）"""
    print("尝试通过Java后端执行SQL...")
    print("注意: 这需要后端服务正在运行，并且有相应的API端点")
    print("建议: 使用数据库管理工具手动执行SQL文件")
    return False

def print_sql_statements(sql_file_path):
    """打印SQL语句，让用户可以手动执行"""
    print("=" * 60)
    print("SQL文件内容预览（前50行）")
    print("=" * 60)
    
    with open(sql_file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        for i, line in enumerate(lines[:50], 1):
            print(f"{i:3}: {line.rstrip()}")
    
    if len(lines) > 50:
        print(f"\n... (共 {len(lines)} 行，仅显示前50行)")
    
    print("\n" + "=" * 60)
    print("执行建议:")
    print("=" * 60)
    print("1. 使用数据库管理工具（推荐）:")
    print("   - pgAdmin: https://www.pgadmin.org/")
    print("   - DBeaver: https://dbeaver.io/")
    print("   - TablePlus: https://tableplus.com/")
    print("   - DataGrip: https://www.jetbrains.com/datagrip/")
    print()
    print("2. 安装PostgreSQL客户端后使用psql:")
    print("   brew install postgresql")
    print("   psql -h localhost -U postgres -d calotter -f init-standard-libraries.sql")
    print()
    print("3. 安装Python依赖后使用Python脚本:")
    print("   pip3 install psycopg2-binary")
    print("   python3 run_init_sql.py")
    print()
    print("4. 如果使用Docker:")
    print("   docker exec -i <postgres_container> psql -U postgres -d calotter < init-standard-libraries.sql")

if __name__ == '__main__':
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sql_file = os.path.join(script_dir, 'init-standard-libraries.sql')
    
    if len(sys.argv) > 1:
        sql_file = sys.argv[1]
    
    if not os.path.exists(sql_file):
        print(f"❌ 错误: SQL文件不存在: {sql_file}")
        sys.exit(1)
    
    print("=" * 60)
    print("标准库数据初始化脚本")
    print("Standard Libraries Data Initialization Script")
    print("=" * 60)
    print()
    print("⚠️  注意: Python标准库无法直接连接PostgreSQL数据库")
    print("   需要安装 psycopg2 库或使用其他工具")
    print()
    
    # 尝试通过Maven（如果后端有相应功能）
    if execute_via_maven(sql_file):
        print("✅ 执行成功！")
        sys.exit(0)
    
    # 否则显示SQL内容和执行建议
    print_sql_statements(sql_file)
    
    sys.exit(0)

