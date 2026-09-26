import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        // ======================================================
        // TITLE
        // ======================================================

        Expanded(
          child: Row(
            children: [
              Container(
                width: 4,
                height: 21,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius:
                  BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // ACTION
        // ======================================================

        if (actionText != null)
          const SizedBox(width: 8),

        if (actionText != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              minimumSize: Size.zero,
              tapTargetSize:
              MaterialTapTargetSize
                  .shrinkWrap,
              foregroundColor:
              colorScheme.primary,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons
                      .arrow_forward_rounded,
                  size: 15,
                  color:
                  colorScheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}