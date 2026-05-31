import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String text;

  const LoadingWidget({
    super.key,
    this.text = 'Processando...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
