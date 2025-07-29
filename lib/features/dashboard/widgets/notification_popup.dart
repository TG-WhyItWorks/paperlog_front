import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/notification_viewmodel.dart';

class NotificationPopup extends StatelessWidget {
  const NotificationPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();

    return Dialog(
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text('알림', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: vm.markAllRead,
                    child: const Text('모두 읽음'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            //알림 목록
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: vm.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = vm.notifications[i];
                  return ListTile(
                    tileColor: n.read
                        ? Theme.of(context).dividerColor.withOpacity(0.1)
                        : null,
                    title: Text(
                      n.title,
                      style: n.read
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                    subtitle: Text(n.subtitle),
                    trailing: Text(
                      '${n.date.month}/${n.date.day}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => vm.markRead(n.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
