import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kit_template_app/core/constants/app_color.dart';
import 'package:kit_template_app/gen/assets.gen.dart';

/// App-wide blocking loader; prefer `UiHelpers.showLoader`/`hideLoader`.
abstract class AppLoader {
  static final ValueNotifier<int> _count = ValueNotifier<int>(0);
  static final ValueNotifier<int> _suspensions = ValueNotifier<int>(0);

  /// Fires whenever visibility could have changed.
  static Listenable get listenable => Listenable.merge([_count, _suspensions]);

  static bool get isVisible => _count.value > 0 && _suspensions.value == 0;

  static void show() => _count.value++;

  static void hide() {
    if (_count.value > 0) _count.value--;
  }

  /// Force-clears every outstanding request (safety valve).
  static void reset() {
    _count.value = 0;
    _suspensions.value = 0;
  }

  /// Hides the overlay for [action]; the caller keeps the reference count.
  static Future<T> suspendedDuring<T>(Future<T> Function() action) async {
    _suspensions.value++;
    try {
      return await action();
    } finally {
      if (_suspensions.value > 0) _suspensions.value--;
    }
  }
}

/// Paints the blocking loader above [child]; mounted once at the app root.
class AppLoaderOverlay extends StatelessWidget {
  const AppLoaderOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLoader.listenable,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          child,
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: AppLoader.isVisible
                ? const _LoaderScrim()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _LoaderScrim extends StatelessWidget {
  const _LoaderScrim();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          const ModalBarrier(dismissible: false, color: AppColor.scrim),
          Center(
            child: SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColor.white,
                    ),
                  ),
                  ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Assets.images.appicon.image(
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scaleXY(
                        begin: 0.94,
                        end: 1.04,
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
