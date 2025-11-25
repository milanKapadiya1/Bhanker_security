import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const MonthPickerDialog({super.key, required this.initialDate});

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year Selector
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedYear',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                  // Simple year navigation for now, or could be a dropdown
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _selectedYear--),
                        child: Icon(Icons.chevron_left, size: 20.sp),
                      ),
                      SizedBox(width: 8.w),
                      InkWell(
                        onTap: () => setState(() => _selectedYear++),
                        child: Icon(Icons.chevron_right, size: 20.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Month Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthIndex = index + 1;
                final isSelected = monthIndex == _selectedMonth;
                final monthName = _getMonthName(monthIndex);

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMonth = monthIndex;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      monthName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Clear selection (or just close without selecting?)
                    // User image says "Clear", likely resets or returns null.
                    // For now, let's return null to indicate no change or clear.
                    Navigator.pop(context, null);
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    // "This month" -> Select current month/year
                    final now = DateTime.now();
                    Navigator.pop(context, DateTime(now.year, now.month));
                  },
                  child: const Text('This month'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                        context, DateTime(_selectedYear, _selectedMonth));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    minimumSize: Size(0, 36.h),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
