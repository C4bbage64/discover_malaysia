/// A user review for a destination
class Review {
  final String id;
  final String destinationId;
  final String userId;
  final String username;
  final String comment;
  final int rating; // 1-5
  final DateTime timestamp;

  const Review({
    required this.id,
    required this.destinationId,
    required this.userId,
    required this.username,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'userId': userId,
      'username': username,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, {String? id}) {
    return Review(
      id: id ?? '',
      destinationId: map['destinationId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'Anonymous',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 5).toInt(),
      timestamp: (map['timestamp'] is DateTime)
          ? map['timestamp']
          : (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Format timestamp as relative time (e.g., "3 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
