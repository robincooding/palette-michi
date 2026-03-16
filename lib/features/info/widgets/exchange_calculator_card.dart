import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palette_michi/core/theme/app_colors.dart';

class ExchangeCalculatorCard extends StatefulWidget {
  final double currentJpyRate;

  const ExchangeCalculatorCard({super.key, required this.currentJpyRate});

  @override
  State<ExchangeCalculatorCard> createState() => _ExchangeCalculatorCardState();
}

class _ExchangeCalculatorCardState extends State<ExchangeCalculatorCard> {
  late final TextEditingController _jpyController = TextEditingController();
  String _krwResult = "0";

  @override
  void dispose() {
    _jpyController.dispose();
    super.dispose();
  }

  void _onJpyChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _krwResult = "0";
      });
      return;
    }

    // 콤마 제거 후 숫자로 변환
    final n = double.tryParse(value.replaceAll(',', ''));
    if (n != null && widget.currentJpyRate > 0) {
      setState(() {
        // 한국수출입은행 API 기준 100엔당 원화값이므로 n * (rate / 100)
        _krwResult = NumberFormat(
          '#,###',
        ).format((n * widget.currentJpyRate).round());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = widget.currentJpyRate > 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "현재 환율(100엔당)",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              isReady
                  ? Text(
                      "약 ${(widget.currentJpyRate * 100).toStringAsFixed(2)}원",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _jpyController,
            keyboardType: TextInputType.number,
            onChanged: _onJpyChanged,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "0",
              prefixText: "¥ ",
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Icon(
              Icons.arrow_downward,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              "₩ $_krwResult",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Text(
            "엔화를 입력하면 원화로 변환됩니다.",
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
