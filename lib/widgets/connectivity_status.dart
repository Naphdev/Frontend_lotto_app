import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lotto_app/providers/connectivity_provider.dart';

class ConnectivityStatusWidget extends StatelessWidget {
  const ConnectivityStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        if (connectivityProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.red[600],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ConnectivityStatusWidget(),
        Expanded(child: child),
      ],
    );
  }
}
