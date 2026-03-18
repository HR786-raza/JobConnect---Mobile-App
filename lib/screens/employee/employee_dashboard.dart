import 'package:flutter/material.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/widgets/category_chip.dart';
import 'package:jobconnect/widgets/job_card.dart';
import 'package:jobconnect/widgets/search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final List<String> categories = [
    'All',
    'Internship',
    'Full Time',
    'Part Time',
    'Remote',
  ];

  final List<Map<String, dynamic>> featuredJobs = [
    {
      'title': 'Flutter Developer',
      'company': 'Tech Corp',
      'location': 'New York, NY',
      'salary': '\$120k - \$150k',
      'type': 'Full Time',
      'logo': Icons.code,
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Design Studio',
      'location': 'San Francisco, CA',
      'salary': '\$90k - \$120k',
      'type': 'Full Time',
      'logo': Icons.design_services,
    },
    {
      'title': 'Product Manager',
      'company': 'Startup Inc',
      'location': 'Remote',
      'salary': '\$130k - \$160k',
      'type': 'Full Time',
      'logo': Icons.business_center,
    },
  ];

  final List<Map<String, dynamic>> recommendedJobs = [
    {
      'title': 'Senior Flutter Developer',
      'company': 'Google',
      'location': 'Mountain View, CA',
      'salary': '\$150k - \$200k',
      'type': 'Full Time',
      'logo': Icons.code,
      'matchPercentage': 95,
    },
    {
      'title': 'Mobile App Developer',
      'company': 'Apple',
      'location': 'Cupertino, CA',
      'salary': '\$140k - \$180k',
      'type': 'Full Time',
      'logo': Icons.phone_android,
      'matchPercentage': 88,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        user?.displayName?.split(' ')[0] ?? 'Hassan',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      CircleAvatar(
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Text(user?.email?[0].toUpperCase() ?? 'H')
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const CustomSearchBar(),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryChip(
                      label: categories[index],
                      isSelected: index == 0,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Jobs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredJobs.length,
                  itemBuilder: (context, index) {
                    return JobCard(
                      job: featuredJobs[index],
                      isFeatured: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendedJobs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: JobCard(
                      job: recommendedJobs[index],
                      showMatchPercentage: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Resume',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.jobSearch);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.resumeBuilder);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.chat);
              break;
            case 4:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
      ),
    );
  }
}