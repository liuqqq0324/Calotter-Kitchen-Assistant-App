import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final double initialValue; // 🔥 改为 double 支持小数
  final String unit;
  final Function(double) onChanged; // 🔥 改为 double

  // 🔥 新增参数：单位选择相关
  final List<String>? unitOptions; // 如果为 null，就是不可选模式
  final Function(String)? onUnitChanged;

  // 🔥 新增参数：宽度控制 (默认 70，编辑页可以传大一点)
  final double totalWidth;

  const QuantitySelector({
    super.key,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
    this.unitOptions,
    this.onUnitChanged,
    this.totalWidth = 70.0, // 默认紧凑宽度
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late TextEditingController _controller;
  late double _currentValue; // 🔥 改为 double
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: _formatNumber(_currentValue));
  }

  @override
  void didUpdateWidget(QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.initialValue - widget.initialValue).abs() > 0.001) { // 🔥 使用小数比较
      _currentValue = widget.initialValue;
      if (!_isTyping && _controller.text != _formatNumber(_currentValue)) {
        _controller.text = _formatNumber(_currentValue);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double number) {
    // 🔥 特殊处理：0 < number < 1 时显示 "< 1"
    if (number > 0 && number < 1) {
      return '< 1';
    }
    
    // 整数部分
    int intPart = number.floor();
    
    if (intPart >= 1000000)
      return '${(intPart / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    if (intPart >= 1000)
      return '${(intPart / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    return intPart.toString();
  }
  
  // 🔥 判断是否需要显示指示器（0 < quantity < 1）
  bool get _showIndicator => _currentValue > 0 && _currentValue < 1;

  void _updateValue(double newValue) {
    if (newValue < 0) return; // 🔥 允许小数，但不允许负数
    _isTyping = false;
    setState(() {
      _currentValue = newValue;
      _controller.text = _formatNumber(newValue);
    });
    widget.onChanged(newValue);
  }

  void _handleInput(String val) {
    _isTyping = false;
    double? newValue = double.tryParse(val); // 🔥 改为 double
    if (newValue != null && newValue >= 0) { // 🔥 允许小数和0
      _updateValue(newValue);
    } else {
      _controller.text = _formatNumber(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMin = _currentValue <= 0; // 🔥 改为 <= 0

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. 减号
        _buildBtn(
          icon: Icons.remove,
          color: isMin ? Colors.grey.shade300 : Colors.orange,
          onTap: isMin ? () {} : () => _updateValue((_currentValue - 1).clamp(0.0, double.infinity)), // 🔥 支持小数
        ),

        const SizedBox(width: 6),

        // 2. 中间容器 (宽度由参数控制)
        Container(
          width: widget.totalWidth, // 🔥 使用传入的宽度
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // 数字输入框 + 指示器
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), // 🔥 允许小数输入
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () {
                          _isTyping = true;
                          _controller.text = _currentValue.toString();
                        },
                        onSubmitted: (val) => _handleInput(val),
                        onTapOutside: (_) {
                          if (_isTyping) {
                            _handleInput(_controller.text);
                            FocusScope.of(context).unfocus();
                          }
                        },
                        onChanged: (val) {
                          _isTyping = true;
                          double? valDouble = double.tryParse(val); // 🔥 改为 double
                          if (valDouble != null && valDouble >= 0) {
                            _currentValue = valDouble;
                            widget.onChanged(valDouble);
                          }
                        },
                      ),
                    ),
                    // 🔥 指示器：当 0 < quantity < 1 时显示小红点
                    if (_showIndicator)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 分割线
              Container(width: 1, height: 14, color: Colors.grey.shade300),

              // 🔥 核心升级：单位显示区
              _buildUnitWidget(),
            ],
          ),
        ),

        const SizedBox(width: 6),

        // 3. 加号
        _buildBtn(
          icon: Icons.add,
          color: Colors.orange,
          onTap: () => _updateValue(_currentValue + 1),
        ),
      ],
    );
  }

  // 🔥 新增：构建单位部分的逻辑
  Widget _buildUnitWidget() {
    // 如果没有提供选项，就显示普通文本 (列表页模式)
    if (widget.unitOptions == null || widget.onUnitChanged == null) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 35),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          widget.unit,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    // 如果有选项，显示弹出菜单 (编辑页模式)
    return PopupMenuButton<String>(
      initialValue: widget.unit,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(maxHeight: 300), // 限制菜单高度
      tooltip: "Select Unit",
      onSelected: widget.onUnitChanged, // 回调
      itemBuilder: (context) {
        return widget.unitOptions!.map((String u) {
          return PopupMenuItem<String>(
            value: u,
            height: 32,
            child: Text(u, style: const TextStyle(fontSize: 14)),
          );
        }).toList();
      },
      // 按钮长什么样
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            // 单位文字
            Container(
              constraints: const BoxConstraints(maxWidth: 40), // 稍微宽一点点
              child: Text(
                widget.unit,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.orange, // 🔥 变橙色，暗示可点击
                  // decoration: TextDecoration.underline, // 加下划线
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ),
            // 小小箭头
            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
