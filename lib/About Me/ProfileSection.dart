class ProfileSection {

  final String title;
  final List<String> bullets;
  ProfileSection(this.title, this.bullets);
}

final List<ProfileSection> profileSections = [
  ProfileSection("Core Skills", [
    "Mobile: Swift, Kotlin, Objective-C, Java, Xamarin, Cordova",
    "Web: Angular, TypeScript, ASP.NET, JavaScript, HTML/CSS",
    "Backend: C#, Java, REST APIs, Azure",
    "CI/CD & DevOps: Git, GitLab, Azure DevOps, Automation",
    "Databases: SQL Server, MySQL, SQLite",
    "Tools: Xcode, Android Studio, Visual Studio, Jira",
    "Methodologies: Agile, Scrum, TDD",
  ]),
  ProfileSection("Notable Projects", [
    "📱 Standard Bank & Stanbic App (iOS/Android)",
    "📱 Discovery Health App (iOS)",
    "📱 Absa Bank App – Global Pay & PayShap integration",
  ]),
  ProfileSection("Certifications", [
    "MCPD: Windows Phone Developer",
    "MCTS: .NET, Silverlight, SharePoint",
  ]),
];
