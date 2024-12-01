import 'package:flutter/material.dart';
import 'package:lds/Controller/InvoiceDashboard.dart';
import 'package:lds/Models/InvoiceDashboard.dart';
import 'package:lds/View/FilteredTable.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<ChartData> statusData = [];
  List<ChartData> typeData = [];
  late final String? filterValue; // Make nullable
  final InvoiceDashboardService _invoiceService = InvoiceDashboardService();
  DateTimeRange? dateRange;

  @override
  void initState() {
    super.initState();
    _fetchDataFromApi(); // Fetch data on screen load
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: dateRange,
    );
    if (newRange != null) {
      setState(() {
        dateRange = newRange;
      });
    }
  }

  Future<void> _fetchDataFromApi() async {
    InvoiceDashboard? invoiceDashboard = await _invoiceService.fetchInvoiceDashboard();

    if (invoiceDashboard != null && invoiceDashboard.zatchaDashboard != null) {
      setState(() {
        statusData = [
          ChartData('Clear', (invoiceDashboard.zatchaDashboard!.status?.clear ?? 0).toDouble(), Colors.green),
          ChartData('Pending', (invoiceDashboard.zatchaDashboard!.status?.pending ?? 0).toDouble(), Colors.blue),
          ChartData('Error', (invoiceDashboard.zatchaDashboard!.status?.error ?? 0).toDouble(), Colors.red),
          ChartData('Warning', (invoiceDashboard.zatchaDashboard!.status?.warning ?? 0).toDouble(), Colors.orange),
        ];

        typeData = [
          ChartData('Invoice', (invoiceDashboard.zatchaDashboard!.type?.invoice ?? 0).toDouble(), Colors.purple),
          ChartData('CreditNote', (invoiceDashboard.zatchaDashboard!.type?.creditNote ?? 0).toDouble(), Colors.yellow[700]!),
          ChartData('DebitNote', (invoiceDashboard.zatchaDashboard!.type?.debitNote ?? 0).toDouble(), Colors.orange),
          ChartData('Prepaid', (invoiceDashboard.zatchaDashboard!.type?.prepaid ?? 0).toDouble(), Colors.blue),
          ChartData('Draft', (invoiceDashboard.zatchaDashboard!.type?.draft ?? 0).toDouble(), Colors.grey),
        ];
      });
    } else {
      print("Failed to parse invoice dashboard data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDate = dateRange?.start;
    final endDate = dateRange?.end;

    // Format the dates to show only the date without the time
    String dateText = 'Select Date Range';
    if (startDate != null && endDate != null) {
      // Use DateFormat to format the DateTime to only show the date part
      final dateFormat = DateFormat('yyyy-MM-dd'); // You can change the format if needed
      dateText = '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const  Text('Invoice Dashboard'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.calendar_today,
                    size: 20,
                  ),
                  label: Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _pickDateRange,

                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 28,
                  ),
                  onPressed: (){
                    _fetchDataFromApi();
                    },
                  splashColor: Colors.blue.withOpacity(0.2),
                  highlightColor: Colors.blue.withOpacity(0.1),
                  tooltip: 'Refresh Data',
                  iconSize: 30,
                  color: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // First Card with Translation and Scaling
             // Slight scaling effect
                 Card(
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.black,
                  surfaceTintColor: Colors.blue,
                  borderOnForeground: false,
                  child: SfCircularChart(
                    title: const ChartTitle(
                      text: 'Document Analysis With Status ',
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      alignment: ChartAlignment.center,
                    ),
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      borderWidth: 0,
                    ),
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        dataSource: statusData,
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          labelPosition: ChartDataLabelPosition.outside,
                          connectorLineSettings: ConnectorLineSettings(
                            type: ConnectorType.curve,
                            length: '20%',
                          ),
                        ),
                        onPointTap: (ChartPointDetails details) {
                          String status = statusData[details.pointIndex!].label;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilteredTableScreen(
                                filterType: 'status',
                                filterValue: status,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    enableMultiSelection: false,
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      color: Colors.black54,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

            const SizedBox(height: 10),
            // Second Card with Translation and Scaling
            Card(
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.black,
                  surfaceTintColor: Colors.blue,
                  borderOnForeground: false,
                  child: SfCircularChart(
                    title: const ChartTitle(
                      text: 'Document Analysis With Type ',
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      alignment: ChartAlignment.center,
                    ),
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      borderWidth: 0,
                    ),
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        dataSource: typeData,
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          labelPosition: ChartDataLabelPosition.outside,
                          connectorLineSettings: ConnectorLineSettings(
                            type: ConnectorType.curve,
                            length: '20%',
                          ),
                        ),
                        onPointTap: (ChartPointDetails details) {
                          String type = typeData[details.pointIndex!].label;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilteredTableScreen(
                                filterType: 'type',
                                filterValue: type,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    enableMultiSelection: false,
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      color: Colors.black54,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
