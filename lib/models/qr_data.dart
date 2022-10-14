class QrData {
  final int? id;
  final String name;
  final int isUrl;
  final String createdAt;

  QrData(
      {required this.createdAt,
      required this.isUrl,
      this.id,
      required this.name});

  factory QrData.fromMap(Map<String, dynamic> json) {
    return QrData(
      id: json['id'] as int?,
      name: json['name'] as String,
      createdAt: json['date'] as String,
      isUrl: json['isUrl'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'date': createdAt,
        'isUrl': isUrl,
      };
}
