import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/event_provider.dart';
import '../widgets/analytics_card.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final events = eventProvider.allEvents;

        // Calculate stats
        final categoryCounts = <String, int>{};
        for (var event in events) {
          categoryCounts[event.category] =
              (categoryCounts[event.category] ?? 0) + 1;
        }

        final totalAttendees = events.fold<int>(
          0,
          (sum, e) => sum + e.goingCount,
        );
        final totalInterested = events.fold<int>(
          0,
          (sum, e) => sum + e.interestedCount,
        );
        final cancelledCount = events.where((e) => e.isCancelled).length;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Analytics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Total Attendees',
                      value: totalAttendees.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Interested',
                      value: totalInterested.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Cancelled',
                      value: cancelledCount.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Events by Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: categoryCounts.length,
                  itemBuilder: (context, index) {
                    final category = categoryCounts.keys.elementAt(index);
                    final count = categoryCounts[category]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 100, child: Text(category)),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: count / events.length,
                                minHeight: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$count'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
