class ImageConstants {
  static ImageConstants? _instance;

  static ImageConstants get instance => _instance ??= ImageConstants._init();

  ImageConstants._init();

  String get logo => toPng('logo');

  String get projeIcon => toPng('mcl_circle');
  String toPng(String name) => 'assets/images/$name.png';
}
