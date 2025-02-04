import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lds/View/FilteredTable.dart';
import 'package:lds/View/scanner.dart';
import 'package:lds/View/settings.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../Controller/InvoiceDashboard.dart';
import '../l10n/app_localizations.dart';
import 'Login.dart';
import 'Profile.dart';
import 'Outbound.dart';
import 'PushNotification.dart';
import 'gemini.dart';
import 'languageswitch.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController periodFromController = TextEditingController();
  final TextEditingController periodToController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Map<String, int> typeStatusData = {};
  Map<String, int> typeDataData = {};

  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    _setDefaultDates();
    _initializeDashboard();

  }
  Future<void> _initializeDashboard() async {
    // Set the default dates
    _setDefaultDates();

    // Wait for a small delay to ensure UI is ready (optional)
    await Future.delayed(const Duration(milliseconds: 1));

    // Fetch dashboard data with default dates
    await fetchDashboardData();
  }
  void _setDefaultDates() {
    DateTime today = DateTime.now();
    DateTime firstDayOfMonth = DateTime(today.year, today.month, 1); // First day of current month

    String formattedFromDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    String formattedToDate = DateFormat('yyyy-MM-dd').format(today);

    periodFromController.text = formattedFromDate;
    periodToController.text = formattedToDate;
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get period values from controllers
      String periodFrom = periodFromController.text;
      String periodTo = periodToController.text;

      // Replace '*' with '-'
      periodFrom = periodFrom.replaceAll('*', '-');
      periodTo = periodTo.replaceAll('*', '-');

      DateFormat dateFormat = DateFormat("dd-MMM-yyyy");

      DateTime parsedPeriodFrom;
      DateTime parsedPeriodTo;

      try {
        parsedPeriodFrom = DateTime.parse(periodFrom);
        parsedPeriodTo = DateTime.parse(periodTo);
      } catch (e) {
        setState(() {
          errorMessage = 'Invalid date format. Please use YYYY-MM-DD.';
          isLoading = false;
        });
        return;
      }

      // Format date to dd-MMM-yyyy
      periodFrom = dateFormat.format(parsedPeriodFrom);
      periodTo = dateFormat.format(parsedPeriodTo);

      // Retrieve companyId from secure storage
      final String? storedCompanyId = await secureStorage.read(key: 'Company_Id');

      if (storedCompanyId == null) {
        setState(() {
          errorMessage = 'Company ID is not available in secure storage.';
          isLoading = false;
        });
        return;
      }

      // Parse companyId to int (or handle error if it can't be parsed)
      int companyId = int.tryParse(storedCompanyId) ?? 0; // Default to 0 if parsing fails

      // Call the service to fetch counts
      DashboardService dashboardService = DashboardService();
      final counts = await dashboardService.fetchDashboardCounts(
        periodFrom: parsedPeriodFrom,
        periodTo: parsedPeriodTo,
        companyId: companyId.toString(),  // Pass companyId here
      );

      if (counts.isEmpty) {
        // Handle the case where there is no data
        setState(() {
          errorMessage = 'No Data Found!';
          isLoading = false;
        });
        return;
      }

      setState(() {
        typeStatusData = {
          "Pending": counts["Pending"] ?? 0,
          "Error": counts["Error"] ?? 0,
          "Warning": counts["Warning"] ?? 0,
          "Clear": counts["Clear"] ?? 0,
        };

        typeDataData = {
          "Invoice": counts["Invoice"] ?? 0,
          "CreditNote": counts["CreditNote"] ?? 0,
          "DebitNote": counts["DebitNote"] ?? 0,
          "Draft": counts["Draft"] ?? 0,
          "Prepaid": counts["Prepaid"] ?? 0,
        };

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  final Map<String, Color> statusColors = {
    "Pending": const Color(0xFF0F6ECB),
    "Error":const Color(0XFFCA1E1A),
    "Warning":const Color(0xFFFF6700) ,
    "Clear": Colors.green,
  };

  final Map<String, Color> docTypeColors = {

    "Invoice":const Color(0xFF9B37AC),
    "CreditNote":const Color(0xFF643DA8),
    "DebitNote": const Color(0XFF4251A6),
    "Draft": const Color(0XFF12AABE),
    "Prepaid":const Color(0XFF298CDC),
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context, 'Invoice Dashboard'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 5, // Reduced elevation for a floating effect
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        toolbarHeight: 60,
        actions: [

          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => NotificationScreen()));
            },
          ),
        ],
      ),

      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use the LanguageSwitchWidget here
                  LanguageSwitchWidget(),
                  // You can add other content here
                ],
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 8,  // Increased elevation for a floating effect
                surfaceTintColor: Colors.blueAccent.withOpacity(0.2), // Soft background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20), // Increased padding for more spacious design
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell( // Tap functionality with a ripple effect
                              onTap: () => _selectDate(context, periodFromController),
                              child: TextField(
                                controller: periodFromController,
                                enabled: false,
                                style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), // Modern font style
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context, 'Date From'),
                                  labelStyle: TextStyle(color: Colors.black54), // Soft label color
                                  floatingLabelBehavior: FloatingLabelBehavior.auto, // Modern floating label behavior
                                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Padding inside TextField
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12), // Rounded borders for TextField
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1), // Subtle border
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1), // Lighter border when not focused
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue, width: 2), // Blue border when focused
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell( // Tap functionality with a ripple effect
                              onTap: () => _selectDate(context, periodToController),
                              child: TextField(
                                controller: periodToController,
                                enabled: false,
                                style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context, 'Date To'),
                                  labelStyle: TextStyle(color: Colors.black54),
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.blue, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
,

              Center(
                child: ElevatedButton(
                  onPressed: fetchDashboardData,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue[900],
                  ),
                  child:  Text(
                    AppLocalizations.of(context, 'Fetch Data'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (errorMessage.isNotEmpty) ...[
     Center(
    child: Text( "No Data Found", style: TextStyle(color: Colors.red, fontSize: 16)),
    )
              ] else ...[
                // First Chart Card
    Center(child:  Text(
      AppLocalizations.of(context, 'Type Status Chart'),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),),
                Card(
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.black,
                  surfaceTintColor: Colors.blueAccent.withOpacity(0.2),
                  child: SfCircularChart(
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      borderWidth: 0,
                    ),                  series: <CircularSeries>[
                    PieSeries<ChartData, String>(
                      dataSource: _generateChartData(typeStatusData),
                      xValueMapper: (ChartData data, _) => data.label,
                      yValueMapper: (ChartData data, _) => data.value,
                      dataLabelMapper: (ChartData data, _) => '${data.label}: ${data.value}',
                      pointColorMapper: (ChartData data, _) => statusColors[data.label] ?? Colors.primaries[ _generateChartData(typeStatusData).indexOf(data) % Colors.primaries.length], // Assign color based on status

                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          fontSize: 9,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        labelPosition: ChartDataLabelPosition.outside,

                        connectorLineSettings: ConnectorLineSettings(
                          type: ConnectorType.curve,
                          length: '2%',
                        ),
                      ),
                      onPointTap: (ChartPointDetails details) async {
                        final String selectedStatus = typeStatusData.keys.toList()[details.pointIndex!];

                        try {
                          // Parse the text from the TextControllers into DateTime objects
                          DateTime periodFrom = DateTime.parse(periodFromController.text);
                          DateTime periodTo = DateTime.parse(periodToController.text);

                          // Retrieve CompanyId from secure storage
                          final String? companyId = await secureStorage.read(key: 'Company_Id');

                          if (companyId != null) {
                            // Navigate to the FilteredTableScreen with the retrieved CompanyId and parsed DateTime values
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilteredTableScreen(
                                  companyId: companyId,  // Pass the retrieved CompanyId
                                  periodFrom: periodFrom,
                                  periodTo: periodTo,
                                  docType: '00',  // Pass document type (e.g., 'Invoice')
                                  status: selectedStatus, // Pass selected status (e.g., 'Pending')
                                ),
                              ),
                            );
                          } else {
                            // Handle the case where CompanyId is null
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Company ID not found in secure storage.')),
                            );
                          }
                        } catch (e) {
                          // Handle invalid date format errors
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid date format. Please use yyyy-MM-dd.')),
                          );
                        }
                      },
                      radius: '60%',
                    )
                  ],
                  ),
                ),
                // Second Chart Card
                SizedBox(height:20),
                Center(child: Text(
                  AppLocalizations.of(context, 'Document Type Chart'),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),),
                Card(
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.black,
                  surfaceTintColor: Colors.blue,
                  borderOnForeground: false,
                  child: SfCircularChart(

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
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          labelPosition: ChartDataLabelPosition.outside,

                          connectorLineSettings: ConnectorLineSettings(
                            type: ConnectorType.curve,
                            length: '2%',
                          ),
                        ),
                        dataSource: _generateChartData(typeDataData),
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        dataLabelMapper: (ChartData data, _) => '${data.label}:${data.value}',
                        pointColorMapper: (ChartData data, _) => docTypeColors[data.label] ?? Colors.accents[_generateChartData(typeDataData).indexOf(data) % Colors.accents.length],
                        onPointTap: (ChartPointDetails details) async {
                          final String selectedDoc = typeDataData.keys.toList()[details.pointIndex!];

                          try {
                            // Parse the text from the TextControllers into DateTime objects
                            DateTime periodFrom = DateTime.parse(periodFromController.text);
                            DateTime periodTo = DateTime.parse(periodToController.text);

                            // Retrieve CompanyId from secure storage
                            final String? companyId = await secureStorage.read(key: 'Company_Id');

                            if (companyId != null) {
                              // Navigate to the FilteredTableScreen with the retrieved CompanyId and parsed DateTime values
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilteredTableScreen(
                                    companyId: companyId,  // Pass the retrieved CompanyId
                                    periodFrom: periodFrom,
                                    periodTo: periodTo,
                                    docType: selectedDoc,  // Pass document type (e.g., 'Invoice')
                                    status: '00',           // Pass a fixed status (e.g., 'Pending')
                                  ),
                                ),
                              );
                            } else {
                              // Handle the case where CompanyId is null
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Company ID not found in secure storage.')),
                              );
                            }
                          } catch (e) {
                            // Handle invalid date format errors
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid date format. Please use yyyy-MM-dd.')),
                            );
                          }
                        },
                        radius: '60%',
                      )
                    ],
                  ),
                ),

              ]],
          ),
        ),


          ),
        );


  }

