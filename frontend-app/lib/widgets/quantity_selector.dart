import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final String unit;
  final Function(int) onChanged;

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
  late int _currentValue;
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
    if (oldWidget.initialValue != widget.initialValue) {
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

  String _formatNumber(int number) {
    if (number >= 1000000)
      return '${(number / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    if (number >= 1000)
      return '${(number / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    return number.toString();
  }

  void _updateValue(int newValue) {
    if (newValue < 1) return;
    _isTyping = false;
    setState(() {
      _currentValue = newValue;
      _controller.text = _formatNumber(newValue);
    });
    widget.onChanged(newValue);
  }

  void _handleInput(String val) {
    _isTyping = false;
    int? newValue = int.tryParse(val);
    if (newValue != null && newValue >= 1) {
      _updateValue(newValue);
    } else {
      _controller.text = _formatNumber(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMin = _currentValue <= 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. 减号
        _buildBtn(
          icon: Icons.remove,
          color: isMin ? Colors.grey.shade300 : Colors.orange,
          onTap: isMin ? () {} : () => _updateValue(_currentValue - 1),
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
              // 数字输入框
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
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
                    int? valInt = int.tryParse(val);
                    if (valInt != null) {
                      _currentValue = valInt;
                      widget.onChanged(valInt);
                    }
                  },
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
