import 'package:flutter/material.dart';

class NavTile extends StatelessWidget {
  const NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary.withOpacity(0.10)
        : Colors.transparent;
    final fg = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w700 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
