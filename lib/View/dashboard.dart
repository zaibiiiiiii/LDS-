import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lds/View/Login.dart';
import 'package:lds/View/Google_maps.dart';
import 'package:lds/View/addproduct.dart';
import 'package:lds/View/uploadproduct.dart';
import 'package:lds/View/view_notifications.dart';
import 'package:lds/View/zatca.dart';
import 'Outbound.dart';
import 'package:lds/View/AddInvoice.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void nameemail() {
    secureStorage.read(key: 'username');
    secureStorage.read(key: 'username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[900],
        title: Text(
          "DASHBOARD",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
        ],
      ),
      drawer: const MyDrawer(companyLogoUrl: ''),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                // Background Card with elegant modern effect
                Transform.translate(
                  offset: const Offset(0, 0),
                  child: Transform.scale(
                    scale: 1.2,
                    child: Card(
                      color: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      elevation: 6,
                      child: const SizedBox(
                        width: double.infinity,
                        height: 195,
                      ),
                    ),
                  ),
                ),
                // Search Bar
                Positioned(
                  top: 20,
                  left: 8,
                  right: 8,
                  child: _buildModernSearchBar(context),
                ),
                const SizedBox(height: 280),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Status Overview',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      children: const [
                        StatusCard(label: 'Cleared', count: '1', color: Colors.green),
                        StatusCard(label: 'Pending', count: '5', color: Colors.blueGrey),
                        StatusCard(label: 'Draft', count: '2', color: Colors.deepPurple),
                        StatusCard(label: 'Error', count: '1', color: Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Invoice Overview',
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            title: Text(
                              'Invoice #${index + 1}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Status: Pending'),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                // Handle viewing invoice details
                              },
                            ),
                          ),
                        );
                      },
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

  // Build modern search bar with sleek design
  Widget _buildModernSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Search Invoices",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextFieldWithIcon(
                  context,
                  label: 'Date from',
                  icon: Icons.calendar_today,
                  isEditable: false,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextFieldWithIcon(
                  context,
                  label: 'Date to',
                  icon: Icons.calendar_today,
                  isEditable: false,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextFieldWithIcon(
                  context,
                  label: 'Document No',
                  icon: Icons.description,
                  isEditable: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Document Type',
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon: const Icon(Icons.file_present),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  items: <String>['Type A', 'Type B', 'Type C'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                // Add search functionality here
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'SEARCH',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

        // Helper method for creating text fields with icons
  Widget _buildTextFieldWithIcon(
      BuildContext context, {
        required String label,
        required IconData icon,
        bool isEditable = true,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: isEditable ? null : onTap,
      child: AbsorbPointer(
        absorbing: !isEditable,
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white60,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(count,
                style: const TextStyle(color: Colors.white, fontSize: 28)),
          ],
        ),
      ),
    );
  }
}



class MyDrawer extends StatelessWidget {
      final String? companyLogoUrl; // Add this field to accept the company's logo URL

      const MyDrawer({super.key, required this.companyLogoUrl});

      @override
      Widget build(BuildContext context) {
        return Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Updated Drawer Header with blue background
              UserAccountsDrawerHeader(
                accountName: const Text(
                  'John Doe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                accountEmail: const Text(
                  'johndoe@example.com',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    'J',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                decoration:  BoxDecoration(
                  color: Colors.blue[900], // Blue background color
                ),
              ),
              // Outbound Item
              ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text('OutBound', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DocumentPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text('Add Product', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text('Upload Product', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadProductScreen()),
                  );
                },
              ),


              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Add Invoice', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddInvoiceWizard()),
                  );
                },
              ),
              // Profile Item
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.blue),
                title: const Text('Profile', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Invoice Dashboard Item
              ListTile(
                leading: const Icon(Icons.business, color: Colors.blue),
                title: const Text('Invoice Dashboard', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.blue),
                title: const Text('Logout', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.blue),
                title: const Text('Role Management', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OSMMapWidget()),
                  );
                },
              ),
              const Divider(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: (companyLogoUrl != null && companyLogoUrl!.isNotEmpty)
                    ? Image.network(
                  companyLogoUrl!, // Use the valid logo URL
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain, // Adjust to fit your requirements
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/logo.png', // Fallback to default logo on error
                    height: 250,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                )
                    : Image.asset(
                  'assets/logo.png', // Default logo if URL is null or empty
                  height: 250,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              )


            ],
          ),
        );
      }
    }
