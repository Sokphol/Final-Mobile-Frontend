String optimizedImageUrl(
  String url, {
  int maxWidth = 640,
  int maxQuality = 75,
}) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host != 'images.unsplash.com') return url;

  final parameters = Map<String, String>.from(uri.queryParameters);
  final currentWidth = int.tryParse(parameters['w'] ?? '');
  final currentQuality = int.tryParse(parameters['q'] ?? '');
  parameters['w'] = currentWidth == null
      ? '$maxWidth'
      : '${currentWidth < maxWidth ? currentWidth : maxWidth}';
  parameters['q'] = currentQuality == null
      ? '$maxQuality'
      : '${currentQuality < maxQuality ? currentQuality : maxQuality}';
  return uri.replace(queryParameters: parameters).toString();
}
