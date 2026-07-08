import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_notify.dart';
import '../../core/utils/error_handler.dart';
import '../../core/services/image_service.dart';
import '../../core/services/location_service.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/avatar_image.dart';
import '../main_shell.dart';

enum _PhotoSource { camera, gallery }

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load profile.\n${AppErrorHandler.friendlyMessage(e)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textLight),
          ),
        ),
        data: (user) {
          return SingleChildScrollView(
            child: Column(
              children: [

                // ── Profile Header ─────────────────────────────
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: Column(
                    children: [
                      // Avatar — tap to capture/choose a new photo
                      GestureDetector(
                        onTap: user == null
                            ? null
                            : () => _pickAndSetProfilePhoto(
                                context, ref, user),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: AvatarImage(
                                photoUrl: user?.photoUrl ?? '',
                                initials: user?.initials ?? 'U',
                                size: 88,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        user?.name ?? 'Guest User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),

                      if (user?.phone.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          user!.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          user?.isAdmin == true
                              ? '👑 Admin'
                              : '🛒 Customer',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Admin Section (visible to admins only) ─────
                if (user?.isAdmin == true) ...[
                  _SectionHeader(title: 'Administration'),
                  _MenuTile(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Admin Panel',
                    subtitle: 'Manage products, orders & users',
                    onTap: () => context.push(AppRoutes.adminDashboard),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Account Section ────────────────────────────
                _SectionHeader(title: 'Account'),

                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () => _showEditProfile(context, ref, user),
                ),

                _MenuTile(
                  icon: Icons.location_on_outlined,
                  label: 'Delivery Address',
                  subtitle: user?.address.isNotEmpty == true
                      ? user!.address
                      : 'Not set',
                  onTap: () => _showEditProfile(context, ref, user),
                ),

                _MenuTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order History',
                  onTap: () {
                    ref.read(mainShellTabProvider.notifier).state = 3;
                  },
                ),

                const SizedBox(height: 16),

                // ── Support Section ────────────────────────────
                _SectionHeader(title: 'Support'),

                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & FAQ',
                  onTap: () {},
                ),

                _MenuTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Contact Us',
                  onTap: () {},
                ),

                _MenuTile(
                  icon: Icons.star_outline_rounded,
                  label: 'Rate the App',
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // ── Preferences Section ────────────────────────
                _SectionHeader(title: 'Preferences'),

                _SwitchTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),

                _MenuTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => AppNotify.info(
                      context, "You're all caught up — no new notifications."),
                ),

                _MenuTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                  onTap: () =>
                      context.push(AppRoutes.forgotPassword),
                ),

                const SizedBox(height: 16),

                // ── Logout ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _confirmLogout(context, authNotifier),
                    icon: const Icon(Icons.logout_rounded,
                        color: AppTheme.error),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppTheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLG),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App version
                const Text(
                  'Mega Mart v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textHint,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Avatar capture (camera/gallery) ────────────────────────
  Future<void> _pickAndSetProfilePhoto(
      BuildContext context, WidgetRef ref, UserModel user) async {
    final source = await showModalBottomSheet<_PhotoSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppTheme.primary),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, _PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppTheme.primary),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, _PhotoSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    try {
      final result = source == _PhotoSource.camera
          ? await ImageService.captureFromCamera()
          : await ImageService.pickFromGallery();

      if (result == null || !context.mounted) return; // user cancelled

      final ok = await ref.read(authNotifierProvider.notifier).updateProfile(
            uid: user.uid,
            photoUrl: result.dataUri,
          );

      if (!context.mounted) return;

      if (ok) {
        AppNotify.success(context, 'Profile photo updated!');
      } else {
        final message = ref.read(authNotifierProvider).maybeWhen(
              error: (e, _) => AppErrorHandler.friendlyMessage(e),
              orElse: () => 'Could not update your photo.',
            );
        AppNotify.error(context, message);
      }
    } on ImageServiceException catch (e) {
      if (context.mounted) AppNotify.error(context, e.message);
    } catch (e) {
      if (context.mounted) {
        AppNotify.error(context, AppErrorHandler.friendlyMessage(e));
      }
    }
  }

  // ── Edit Profile Sheet ─────────────────────────────────────
  void _showEditProfile(
      BuildContext context, WidgetRef ref, UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final addressController =
        TextEditingController(text: user?.address ?? '');
    bool isFetchingLocation = false;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: isFetchingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        )
                      : IconButton(
                          tooltip: 'Use my current location',
                          icon: const Icon(Icons.my_location_rounded,
                              color: AppTheme.primary),
                          onPressed: () async {
                            setSheetState(() => isFetchingLocation = true);
                            try {
                              final loc =
                                  await LocationService.getCurrentLocation();
                              addressController.text = loc.asAddressLabel;
                            } on LocationServiceException catch (e) {
                              if (ctx.mounted) {
                                AppNotify.error(ctx, e.message);
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                AppNotify.error(
                                  ctx,
                                  AppErrorHandler.friendlyMessage(e),
                                );
                              }
                            } finally {
                              if (ctx.mounted) {
                                setSheetState(
                                    () => isFetchingLocation = false);
                              }
                            }
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: (user == null || isSaving)
                    ? null
                    : () async {
                        setSheetState(() => isSaving = true);
                        final ok = await ref
                            .read(authNotifierProvider.notifier)
                            .updateProfile(
                              uid: user.uid,
                              name: nameController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                            );
                        if (!ctx.mounted) return;
                        setSheetState(() => isSaving = false);

                        if (ok) {
                          Navigator.pop(ctx);
                          if (context.mounted) {
                            AppNotify.success(
                                context, 'Profile updated!');
                          }
                        } else {
                          final message = ref
                              .read(authNotifierProvider)
                              .maybeWhen(
                                error: (e, _) =>
                                    AppErrorHandler.friendlyMessage(e),
                                orElse: () =>
                                    'Could not save your changes.',
                              );
                          AppNotify.error(ctx, message);
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Confirm Logout Dialog ──────────────────────────────────
  void _confirmLogout(
      BuildContext context, AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        title: const Text('Sign Out?'),
        content: const Text(
            'Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authNotifier.logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textLight,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Menu Tile ────────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: AppTheme.cardDecoration(),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppTheme.textHint),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}

// ── Switch Tile (Dark Mode toggle etc.) ───────────────────────
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: AppTheme.cardDecoration(),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        trailing: Switch(
          value: value,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
