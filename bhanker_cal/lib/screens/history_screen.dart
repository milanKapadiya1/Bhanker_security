import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:file_picker/file_picker.dart'; // Removed file_picker
import 'package:permission_handler/permission_handler.dart'; // import permission_handler
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
                1: const pw.IntrinsicColumnWidth(), // Days
                2: const pw.IntrinsicColumnWidth(), // Per Day
                3: const pw.IntrinsicColumnWidth(), // Monthly
                4: const pw.FlexColumnWidth(), // Deductions
                5: const pw.IntrinsicColumnWidth(), // Gross Salary
                6: const pw.IntrinsicColumnWidth(), // Profit
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerLeft, // Deductions
                5: pw.Alignment.centerRight, // Gross Salary
                6: pw.Alignment.centerRight, // Profit
              },
              headers: [
                'Name',
                'Days',
                'Per Day',
                'Monthly',
                'Deductions',
                'Gross Salary',
                'Profit'
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
                  '${item.presentDays}/${item.totalDays}',
                  NumberFormat('#,##0').format(item.perDayAmount),
                  NumberFormat('#,##0').format(item.monthlySalary),
                  deductionStr, // New Column Data
                  NumberFormat('#,##0').format(item.calculatedSalary),
                  '+${NumberFormat('#,##0').format(item.profit)}',
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

    final bytes = await pdf.save(); // Get PDF bytes

    // final bytes = await pdf.save(); // Already defined above
    String? finalPath;

    try {
      Directory? directory;
      bool permissionGranted = false;

      // 1. Try Public "Downloads" folder (Android Only)
      if (Platform.isAndroid) {
        // Attempt to request permissions
        // Note: manageExternalStorage request opens settings page,
        // if user denies or ignores, we must have a fallback.
        if (await Permission.storage.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {
          permissionGranted = true;
        }

        // Even if permission is 'denied', on Android 10+ using specific paths might work.
        // But to be safe, we check if we can write.

        if (permissionGranted) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = null; // Path invalid
          }
        }
      }

      // 2. If Public failed or iOS -> Use App Documents
      if (directory == null) {
        if (Platform.isAndroid) {
          directory =
              await getExternalStorageDirectory(); // App-specific external (Android/data/...)
        } else {
          directory = await getApplicationDocumentsDirectory(); // iOS Documents
        }
      }

      if (directory != null) {
        final filePath = '${directory.path}/Salary_Report_$month.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        finalPath = filePath;
      } else {
        throw Exception('Could not determine ANY save directory.');
      }

      // Success Message
      if (context.mounted && finalPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Saved PDF to: $finalPath'), // Show full path so user knows where it is
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF. Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
                            title: Text(
                              item.employeeName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4.h),
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
                                Text(
                                  'Profit: +₹${NumberFormat('#,##0').format(item.profit)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
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
