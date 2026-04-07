import 'package:flutter/material.dart';
import '../services/custom_contacts_provider.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final Color onSurface;
  const SectionLabel({super.key, required this.label, required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}

class EmergencyCard extends StatelessWidget {
  final Widget child;
  final Color bg;
  final List<BoxShadow> shadows;
  const EmergencyCard({super.key, required this.child, required this.bg, required this.shadows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

class ServiceDivider extends StatelessWidget {
  final Color onSurface;
  const ServiceDivider({super.key, required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 20, color: onSurface.withValues(alpha: 0.08));
  }
}

class ServiceSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> numbers;
  final Color iconColor;
  final Future<void> Function(String) onCall;
  final Color onSurface;

  const ServiceSection({
    super.key,
    required this.icon,
    required this.label,
    required this.numbers,
    required this.iconColor,
    required this.onCall,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveNumbers = numbers.isEmpty
        ? <String>['Not available']
        : numbers;
    final bool unavailable =
        numbers.isEmpty ||
        (numbers.length == 1 && numbers.first == 'Not available');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            if (effectiveNumbers.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${effectiveNumbers.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        ...effectiveNumbers.map(
          (number) => Padding(
            padding: const EdgeInsets.only(top: 10, left: 4),
            child: Row(
              children: [
                const SizedBox(width: 38), 
                Expanded(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 15,
                      color: unavailable
                          ? onSurface.withValues(alpha: 0.35)
                          : onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                if (!unavailable)
                  BounceButton(
                    onTap: () => onCall(number),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call_rounded,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomContactRow extends StatelessWidget {
  final CustomContact contact;
  final bool showCategory;
  final Future<void> Function(String) onCall;
  final Color onSurface;
  final Color primary;

  const CustomContactRow({
    super.key,
    required this.contact,
    required this.showCategory,
    required this.onCall,
    required this.onSurface,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_rounded, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showCategory && contact.category.isNotEmpty)
                  Text(
                    contact.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Text(
                  contact.phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          BounceButton(
            onTap: () => onCall(contact.phone),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.call_rounded,
                color: primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType inputType;

  const SheetField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ─── Animations ──────────────────────────────────────────────────────────────

class JigglingTrashIcon extends StatefulWidget {
  final Color color;
  const JigglingTrashIcon({super.key, required this.color});

  @override
  State<JigglingTrashIcon> createState() => _JigglingTrashIconState();
}

class _JigglingTrashIconState extends State<JigglingTrashIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Rotate back and forth between -0.1 and 0.1 radians
        final angle = -0.1 + (0.2 * _controller.value);
        return Transform.rotate(
          angle: angle,
          child: Icon(Icons.delete_rounded, color: widget.color),
        );
      },
    );
  }
}

class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BounceButton({super.key, required this.child, required this.onTap});

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: widget.child,
        ),
      ),
    );
  }
}

