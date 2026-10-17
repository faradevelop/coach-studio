/// A target muscle, as provided by the Backend's muscles catalog.
///
/// Muscles are no longer a hardcoded Flutter enum — they are fetched from
/// the API (see `ExerciseMetaRepository`), so identity is carried by
/// [slug] (used when talking to the API) and [id] (the row's primary key).
class Muscle {
  final String id;
  final String name;
  final String slug;

  const Muscle({required this.id, required this.name, required this.slug});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Muscle && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Muscle($slug)';
}
