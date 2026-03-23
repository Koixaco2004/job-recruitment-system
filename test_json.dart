void main() {
  final Map<String, dynamic> json = {
    "id": 3,
    "userId": 3,
    "fullName": "Ta Vu",
    "gender": null,
    "phone": "0123456789",
    "avatarUrl": null,
    "cvUrl": null,
    "bio": null,
    "provinceId": 79,
    "position": null,
    "salaryMin": null,
    "salaryMax": null,
    "jobTypeId": null,
    "yearWorkingExperience": null
  };

  try {
    final candidateId = json['candidate_id'] ?? json['id'] ?? json['candidateId'] ?? 0;
    final userId = json['user_id'] ?? json['userId'] ?? 0;
    final email = json['email'] ?? '';
    final phone = json['phone'] as String?;
    final fullName = json['full_name'] ?? json['fullName'] ?? '';
    final avatarUrl = json['avatar_url'] ?? json['avatarUrl'] as String?;
    
    final dateOfBirth = (json['date_of_birth'] ?? json['dateOfBirth']) != null
        ? DateTime.parse(json['date_of_birth'] ?? json['dateOfBirth'])
        : null;
        
    final gender = json['gender'] as String?;
    final address = json['address'] as String?;
    final cityName = json['city_name'] ?? json['cityName'] as String?;
    final educationLevel = json['education_level'] ?? json['educationLevel'] as String?;
    final yearsOfExperience = json['years_of_experience'] ?? json['yearWorkingExperience'] ?? json['yearsOfExperience'] ?? 0;
    final currentJobTitle = json['current_job_title'] ?? json['currentJobTitle'] as String?;
    final desiredJobTitle = json['desired_job_title'] ?? json['position'] ?? json['desiredJobTitle'] as String?;
    final desiredSalaryMin = json['desired_salary_min'] ?? json['salaryMin'] ?? json['desiredSalaryMin'] as int?;
    final desiredSalaryMax = json['desired_salary_max'] ?? json['salaryMax'] ?? json['desiredSalaryMax'] as int?;
    final desiredJobType = json['desired_job_type'] ?? json['jobType'] ?? json['desiredJobType'] as String?;
    
    final skills = json['skills'] != null ? List<String>.from(json['skills']) : [];
    final cvFileUrl = json['cv_file_url'] ?? json['cvUrl'] ?? json['cvFileUrl'] as String?;
    final industry = json['industry'] as String?;
    final isSearchable = json['is_searchable'] ?? json['isSearchable'] ?? false;
    
    final workExperiences = json['work_experiences'] ?? json['workExperiences'] != null
        ? (json['work_experiences'] ?? json['workExperiences'] as List)
              .map((e) => e.toString())
              .toList()
        : [];
        
    final createdAt = (json['created_at'] ?? json['createdAt']) != null ? DateTime.parse(json['created_at'] ?? json['createdAt']) : DateTime.now();
    final updatedAt = (json['updated_at'] ?? json['updatedAt']) != null ? DateTime.parse(json['updated_at'] ?? json['updatedAt']) : DateTime.now();

    print("Success!");
    print("userId: $userId");
    print("email: $email");
    print("fullName: $fullName");
    print("phone: $phone");
  } catch (e, stackTrace) {
    print("Error: $e");
    print(stackTrace);
  }
}
