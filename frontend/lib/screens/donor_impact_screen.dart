import 'package:flutter/material.dart';

class DonorImpactScreen extends StatefulWidget {
  const DonorImpactScreen({super.key});

  @override
  State<DonorImpactScreen> createState() => _DonorImpactScreenState();
}

class _DonorImpactScreenState extends State<DonorImpactScreen> {
  Map<String, dynamic> impactData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImpactData();
  }

  Future<void> _loadImpactData() async {
    // TODO: Implement API call to load impact data
    setState(() {
      impactData = {
        'totalDonations': 0,
        'totalValue': 0.0,
        'peopleHelped': 0,
        'categories': <String, int>{},
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Impact'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total Impact',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                'Donations',
                                impactData['totalDonations'].toString(),
                                Icons.favorite,
                              ),
                              _buildStatCard(
                                'People Helped',
                                impactData['peopleHelped'].toString(),
                                Icons.people,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Donation Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (impactData['categories'].isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No donations yet'),
                      ),
                    )
                  else
                    ...impactData['categories'].entries.map(
                      (entry) => Card(
                        child: ListTile(
                          title: Text(entry.key),
                          trailing: Text('${entry.value} donations'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title),
      ],
    );
  }
}