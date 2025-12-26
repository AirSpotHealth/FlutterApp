import 'package:flutter/material.dart';

/// Optional email field for follow-up contact.
class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'your@email.com',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        onChanged: (value) {
          onChanged(value.isEmpty ? null : value);
        },
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (!value.contains('@') || !value.contains('.')) {
              return 'Please enter a valid email address';
            }
          }
          return null; // Optional field
        },
      ),
    );
  }
}
