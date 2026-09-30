// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:favourite_location/favorite_location.dart';

void main() {
  test('provides three favorite locations with stable coordinates', () {
    expect(FavoriteLocation.samples, hasLength(3));
    expect(FavoriteLocation.samples.first.id, 1);
    expect(FavoriteLocation.samples.first.name, 'Khulna University');
    expect(FavoriteLocation.samples.first.latitude, 22.8026);
    expect(FavoriteLocation.samples.first.longitude, 89.3709);
    expect(
      FavoriteLocation.samples.map((location) => location.name),
      containsAll(['Khulna Railway Station', 'Shibbari More']),
    );
  });
}
