import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'admin_shell.dart';

// ─────────────────────────────────────────────────────────────
// Admin API Screen
// Documents every Firebase/Firestore API endpoint the app uses,
// with request format, response structure, and error codes.
// ─────────────────────────────────────────────────────────────
class AdminApiScreen extends StatefulWidget {
  const AdminApiScreen({super.key});

  @override
  State<AdminApiScreen> createState() => _AdminApiScreenState();
}

class _AdminApiScreenState extends State<AdminApiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AdminAppBar(title: '🔌 API Information'),
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search endpoints...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  borderSide: BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  borderSide: BorderSide(color: AppTheme.divider),
                ),
                filled: true,
                fillColor: AppTheme.background,
              ),
            ),
          ),
          // ── Tabs ────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textLight,
              indicatorColor: AppTheme.primary,
              tabs: const [
                Tab(text: 'Auth'),
                Tab(text: 'Firestore'),
                Tab(text: 'Firebase'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EndpointList(
                  endpoints: _authEndpoints
                      .where((e) =>
                          _searchQuery.isEmpty ||
                          e.title.toLowerCase().contains(_searchQuery) ||
                          e.method.toLowerCase().contains(_searchQuery))
                      .toList(),
                ),
                _EndpointList(
                  endpoints: _firestoreEndpoints
                      .where((e) =>
                          _searchQuery.isEmpty ||
                          e.title.toLowerCase().contains(_searchQuery) ||
                          e.path.toLowerCase().contains(_searchQuery))
                      .toList(),
                ),
                _EndpointList(
                  endpoints: _otherEndpoints
                      .where((e) =>
                          _searchQuery.isEmpty ||
                          e.title.toLowerCase().contains(_searchQuery))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Endpoint definitions
// ─────────────────────────────────────────────────────────────
const _authEndpoints = [
  _ApiEndpoint(
    title: 'Register (Email/Password)',
    method: 'POST',
    path: 'FirebaseAuth.createUserWithEmailAndPassword()',
    description:
        'Creates a new Firebase Auth user and a Firestore profile document.',
    requestBody: '{ email: String, password: String }',
    responseBody: 'UserCredential → uid, email, displayName',
    errors: ['email-already-in-use', 'weak-password', 'invalid-email'],
    color: Color(0xFF22C55E),
  ),
  _ApiEndpoint(
    title: 'Login (Email/Password)',
    method: 'POST',
    path: 'FirebaseAuth.signInWithEmailAndPassword()',
    description: 'Signs in a user. Returns UserModel fetched from Firestore.',
    requestBody: '{ email: String, password: String }',
    responseBody: 'UserCredential → UserModel from /users/{uid}',
    errors: ['user-not-found', 'wrong-password', 'invalid-credential', 'too-many-requests'],
    color: Color(0xFF22C55E),
  ),
  _ApiEndpoint(
    title: 'Google Sign In',
    method: 'POST',
    path: 'GoogleSignIn.signIn() → FirebaseAuth.signInWithCredential()',
    description:
        'OAuth2 Google sign-in. Creates Firestore profile on first login.',
    requestBody: 'GoogleSignInAccount (popup/intent)',
    responseBody: 'OAuthCredential → UserCredential → UserModel',
    errors: ['cancelled', 'network-error', 'sign-in-failed'],
    color: Color(0xFF22C55E),
  ),
  _ApiEndpoint(
    title: 'Send Password Reset',
    method: 'POST',
    path: 'FirebaseAuth.sendPasswordResetEmail()',
    description:
        'Sends a reset link to the provided email. Silent if email not found.',
    requestBody: '{ email: String }',
    responseBody: 'void (email sent)',
    errors: ['invalid-email', 'network-request-failed'],
    color: Color(0xFFF59E0B),
  ),
  _ApiEndpoint(
    title: 'Update Profile',
    method: 'PATCH',
    path: 'FirebaseAuth.updateDisplayName() + Firestore.update()',
    description: 'Updates display name in Auth and user fields in Firestore.',
    requestBody: '{ uid, name?, phone?, address?, photoUrl? }',
    responseBody: 'Updated UserModel',
    errors: ['requires-recent-login', 'network-request-failed'],
    color: Color(0xFFF59E0B),
  ),
  _ApiEndpoint(
    title: 'Sign Out',
    method: 'DELETE',
    path: 'FirebaseAuth.signOut() + GoogleSignIn.signOut()',
    description: 'Signs out from both Firebase Auth and Google sessions.',
    requestBody: 'none',
    responseBody: 'void',
    errors: [],
    color: Color(0xFFEF4444),
  ),
];

const _firestoreEndpoints = [
  _ApiEndpoint(
    title: 'Stream All Products',
    method: 'GET',
    path: 'collection("products").snapshots()',
    description: 'Real-time stream of all product documents. Used in home feed and admin list.',
    requestBody: 'none',
    responseBody: 'Stream<List<ProductModel>>',
    errors: ['permission-denied', 'unavailable'],
    color: Color(0xFF1A5CFF),
  ),
  _ApiEndpoint(
    title: 'Add Product',
    method: 'POST',
    path: 'collection("products").doc(id).set(data)',
    description: 'Creates a new product document with a manually-generated ID.',
    requestBody: 'ProductModel.toMap()',
    responseBody: 'void',
    errors: ['permission-denied', 'already-exists'],
    color: Color(0xFF22C55E),
  ),
  _ApiEndpoint(
    title: 'Update Product',
    method: 'PATCH',
    path: 'collection("products").doc(id).update(data)',
    description: 'Updates product fields. updatedAt is set to server timestamp.',
    requestBody: 'Partial ProductModel fields + updatedAt: serverTimestamp()',
    responseBody: 'void',
    errors: ['not-found', 'permission-denied'],
    color: Color(0xFFF59E0B),
  ),
  _ApiEndpoint(
    title: 'Delete Product',
    method: 'DELETE',
    path: 'collection("products").doc(id).delete()',
    description: 'Hard deletes a product document.',
    requestBody: 'productId: String',
    responseBody: 'void',
    errors: ['not-found', 'permission-denied'],
    color: Color(0xFFEF4444),
  ),
  _ApiEndpoint(
    title: 'Stream All Orders (Admin)',
    method: 'GET',
    path: 'collection("orders").orderBy("createdAt", desc).snapshots()',
    description: 'Admin-only stream of all orders, newest first.',
    requestBody: 'none',
    responseBody: 'Stream<List<OrderModel>>',
    errors: ['permission-denied'],
    color: Color(0xFF1A5CFF),
  ),
  _ApiEndpoint(
    title: 'Stream User Orders',
    method: 'GET',
    path: 'collection("orders").where("userId", ==, uid).snapshots()',
    description: 'Per-user order history stream for the Orders tab.',
    requestBody: 'userId: String',
    responseBody: 'Stream<List<OrderModel>>',
    errors: ['permission-denied'],
    color: Color(0xFF1A5CFF),
  ),
  _ApiEndpoint(
    title: 'Place Order',
    method: 'POST',
    path: 'collection("orders").doc(id).set(data)',
    description: 'Creates an order document from the current cart.',
    requestBody: 'OrderModel.toMap() (UUID-based ID)',
    responseBody: 'void',
    errors: ['permission-denied', 'quota-exceeded'],
    color: Color(0xFF22C55E),
  ),
  _ApiEndpoint(
    title: 'Update Order Status',
    method: 'PATCH',
    path: 'collection("orders").doc(id).update({ status, updatedAt })',
    description: 'Admin updates order status. Triggers UI refresh via stream.',
    requestBody: '{ status: String, updatedAt: ISO String }',
    responseBody: 'void',
    errors: ['not-found', 'permission-denied'],
    color: Color(0xFFF59E0B),
  ),
  _ApiEndpoint(
    title: 'Stream All Users (Admin)',
    method: 'GET',
    path: 'collection("users").snapshots()',
    description: 'Admin-only stream of all user profiles.',
    requestBody: 'none',
    responseBody: 'Stream<List<UserModel>>',
    errors: ['permission-denied'],
    color: Color(0xFF1A5CFF),
  ),
  _ApiEndpoint(
    title: 'Get User Profile',
    method: 'GET',
    path: 'collection("users").doc(uid).get()',
    description: 'Fetches a single user document. Used after login.',
    requestBody: 'uid: String',
    responseBody: 'UserModel?',
    errors: ['not-found', 'permission-denied'],
    color: Color(0xFF1A5CFF),
  ),
  _ApiEndpoint(
    title: 'Toggle User Role',
    method: 'PATCH',
    path: 'collection("users").doc(uid).update({ role })',
    description: 'Admin promotes/demotes users between customer and admin.',
    requestBody: '{ role: "customer" | "admin" }',
    responseBody: 'void',
    errors: ['not-found', 'permission-denied'],
    color: Color(0xFFF59E0B),
  ),
];

const _otherEndpoints = [
  _ApiEndpoint(
    title: 'Firebase Initialization',
    method: 'INIT',
    path: 'Firebase.initializeApp(options)',
    description:
        'Bootstraps all Firebase services. Must complete before runApp().',
    requestBody: 'FirebaseOptions (from firebase_options.dart)',
    responseBody: 'FirebaseApp instance',
    errors: ['duplicate-app', 'invalid-api-key'],
    color: Color(0xFFFF6B2C),
  ),
  _ApiEndpoint(
    title: 'Auth State Stream',
    method: 'STREAM',
    path: 'FirebaseAuth.authStateChanges()',
    description:
        'Reactive stream powering the router guard. Emits on login/logout.',
    requestBody: 'none',
    responseBody: 'Stream<User?> — null means logged out',
    errors: [],
    color: Color(0xFF8B5CF6),
  ),
  _ApiEndpoint(
    title: 'Cached Network Image',
    method: 'GET',
    path: 'HTTP GET (CachedNetworkImage)',
    description:
        'Loads product images from URL with disk and memory caching.',
    requestBody: 'imageUrl: String',
    responseBody: 'Image widget (cached or network)',
    errors: ['404 not found', 'network-error'],
    color: Color(0xFF64748B),
  ),
];

// ─────────────────────────────────────────────────────────────
// Endpoint list widget
// ─────────────────────────────────────────────────────────────
class _EndpointList extends StatelessWidget {
  final List<_ApiEndpoint> endpoints;

  const _EndpointList({required this.endpoints});

  @override
  Widget build(BuildContext context) {
    if (endpoints.isEmpty) {
      return const Center(
        child: Text('No matching endpoints.',
            style: TextStyle(color: AppTheme.textLight)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: endpoints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _EndpointCard(endpoint: endpoints[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Endpoint card
// ─────────────────────────────────────────────────────────────
class _EndpointCard extends StatefulWidget {
  final _ApiEndpoint endpoint;

  const _EndpointCard({required this.endpoint});

  @override
  State<_EndpointCard> createState() => _EndpointCardState();
}

class _EndpointCardState extends State<_EndpointCard> {
  bool _expanded = false;

  Color get _methodColor {
    switch (widget.endpoint.method) {
      case 'GET':
      case 'STREAM':
        return const Color(0xFF1A5CFF);
      case 'POST':
        return const Color(0xFF22C55E);
      case 'PATCH':
        return const Color(0xFFF59E0B);
      case 'DELETE':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.endpoint;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Method badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _methodColor.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      e.method,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _methodColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppTheme.textHint,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Path
                  _CodeRow(label: 'Path', value: e.path),
                  const SizedBox(height: 10),
                  // Description
                  Text(
                    e.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMedium,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CodeRow(label: 'Request', value: e.requestBody),
                  const SizedBox(height: 6),
                  _CodeRow(label: 'Response', value: e.responseBody),
                  if (e.errors.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Error Codes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: e.errors
                          .map((err) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull),
                                  border: Border.all(
                                      color: AppTheme.error
                                          .withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  err,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeRow extends StatelessWidget {
  final String label;
  final String value;

  const _CodeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onLongPress: () =>
                Clipboard.setData(ClipboardData(text: value)),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────
class _ApiEndpoint {
  final String title;
  final String method;
  final String path;
  final String description;
  final String requestBody;
  final String responseBody;
  final List<String> errors;
  final Color color;

  const _ApiEndpoint({
    required this.title,
    required this.method,
    required this.path,
    required this.description,
    required this.requestBody,
    required this.responseBody,
    required this.errors,
    required this.color,
  });
}
