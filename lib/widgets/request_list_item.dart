import 'package:flutter/material.dart';
import 'package:nesysworks/models/request_item.dart';

class RequestListItem extends StatelessWidget {
  final RequestItem item;
  final String distanceDisplay;
  final bool isFullyJoined;
  final VoidCallback onJoin;

  const RequestListItem({
    required this.item,
    required this.distanceDisplay,
    required this.isFullyJoined,
    required this.onJoin,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('차량 번호: ${item.vehicleNumber}'),
                const SizedBox(height: 4),
                Text(
                  '위치: ${item.location}',
                ),
                const SizedBox(height: 4),
                Text(
                  '상황: ${item.situation}',
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  distanceDisplay,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isFullyJoined ? null : onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFullyJoined ? Colors.grey : Colors.blue,
                  ),
                  child: Text(
                    isFullyJoined
                        ? '마감됨'
                        : '${item.joinedWorkers}/${item.workers} 참여',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}