import 'package:flutter/material.dart';
import 'package:lds/Controller/rolemanage_service.dart';
import 'package:lds/Models/rolemanage_model.dart';

class RolesAndBranchesScreen extends StatefulWidget {
  const RolesAndBranchesScreen({super.key});

  @override
  _RolesAndBranchesScreenState createState() => _RolesAndBranchesScreenState();
}

class _RolesAndBranchesScreenState extends State<RolesAndBranchesScreen> {
  late Future<RoleManagementResponse> _roleManagementData;

  @override
  void initState() {
    super.initState();
    _roleManagementData = RoleManagementService().fetchRoleManagementData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,

      ),
      body: FutureBuilder<RoleManagementResponse>(
        future: _roleManagementData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: Colors.blueAccent,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.group), text: 'Roles'),
                      Tab(icon: Icon(Icons.location_city), text: 'Branches'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildRolesTab(data.roles),
                        _buildBranchesTab(data.branches),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Widget _buildRolesTab(List<Role> roles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Role',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Add Role functionality
                  print('Add Role Button Pressed');
                },

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.file_download),
                label: const Text(
                  'Excel File',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Download Excel functionality
                  print('Download Excel File Button Pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueAccent),
              columns: const [
                DataColumn(label: Text('Role', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Description', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('No. of Assigned Users', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
              ],
              rows: roles.map((role) {
                return DataRow(cells: [
                  DataCell(Text(role.role, style: const TextStyle(fontSize: 16))),
                  DataCell(Text(role.description, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
                  DataCell(Text(role.noOfAssignedUsers.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 14)),
                      onPressed: () {
                        // Add edit functionality
                        print('Edit Role: ${role.role}');
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchesTab(List<Branch> branches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Branch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  print('Add Branch Button Pressed');
                },

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.file_download),
                label: const Text(
                  'Excel File',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Download Excel functionality
                  print('Download Excel File Button Pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueAccent),
              columns: const [
                DataColumn(label: Text('Branch Code', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Branch Description', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Branch Type', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Assign User', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
              ],
              rows: branches.map((branch) {
                return DataRow(cells: [
                  DataCell(Text(branch.branchCode, style: const TextStyle(fontSize: 16))),
                  DataCell(Text(branch.branchDescription, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
                  DataCell(Text(branch.branchType, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(branch.assignedUsers.toString(), style: const TextStyle(fontSize: 14))),
                  DataCell(
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add, size: 16),
                          label: const Text('Assign', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            // Add Assign User functionality
                            print('Assign User to Branch: ${branch.branchCode}');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green,foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_remove, size: 16),
                          label: const Text('Revoke', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            // Add Revoke User functionality
                            print('Revoke User from Branch: ${branch.branchCode}');
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red,foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
