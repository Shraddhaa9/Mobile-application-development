class WeatherAlert {
  final String event;
  final String description;

  WeatherAlert({
    required this.event,
    required this.description,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      event: json['event'],
      description: json['description'],
    );
  }
}