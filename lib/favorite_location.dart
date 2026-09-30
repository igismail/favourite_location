class FavoriteLocation {
  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;

  static const samples = <FavoriteLocation>[
    FavoriteLocation(
      id: 1,
      name: 'Khulna University',
      latitude: 22.8026,
      longitude: 89.3709,
    ),
    FavoriteLocation(
      id: 2,
      name: 'Khulna Railway Station',
      latitude: 22.8434,
      longitude: 89.5403,
    ),
    FavoriteLocation(
      id: 3,
      name: 'Shibbari More',
      latitude: 22.8167,
      longitude: 89.5501,
    ),
  ];
}
