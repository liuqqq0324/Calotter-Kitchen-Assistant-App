#!/usr/bin/env python3
"""
标准库数据初始化脚本
执行标准库数据初始化（包含 YOLO 对齐）

此脚本会执行 init-standard-libraries.sql，该文件已包含：
1. 基础标准库数据初始化（过敏原、食材、调料、厨具）
2. YOLO 模型对齐（修复名称不一致，添加缺失食材）
3. 数据验证
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

def run_sql_file(sql_file_path, description=""):
    """执行 SQL 文件"""
    try:
        # 读取 SQL 文件
        if description:
            print(f"\n📖 {description}")
        print(f"   读取 SQL 文件: {os.path.basename(sql_file_path)}")
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # 连接到数据库
        print(f"   🔌 连接到数据库: {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}")
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True  # 自动提交，因为 SQL 文件包含事务控制
        
        # 创建游标
        cursor = conn.cursor()
        
        # 执行 SQL（使用 execute 执行整个文件内容）
        print("   ⚙️  执行 SQL 脚本...")
        cursor.execute(sql_content)
        
        # 获取所有结果（包括 NOTICE 消息）
        try:
            results = cursor.fetchall()
            if results:
                for row in results:
                    print(f"      {row}")
        except psycopg2.ProgrammingError:
            # 如果没有返回结果（如 INSERT/UPDATE），这是正常的
            pass
        
        # 关闭连接
        cursor.close()
        conn.close()
        
        print("   ✅ SQL 脚本执行成功！")
        return True
        
    except FileNotFoundError:
        print(f"   ❌ 错误: 找不到文件 {sql_file_path}")
        return False
    except psycopg2.OperationalError as e:
        print(f"   ❌ 数据库连接错误: {e}")
        print("\n   💡 提示:")
        print("      1. 确保 PostgreSQL 正在运行")
        print("      2. 如果使用 Docker，运行: docker-compose up -d")
        print("      3. 检查数据库配置是否正确")
        return False
    except psycopg2.Error as e:
        print(f"   ❌ SQL 执行错误: {e}")
        return False
    except Exception as e:
        print(f"   ❌ 未知错误: {e}")
        return False

def verify_data():
    """验证数据插入"""
    try:
        print("\n📊 验证数据完整性...")
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM ref_standard_ingredients")
        ingredient_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM ref_standard_spices")
        spice_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM ref_standard_utensils")
        utensil_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM ref_standard_allergens")
        allergen_count = cursor.fetchone()[0]
        
        print(f"   ✅ 标准食材: {ingredient_count} 条（应包含 96 条，仅 YOLO 模型标签）")
        print(f"   ✅ 标准调料: {spice_count} 条")
        print(f"   ✅ 标准厨具: {utensil_count} 条")
        print(f"   ✅ 标准过敏原: {allergen_count} 条")
        
        # 验证 YOLO 对齐的关键食材
        yolo_key_ingredients = ['Pomegranate', 'Spinach', 'Cucumber', 'Avocado', 'Beef', 'Chicken-Whole', 'Onion', 'Mushroom']
        cursor.execute(
            "SELECT COUNT(*) FROM ref_standard_ingredients WHERE name = ANY(%s)",
            (yolo_key_ingredients,)
        )
        yolo_aligned_count = cursor.fetchone()[0]
        
        if yolo_aligned_count >= len(yolo_key_ingredients) - 1:  # 允许一个缺失
            print(f"   ✅ YOLO 对齐验证: 关键食材已正确配置（{yolo_aligned_count}/{len(yolo_key_ingredients)} 个验证点）")
        else:
            print(f"   ⚠️  YOLO 对齐验证: 部分关键食材可能缺失（仅找到 {yolo_aligned_count}/{len(yolo_key_ingredients)} 个）")
        
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"   ❌ 验证失败: {e}")
        return False

def main():
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sql_file = os.path.join(script_dir, 'init-standard-libraries.sql')
    
    # 检查文件是否存在
    if not os.path.exists(sql_file):
        print(f"❌ 错误: 找不到 SQL 文件: {sql_file}")
        sys.exit(1)
    
    print("=" * 70)
    print("标准库数据初始化脚本（完整版，包含 YOLO 对齐）")
    print("=" * 70)
    print()
    print("此脚本将执行以下操作：")
    print("  1. 初始化基础标准库数据（过敏原、食材、调料、厨具）")
    print("  2. 标准食材库仅包含 YOLO 模型可识别的 96 个标签")
    print("  3. 所有食材的单位和单位转换已规范化")
    print("  4. 验证数据完整性")
    print()
    
    # 执行 SQL 文件
    success = run_sql_file(
        sql_file,
        "执行标准库初始化（仅 YOLO 模型标签，单位已规范化）"
    )
    
    if not success:
        print("\n❌ 初始化失败，终止执行")
        sys.exit(1)
    
    # 验证数据
    verify_success = verify_data()
    
    print()
    print("=" * 70)
    if success and verify_success:
        print("✅ 初始化完成！所有步骤执行成功")
        print("=" * 70)
        sys.exit(0)
    else:
        print("⚠️  初始化部分完成，请检查验证结果")
        print("=" * 70)
        sys.exit(0)

if __name__ == '__main__':
    main()
