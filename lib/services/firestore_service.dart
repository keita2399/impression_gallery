import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  /// Sign in anonymously (no account required)
  static Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  /// Get the favorites collection for the current user
  static CollectionReference<Map<String, dynamic>> _favoritesRef() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  /// Sync local favorites to Firestore
  static Future<void> syncLocalToCloud() async {
    if (_auth.currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final localIds = prefs.getStringList('favorites') ?? [];

    if (localIds.isEmpty) return;

    final batch = _firestore.batch();
    final ref = _favoritesRef();

    for (final id in localIds) {
      batch.set(ref.doc(id), {
        'artworkId': int.parse(id),
        'addedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Sync cloud favorites to local
  static Future<void> syncCloudToLocal() async {
    if (_auth.currentUser == null) return;

    final snapshot = await _favoritesRef().get();
    final cloudIds = snapshot.docs.map((d) => d.id).toSet();

    final prefs = await SharedPreferences.getInstance();
    final localIds = (prefs.getStringList('favorites') ?? []).toSet();

    // Merge: keep both local and cloud
    final merged = localIds.union(cloudIds);
    await prefs.setStringList('favorites', merged.toList());
  }

  /// Add a favorite
  static Future<void> addFavorite(int artworkId) async {
    // Save locally
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList('favorites') ?? []).toSet();
    ids.add(artworkId.toString());
    await prefs.setStringList('favorites', ids.toList());

    // Save to cloud
    if (_auth.currentUser != null) {
      await _favoritesRef().doc(artworkId.toString()).set({
        'artworkId': artworkId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Remove a favorite
  static Future<void> removeFavorite(int artworkId) async {
    // Remove locally
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList('favorites') ?? []).toSet();
    ids.remove(artworkId.toString());
    await prefs.setStringList('favorites', ids.toList());

    // Remove from cloud
    if (_auth.currentUser != null) {
      await _favoritesRef().doc(artworkId.toString()).delete();
    }
  }

  /// Toggle a favorite (returns new state)
  static Future<bool> toggleFavorite(int artworkId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList('favorites') ?? []).toSet();

    if (ids.contains(artworkId.toString())) {
      await removeFavorite(artworkId);
      return false;
    } else {
      await addFavorite(artworkId);
      return true;
    }
  }

  /// Get all favorite IDs
  static Future<Set<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    return ids.map((s) => int.parse(s)).toSet();
  }

  /// Check if an artwork is favorited
  static Future<bool> isFavorite(int artworkId) async {
    final ids = await getFavoriteIds();
    return ids.contains(artworkId);
  }
}
