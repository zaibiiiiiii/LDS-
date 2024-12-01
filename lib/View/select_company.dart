import 'package:flutter/material.dart';
import 'package:lds/Models/selectcompany_model.dart';
import 'package:lds/View/dashboard.dart';
import 'package:lds/Controller/selectcompany_service.dart';

class CompanySelectionStaticPage extends StatefulWidget {
  const CompanySelectionStaticPage({super.key});

  @override
  _CompanySelectionStaticPageState createState() => _CompanySelectionStaticPageState();
}

class _CompanySelectionStaticPageState extends State<CompanySelectionStaticPage> {
  int? selectedCompanyIndex;
  List<Company> companyLogos = [];
  final SelectCompany selectCompany = SelectCompany();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    try {
      final fetchedCompanies = await selectCompany.fetchCompany();
      setState(() {
        companyLogos = fetchedCompanies.company ?? [];
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load companies. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.blue.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Title Text with bold and modern styling
                const Text(
                  "Select Your Company",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                // Loading Indicator
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (_errorMessage != null)
                // Error Message
                  Expanded(
                    child: Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                // Company Logos Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: companyLogos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCompanyIndex = index;
                              });
                            },
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: selectedCompanyIndex == index ? 1.1 : 1.0,
                              child: Card(
                                color: selectedCompanyIndex == index
                                    ? Colors.lightBlueAccent.shade100
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(companyLogos[index].logoUrl ?? ''),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      companyLogos[index].name ?? 'Unknown Company',
                                      style: TextStyle(
                                        color: selectedCompanyIndex == index ? Colors.blue : Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                // Navigate to Dashboard Button
                if (selectedCompanyIndex != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });

                        setState(() {
                          _isLoading = false;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManagementDashboard(),
                          ),
                        );
                      },

                      child: const Text(
                        "Navigate to Dashboard",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
