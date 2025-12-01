import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../services/salary_service.dart';
import '../models/calculation_result.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history';

  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _salaryService = SalaryService();
  late Future<Map<String, List<CalculationResult>>> _groupedHistoryFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _groupedHistoryFuture = _fetchAndGroupHistory();
    });
  }

  Future<Map<String, List<CalculationResult>>> _fetchAndGroupHistory() async {
    final history = await _salaryService.getHistory();
    final Map<String, List<CalculationResult>> grouped = {};

    for (var item in history) {
      final key = DateFormat('MMMM yyyy').format(item.date);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }
    return grouped;
  }

  Future<void> _generatePdf(String month, List<CalculationResult> items) async {
    final pdf = pw.Document();

    // Load font if needed, but standard fonts work well for basic text
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Salary Report',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(month,
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              columnWidths: {
                0: const pw.IntrinsicColumnWidth(), // Name
                1: const pw.IntrinsicColumnWidth(), // ID
                2: const pw.IntrinsicColumnWidth(), // Role
                3: const pw.IntrinsicColumnWidth(), // Days
                4: const pw.IntrinsicColumnWidth(), // Per Day
                5: const pw.IntrinsicColumnWidth(), // Monthly
                6: const pw.FlexColumnWidth(), // Deductions
                7: const pw.IntrinsicColumnWidth(), // Gross Salary
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerLeft, // Deductions
                7: pw.Alignment.centerRight, // Gross Salary
              },
              headers: [
                'Name',
                'ID',
                'Role',
                'Days',
                'Per Day',
                'Monthly',
                'Deductions',
                'Gross Salary'
              ],
              data: items.map((item) {
                // Format deductions string
                final List<String> deductions = [];
                if (item.wc > 0) deductions.add('WC: ${item.wc.toInt()}');
                if (item.uniform > 0)
                  deductions.add('Uni: ${item.uniform.toInt()}');
                if (item.advance > 0)
                  deductions.add('Adv: ${item.advance.toInt()}');
                final deductionStr =
                    deductions.isEmpty ? '-' : deductions.join(', ');

                return [
                  item.employeeName,
                  item.employeeId,
                  item.employeeRole,
                  '${item.presentDays}/${item.totalDays}',
                  NumberFormat('#,##0').format(item.perDayAmount),
                  NumberFormat('#,##0').format(item.monthlySalary),
                  deductionStr, // New Column Data
                  NumberFormat('#,##0').format(item.calculatedSalary),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                    'Total: ${NumberFormat('#,##0').format(items.fold(0.0, (sum, item) => sum + item.calculatedSalary))}',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Salary_Report_$month.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshHistory,
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder<Map<String, List<CalculationResult>>>(
          future: _groupedHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final groupedHistory = snapshot.data ?? {};

            if (groupedHistory.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(color: Colors.grey.shade100),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 48.h, horizontal: 24.w),
                          child: Column(
                            children: [
                              Text(
                                'No salary calculations yet.',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Calculations saved from the calculator will appear here.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: groupedHistory.length,
              itemBuilder: (context, index) {
                final monthKey = groupedHistory.keys.elementAt(index);
                final monthItems = groupedHistory[monthKey]!;

                return Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      monthKey,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${monthItems.length} calculations',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _generatePdf(monthKey, monthItems),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Download PDF Report'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                            ),
                          ),
                        ),
                      ),
                      ...monthItems.map((item) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade100),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            title: Row(
                              children: [
                                Text(
                                  item.employeeName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    item.employeeRole,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4.h),
                                Text(
                                  'ID: ${item.employeeId}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${item.presentDays}/${item.totalDays} days',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Per Day: ₹${NumberFormat('#,##0').format(item.perDayAmount)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                if (item.wc > 0 ||
                                    item.uniform > 0 ||
                                    item.advance > 0) ...[
                                  SizedBox(height: 4.h),
                                  Wrap(
                                    spacing: 8.w,
                                    children: [
                                      Text(
                                        'Deductions:',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (item.wc > 0)
                                        Text(
                                          'WC: ${NumberFormat('#,##0').format(item.wc)}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      if (item.uniform > 0)
                                        Text(
                                          'Uniform: ${NumberFormat('#,##0').format(item.uniform)}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      if (item.advance > 0)
                                        Text(
                                          'Adv: ${NumberFormat('#,##0').format(item.advance)}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
