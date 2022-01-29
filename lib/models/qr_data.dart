class QrData{
  final int? id;
  final String name;
  final DateTime createdAt;

  QrData({required this.createdAt, this.id, required this.name});

  factory QrData.fromMap(Map<String, dynamic> json){
    return QrData(
      id: json['id'] as int?,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
  };

}