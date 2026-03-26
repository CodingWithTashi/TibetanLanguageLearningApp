import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/application_util.dart';

/// Toggle switch between Free Draw and Guided Trace modes
class TraceModeToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const TraceModeToggle({
    Key? key,
    this.initialValue = false,
    this.onChanged,
  }) : super(key: key);

  @override
  State<TraceModeToggle> createState() => _TraceModeToggleState();
}

class _TraceModeToggleState extends State<TraceModeToggle>
    with SingleTickerProviderStateMixin {
  late bool _isTraceMode;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _isTraceMode = widget.initialValue;
    _loadModePreference();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.blue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_isTraceMode) {
      _animationController.value = 1.0;
    }
  }

  Future<void> _loadModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getBool('trace_mode') ?? false;
    if (mounted) {
      setState(() {
        _isTraceMode = savedMode;
        if (_isTraceMode) {
          _animationController.value = 1.0;
        }
      });
    }
  }

  Future<void> _saveModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trace_mode', value);
  }

  void _toggleMode() {
    setState(() {
      _isTraceMode = !_isTraceMode;
      if (_isTraceMode) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      widget.onChanged?.call(_isTraceMode);
      _saveModePreference(_isTraceMode);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ApplicationUtil.getBoxDecorationTwo(context),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeLabel(
            label: 'Free Draw',
            isSelected: !_isTraceMode,
            onTap: () {
              if (_isTraceMode) _toggleMode();
            },
          ),
          const SizedBox(width: 8),
          _buildToggle(),
          const SizedBox(width: 8),
          _buildModeLabel(
            label: 'Guided Trace',
            isSelected: _isTraceMode,
            onTap: () {
              if (!_isTraceMode) _toggleMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeLabel({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: isSelected ? 14 : 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildToggle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _toggleMode,
          child: Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isTraceMode ? 28 : 4,
                  right: _isTraceMode ? 4 : 28,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colorAnimation.value ?? Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_colorAnimation.value ?? Colors.grey).withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Simple inline toggle for compact display
class InlineTraceModeToggle extends StatefulWidget {
  final bool isTraceMode;
  final ValueChanged<bool>? onChanged;

  const InlineTraceModeToggle({
    Key? key,
    required this.isTraceMode,
    this.onChanged,
  }) : super(key: key);

  @override
  State<InlineTraceModeToggle> createState() => _InlineTraceModeToggleState();
}

class _InlineTraceModeToggleState extends State<InlineTraceModeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    if (widget.isTraceMode) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(InlineTraceModeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTraceMode != oldWidget.isTraceMode) {
      if (widget.isTraceMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged?.call(!widget.isTraceMode);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isTraceMode
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isTraceMode
                ? Theme.of(context).primaryColor
                : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isTraceMode ? Icons.edit_road_rounded : Icons.edit,
              size: 16,
              color: widget.isTraceMode
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              widget.isTraceMode ? 'Guided' : 'Free',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.isTraceMode
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
