#!/bin/bash
# 训练监控脚本 - 检查 Pasta 数据集训练是否完成

echo "=== 训练状态检查 ==="
echo ""

# 检查训练进程
PROCESS=$(ps aux | grep "train.py.*Pasta" | grep -v grep)
if [ -z "$PROCESS" ]; then
    echo "❌ 训练进程未运行"
    echo ""
    echo "检查训练结果..."
    
    # 检查结果文件
    if [ -f "runs/detect/train/results.csv" ]; then
        echo "✅ 训练已完成！"
        echo ""
        echo "=== 最终结果 ==="
        tail -1 runs/detect/train/results.csv | awk -F',' '{
            printf "Epoch: %s\n", $1
            printf "mAP50: %s\n", $8
            printf "mAP50-95: %s\n", $9
            printf "Precision: %s\n", $5
            printf "Recall: %s\n", $6
        }'
        echo ""
        echo "模型文件位置："
        ls -lh runs/detect/train/weights/*.pt 2>/dev/null || echo "模型文件未找到"
    else
        echo "⚠️  训练可能未正常完成（结果文件不存在）"
    fi
else
    echo "✅ 训练正在进行中..."
    echo ""
    echo "$PROCESS" | awk '{print "进程ID:", $2, "| CPU:", $3"%", "| 内存:", $4"%"}'
    echo ""
    
    # 显示当前进度（如果有结果文件）
    if [ -f "runs/detect/train/results.csv" ]; then
        echo "=== 当前进度 ==="
        tail -1 runs/detect/train/results.csv | awk -F',' '{
            printf "已完成 Epoch: %s / 50\n", $1
            printf "当前 mAP50: %s\n", $8
            printf "当前 mAP50-95: %s\n", $9
        }'
    else
        echo "训练刚开始，结果文件尚未生成..."
    fi
fi

echo ""
echo "=== 训练信息 ==="
if [ -f "runs/detect/train/args.yaml" ]; then
    grep -E "data:|epochs:|batch:" runs/detect/train/args.yaml | head -3
fi

