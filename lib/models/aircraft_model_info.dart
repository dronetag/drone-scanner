class AircraftModelInfo {
  final String maker;
  final String? model;

  AircraftModelInfo({required this.model, required this.maker});

  factory AircraftModelInfo.fromJson(Map<String, dynamic> json) =>
      AircraftModelInfo(
        maker: json['maker'] as String,
        model: json['model'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'maker': maker,
        'model': model,
      };
}
