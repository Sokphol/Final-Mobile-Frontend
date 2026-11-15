import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/utils/image_url.dart';

void main() {
  test('caps oversized Unsplash image requests for product cards', () {
    final optimized = Uri.parse(
      optimizedImageUrl(
        'https://images.unsplash.com/photo-example?auto=format&fit=crop&w=1200&q=85',
      ),
    );

    expect(optimized.queryParameters['w'], '640');
    expect(optimized.queryParameters['q'], '75');
    expect(optimized.queryParameters['fit'], 'crop');
  });

  test('does not increase image dimensions or quality', () {
    final optimized = Uri.parse(
      optimizedImageUrl('https://images.unsplash.com/photo-example?w=320&q=60'),
    );

    expect(optimized.queryParameters['w'], '320');
    expect(optimized.queryParameters['q'], '60');
  });

  test('leaves images from other hosts unchanged', () {
    const url = 'https://cdn.example.com/headphones.jpg?w=1200';

    expect(optimizedImageUrl(url), url);
  });
}
