class RoleManagementResponse {
  final List<Role> roles;
  final List<Branch> branches;

  RoleManagementResponse({required this.roles, required this.branches});

  factory RoleManagementResponse.fromJson(Map<String, dynamic> json) {
    return RoleManagementResponse(
      roles: (json['role'] as List).map((e) => Role.fromJson(e)).toList(),
      branches: (json['branch'] as List).map((e) => Branch.fromJson(e)).toList(),
    );
  }
}

class Role {
  final String role;
  final String description;
  final int noOfAssignedUsers;

  Role({
    required this.role,
    required this.description,
    required this.noOfAssignedUsers,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      role: json['Role'],
      description: json['Description'],
      noOfAssignedUsers: json['No_of_Assign_User'],
    );
  }
}

class Branch {
  final String branchCode;
  final String branchDescription;
  final String branchType;
  final int assignedUsers;

  Branch({
    required this.branchCode,
    required this.branchDescription,
    required this.branchType,
    required this.assignedUsers,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchCode: json['BRANCH_CODE'],
      branchDescription: json['BRANCH_DESCRIPTION'],
      branchType: json['BRANCH_TYPE'],
      assignedUsers: json['ASSIGN_USER'],
    );
  }
}
