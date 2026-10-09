import 'package:intl/intl.dart';

class Formatters {
  static String formatBytes(num bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    int i = (bytes > 0 ? (bytes.toString().length - 1) ~/ 3 : 0);
    if (i >= suffixes.length) i = suffixes.length - 1;
    double count = bytes / (1 << (i * 10));
    return '${count.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String formatBandwidth(num bytesPerSecond) {
    return '${formatBytes(bytesPerSecond)}/s';
  }

  static String formatPercentage(double value, [int decimals = 1]) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  static String formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  static String formatUptime(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
