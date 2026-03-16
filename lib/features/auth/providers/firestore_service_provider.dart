import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/features/auth/services/firestore_service.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());
