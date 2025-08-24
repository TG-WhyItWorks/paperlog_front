import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/notification_viewmodel.dart';
import '../../../core/models/notification_model.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();

    return Builder(
      builder: (btnContext) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                //아이콘 위치를 기준으로 컨텍스트 메뉴 표시
                final RenderBox button =
                    btnContext.findRenderObject() as RenderBox;
                final overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final pos = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(
                      button.size.bottomRight(Offset.zero),
                      ancestor: overlay,
                    ),
                  ),
                  Offset.zero & overlay.size,
                );

                // showMenu 호출
                showMenu<NotificationModel>(
                  context: btnContext,
                  position: pos.shift(const Offset(0, 40)),
                  items: vm.notifications.map((n) {
                    return PopupMenuItem<NotificationModel>(
                      value: n,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          n.title,
                          style: n.read
                              ? Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                )
                              : Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                        subtitle: Text(
                          n.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${n.date.month}/${n.date.day}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        tileColor: n.read
                            ? Theme.of(context).dividerColor.withOpacity(0.05)
                            : null,
                      ),
                    );
                  }).toList(),
                  color: Theme.of(context).cardColor,
                  elevation: 4,
                ).then((value) {
                  if (value != null && !value.read) {
                    vm.markRead(value.id);
                  }
                });
              },
            ),
            if (vm.hasUnread)
              Positioned(
                right: 6,
                top: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 8, height: 8),
                ),
              ),
          ],
        );
      },
    );
  }
}
