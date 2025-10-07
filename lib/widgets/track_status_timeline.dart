import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackStatusTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> statusList;

  const TrackStatusTimeline({super.key, required this.statusList});

  String formatDate(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      final date =
          "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      final time =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      return "Updated on: $date\nTime: $time";
    } catch (_) {
      return dateTime;
    }
  }

  LinearGradient getGradient(String status) {
    switch (status.toLowerCase()) {
      case 'forwarded':
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 46, 204, 112),
            Color.fromARGB(255, 0, 192, 80),
          ], // greens
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pending':
        return const LinearGradient(
          colors: [Color(0xFFF39C12), Color(0xFFD35400)], // oranges
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rejected':
      case 'reverted':
      case 'blocked':
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 230, 83, 67),
            Color.fromARGB(255, 197, 28, 9),
          ], // reds
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF4187C5), Color(0xFF62A8E5)], // fallback blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData getIcon(String status) {
    switch (status.toLowerCase()) {
      case 'forwarded':
        return Icons.forward_to_inbox;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
      case 'blocked':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 20,
        right: 16,
        top: 12,
      ), // left side padding
      itemCount: statusList.length,
      itemBuilder: (context, index) {
        final item = statusList[index];
        final isFirst = index == 0;
        final isLast = index == statusList.length - 1;

        final dept = item['department'] ?? 'Unknown Department';
        final time = formatDate(item['created_at'] ?? '');
        final status = (item['status'] ?? '').toString();

        final gradient = getGradient(status);
        final icon = getIcon(status);

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.05, // pushes line towards left
          isFirst: isFirst,
          isLast: isLast,
          beforeLineStyle: const LineStyle(color: Colors.grey, thickness: 2),
          afterLineStyle: const LineStyle(color: Colors.grey, thickness: 2),
          indicatorStyle: IndicatorStyle(
            width: 28,
            height: 28,
            indicator: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
          ),
          endChild: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                dept,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              subtitle: Row(
                children: [
                  // const Icon(
                  //   Icons.access_time,
                  //   color: Colors.white70,
                  //   size: 16,
                  // ),
                  const SizedBox(width: 3),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.15), // subtle background
                  border: Border.all(color: Colors.white, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