List<ChartData> _generateChartData(Map<String, int> data) {
  return data.entries.map((entry) => ChartData(entry.key, entry.value)).toList();
}
}
class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}

class MyDrawer extends StatefulWidget {
  final String? companyLogoUrl;

  const MyDrawer({Key? key, this.companyLogoUrl}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? userName = 'Loading...';
  String? userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    String? savedUserName = await _secureStorage.read(key: 'User_Name');
    String? savedUserEmail = await _secureStorage.read(key: 'Email');
    setState(() {
      userName = savedUserName ?? 'Unknown';
      userEmail = savedUserEmail ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              userEmail!,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40.0,


              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue[900],
            ),
          ),
          ListTile(
            leading:  Icon(Icons.dashboard, color: Colors.blue[900]),
            title:  Text(
                AppLocalizations.of(context, 'Dashboard'),
                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
          ),
          ListTile(
            leading:  Icon(Icons.account_circle, color: Colors.blue[900]),
            title:  Text(
                AppLocalizations.of(context, 'Profile'),
                style:const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProfilePage()),
              );
            },
          ),
          ListTile(
            leading:  Icon(Icons.edit_document,color: Colors.blue[900]),
            title: Text(
                AppLocalizations.of(context, 'Get Document'),

                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentPage()),
              );
            },
          ),

          ListTile(
            leading:  Icon(Icons.support_agent, color: Colors.blue[900]),
            title:  Text(
                AppLocalizations.of(context, 'Chat Bot'),
                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContentGenerationScreen()),
              );
            },
          ),
          ListTile(
            leading:  Icon(Icons.notifications, color: Colors.blue[900]),
            title:  Text(
                AppLocalizations.of(context, 'Notifications'),
                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  NotificationScreen()),
              );
            },
          ),
          ListTile(
            leading:  Icon(Icons.qr_code, color: Colors.blue[900]),
            title:  Text(
                AppLocalizations.of(context, 'Scan QR Code'),
                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerPage(),
                ), );
            },
          ),

          ListTile(
            leading:  Icon(Icons.settings,color: Colors.blue[900]),
            title:  Text(
                AppLocalizations.of(context, 'Settings'),
                style: const TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageScreen()),
              );
            },
          ),
          ListTile(
            leading:  Icon(Icons.exit_to_app, color: Colors.blue[900]),
            title:  Text(
                AppLocalizations.of(context, 'Logout'),
                style: const TextStyle(fontSize: 18)),
            onTap: () async {
              await AuthService.logout(context);
            },
          ),


          const Divider(),

        ],
      ),
    );
  }
}
class AuthService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Static logout method
  static Future<void> logout(BuildContext context) async {
    try {
      await _secureStorage.delete(key: 'Company_Id'); // Delete company ID
      await _secureStorage.delete(key: 'AccessToken');

      // Navigate to the LoginScreen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginScreen()
        ),
            (route) => false,
      );
    } catch (error) {
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            AppLocalizations.of(context, 'GetDocument'
                ' $error')),),
      );
    }
  }
}