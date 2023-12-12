class SensorData {
  final double temperature;
  final double humidity;

  SensorData({required this.temperature, required this.humidity});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['temp'].toDouble(),
      humidity: json['humid'].toDouble(),
    );
  }
}
