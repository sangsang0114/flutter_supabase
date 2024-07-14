// board/model/image.dart
class Image {
  final int id;
  final String serviceName;
  final int serviceId;
  final String originalUrl;
  final String thumbUrl;
  final Map<String, dynamic> exifData;
  final DateTime createdAt;

  Image({
    required this.id,
    required this.serviceName,
    required this.serviceId,
    required this.originalUrl,
    required this.thumbUrl,
    required this.exifData,
    required this.createdAt,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'],
      serviceName: json['service_name'],
      serviceId: json['service_id'],
      originalUrl: json['original_url'],
      thumbUrl: json['thumb_url'],
      exifData: json['exif_data'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
