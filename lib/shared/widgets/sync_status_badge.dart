import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// SyncStatusBadge — Pulsing dot + status label pill.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    super.key,
    required this.isOnline,
    required this.isSyncing,
  });

  final bool isOnline;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusText;

    if (!isOnline) {
      statusColor = const Color(0xFFC2445B);
      statusText = 'Offline';
    } else if (isSyncing) {
      statusColor = const Color(0xFFD4A574);
      statusText = 'Syncing…';
    } else {
      statusColor = const Color(0xFF7B9971);
      statusText = 'Synced';
    }

    // ConstrainedBox caps the badge width so it never pushes the AppBar title
    // into overflow — "Syncing…" is the widest label at ~80px.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 90),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 0.8,
                  end: 1.2,
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                )
                .boxShadow(
                  begin: const BoxShadow(blurRadius: 0),
                  end: BoxShadow(
                    blurRadius: 4,
                    color: statusColor.withValues(alpha: 0.4),
                  ),
                ),

            const SizedBox(width: 6),

            Flexible(
              child: Text(
                statusText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
