import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/app_style.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_border.dart';

class QuantitySelector extends StatefulWidget {
  final double initialValue; // 🔥 改为 double 支持小数
  final String unit;
  final Function(double) onChanged; // 🔥 改为 double

  // 🔥 新增参数：单位选择相关
  final List<String>? unitOptions; // 如果为 null，就是不可选模式
  final Function(String)? onUnitChanged;

  // 🔥 新增参数：宽度控制 (默认 70，编辑页可以传大一点)
  final double totalWidth;

  /// 为 true 时，+/- 按钮使用方形 + sketchy_button 手绘风格
  final bool useSketchySquareButtons;

  const QuantitySelector({
    super.key,
    required this.initialValue,
    required this.unit,
    required this.onChanged,
    this.unitOptions,
    this.onUnitChanged,
    this.totalWidth = 70.0, // 默认紧凑宽度
    this.useSketchySquareButtons = false,
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
    // ✅ 当数值变化或单位变化时，更新显示
    if ((oldWidget.initialValue - widget.initialValue).abs() > 0.001 ||
        oldWidget.unit != widget.unit) {
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
    // ✅ 特殊处理：只有当单位为 pcs 时，0 < number < 1 才显示 "< 1"
    // 其他单位显示两位小数
    if (number > 0 && number < 1) {
      if (widget.unit.toLowerCase() == 'pcs') {
        return '< 1';
      } else {
        // 非 pcs 单位，显示两位小数
        return number.toStringAsFixed(2);
      }
    }

    // 整数部分
    int intPart = number.floor();

    if (intPart >= 1000000)
      return '${(intPart / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    if (intPart >= 1000)
      return '${(intPart / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';

    // ✅ 如果单位不是 pcs，且数字有小数部分，显示两位小数
    if (widget.unit.toLowerCase() != 'pcs' && number != intPart) {
      return number.toStringAsFixed(2);
    }

    return intPart.toString();
  }

  // ✅ 判断是否需要显示指示器（只有当单位为 pcs 时，0 < quantity < 1 才显示红点）
  bool get _showIndicator =>
      widget.unit.toLowerCase() == 'pcs' &&
      _currentValue > 0 &&
      _currentValue < 1;

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
    if (newValue != null && newValue >= 0) {
      // 🔥 允许小数和0
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
      crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 1. 减号
        widget.useSketchySquareButtons
            ? _buildSketchySquareBtn(
                icon: Icons.remove,
                color: isMin ? Colors.grey.shade300 : AppStyle.accentColor,
                onTap: isMin
                    ? () {}
                    : () => _updateValue(
                        (_currentValue - 1).clamp(0.0, double.infinity),
                      ),
              )
            : _buildCircleBtn(
                icon: Icons.remove,
                color: isMin ? Colors.grey.shade300 : AppStyle.accentColor,
                onTap: isMin
                    ? () {}
                    : () => _updateValue(
                        (_currentValue - 1).clamp(0.0, double.infinity),
                      ),
              ),

        const SizedBox(width: 6),

        // 2. 中间输入框 (SketchyBorder 手绘风格)
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.totalWidth,
              minWidth: 45,
            ),
            child: SketchyBorder(
              borderColor: AppStyle.inputBorderColor,
              borderWidth: 2.0,
              backgroundColor: Colors.white,
              borderRadius: 8.0,
              roughness: 3.0,
              child: SizedBox(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: TextField(
                              controller: _controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ), // 🔥 允许小数输入
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppStyle.inkColorDark, // 深棕色字
                                // fontFamily: 'Patrick Hand', // 记得加手写字体
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  bottom: 2,
                                ), // 微调文字位置
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
                                double? valDouble = double.tryParse(
                                  val,
                                ); // 🔥 改为 double
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
                    // 单位显示 (简化版，去掉分割线)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildUnitWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        // 3. 加号
        widget.useSketchySquareButtons
            ? _buildSketchySquareBtn(
                icon: Icons.add,
                color: AppStyle.accentColor,
                onTap: () => _updateValue(_currentValue + 1),
              )
            : _buildCircleBtn(
                icon: Icons.add,
                color: AppStyle.accentColor,
                onTap: () => _updateValue(_currentValue + 1),
              ),
      ],
    );
  }

  /// 方形 + sketchy_button 手绘风格的 +/- 按钮
  Widget _buildSketchySquareBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return _SketchySquareIconButton(
      icon: icon,
      onPressed: onTap,
      backgroundColor: color,
      size: 28.0,
    );
  }

  // 🔥 新增：构建单位部分的逻辑
  Widget _buildUnitWidget() {
    // 如果没有提供选项，就显示普通文本 (列表页模式)
    if (widget.unitOptions == null || widget.onUnitChanged == null) {
      return Text(
        widget.unit,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 单位文字
          Text(
            widget.unit,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppStyle.accentColor, // 暖橙色，暗示可点击
              fontWeight: FontWeight.w500,
            ),
          ),
          // 小小箭头
          const Icon(
            Icons.arrow_drop_down,
            size: 14,
            color: AppStyle.accentColor,
          ),
        ],
      ),
    );
  }

  /// 构建圆形按钮（原视觉风格）
  Widget _buildCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                offset: const Offset(1, 2),
                blurRadius: 3,
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

/// 方形手绘风格图标按钮（与 sketchy_button 外观一致，borderRadius 小则为方形）
class _SketchySquareIconButton extends StatefulWidget {
  static const double _borderWidth = 2.5;
  static const double _borderRadius = 8.0;

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double size;

  const _SketchySquareIconButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    this.size = 28.0,
  });

  @override
  State<_SketchySquareIconButton> createState() =>
      _SketchySquareIconButtonState();
}

class _SketchySquareIconButtonState extends State<_SketchySquareIconButton> {
  bool _pressed = false;

  Color _darken(Color c, [double amount = 0.12]) {
    return Color.lerp(c, Colors.black, amount) ?? c;
  }

  @override
  Widget build(BuildContext context) {
    final baseBg = widget.backgroundColor;
    final pressedBg = _darken(baseBg);
    const iconColor = Colors.white;

    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      tween: ColorTween(end: _pressed ? pressedBg : baseBg),
      builder: (context, bg, _) {
        return SketchyBorder(
          borderColor: Colors.black87,
          borderWidth: _SketchySquareIconButton._borderWidth,
          backgroundColor: bg ?? baseBg,
          borderRadius: _SketchySquareIconButton._borderRadius,
          roughness: 3.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              borderRadius: BorderRadius.circular(
                _SketchySquareIconButton._borderRadius,
              ),
              child: Container(
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  color: iconColor,
                  size: widget.size * 0.55,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
