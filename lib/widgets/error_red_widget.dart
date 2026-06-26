import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class ErrorRedWidget extends StatelessWidget {
  final VoidCallback onReintentar; // función que se llama al pulsar Reintentar

  const ErrorRedWidget({super.key, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 52, color: kColorTextoSecundario),
          const SizedBox(height: 16),
          const Text(
            'Sin conexión con el servidor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kColorTextoOscuro,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Contacta con tu amorcito <3',
            style: TextStyle(fontSize: 14, color: kColorTextoSecundario),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onReintentar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B46BE), // morado BTS
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
