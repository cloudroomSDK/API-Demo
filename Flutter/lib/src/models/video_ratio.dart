class VideoRatio {
  int width;
  int height;
  double maxkbps;

  String get text => "${height.toInt()}P";
  double get minkbps => maxkbps / 4;
  double get initbps => minkbps + ((maxkbps - minkbps) / 2);

  VideoRatio(this.height, this.width, this.maxkbps);
}
