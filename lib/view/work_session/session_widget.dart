// lib/view/work_session/session_widget.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import 'session_create_view.dart';

class SessionWidget extends StatelessWidget {
  const SessionWidget({
    super.key,
    required this.session,
  });

  final WorkSession session;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Naviguer vers la vue d'édition
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => SessionCreateView(
              session: session,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(
                  session.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: session.isCompleted
                      ? MyColors.primaryColor
                      : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              session.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  'Travail: ${session.workDurationMinutes} min',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.coffee, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  'Pause: ${session.breakDurationMinutes} min',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}