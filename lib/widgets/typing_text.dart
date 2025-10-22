import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final TextAlign textAlign;
  final VoidCallback? onComplete;
  final bool autoStart;
  
  const TypingText(
    this.text, {
    super.key,
    this.duration = const Duration(milliseconds: 50),
    this.style,
    this.textAlign = TextAlign.left,
    this.onComplete,
    this.autoStart = true,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * widget.duration.inMilliseconds),
      vsync: this,
    );
    
    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.autoStart) {
      _startTyping();
    }
  }
  
  void _startTyping() {
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final visibleText = widget.text.substring(0, _animation.value);
        final remainingText = widget.text.substring(_animation.value);
        
        return RichText(
          textAlign: widget.textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: visibleText,
                style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
              ),
              if (remainingText.isNotEmpty)
                TextSpan(
                  text: remainingText,
                  style: (widget.style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
                    color: Colors.transparent,
                  ),
                ),
              if (_animation.value < widget.text.length)
                TextSpan(
                  text: '|',
                  style: (widget.style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  void startTyping() {
    if (!_controller.isAnimating) {
      _startTyping();
    }
  }
  
  void stopTyping() {
    _controller.stop();
  }
  
  void resetTyping() {
    _controller.reset();
  }
}
