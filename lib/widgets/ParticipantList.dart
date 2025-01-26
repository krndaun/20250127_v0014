import 'package:flutter/material.dart';

class ParticipantList extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  const ParticipantList({Key? key, required this.participants}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] ParticipantList 데이터: $participants');

    if (participants.isEmpty) {
      return Center(
        child: Text(
          '참여자가 없습니다.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final name = participant['name'] ?? '알 수 없음';
        final distance = participant['distance'] ?? double.infinity;
        final distanceDisplay = distance <= 0.5
            ? '거리: ${(distance * 1000).toStringAsFixed(0)}m'
            : '거리 초과: ${(distance * 1000).toStringAsFixed(0)}m';

        return ListTile(
          title: Text(name),
          subtitle: Text(distanceDisplay),
          trailing: distance <= 0.5
              ? Icon(Icons.check_circle, color: Colors.green)
              : Icon(Icons.warning, color: Colors.red),
        );
      },
    );
  }
}