import 'package:flutter/material.dart';
import 'package:temple/utils/colors.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({Key? key, this.message = 'No items', this.icon = Icons.inbox}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.disabledColor ?? Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class EmptyState extends StatelessWidget {
//   final String title;
//   final String message;
//   final IconData icon;

//   const EmptyState({Key? key, this.title = 'Nothing here', this.message = '', this.icon = Icons.inbox}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 72, color: Theme.of(context).disabledColor),
//           const SizedBox(height: 12),
//           Text(title, style: Theme.of(context).textTheme.headline6),
//           if (message.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2),
//           ]
//         ],
//       ),
//     );
//   }
// }
