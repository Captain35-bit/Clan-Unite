import 'package:flutter/material.dart';

import 'clan_member.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key, required this.member});

  final ClanMember member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: member.color.withOpacity(0.14),
                child: Text(member.initials, style: TextStyle(
                  color: member.color, fontSize: 30, fontWeight: FontWeight.bold,
                )),
              ),
              const SizedBox(height: 16),
              Text(member.name, textAlign: TextAlign.center, style: const TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 5),
              Text(member.role, style: TextStyle(color: member.color, fontSize: 16)),
              const SizedBox(height: 12),
              Chip(
                avatar: Icon(Icons.circle, size: 10,
                    color: member.isOnline ? Colors.green : Colors.grey),
                label: Text(member.isOnline ? 'Online' : 'Away'),
              ),
              const SizedBox(height: 24),
              _ProfileInfoTile(icon: Icons.email_outlined,
                  title: 'Email', value: member.email),
              _ProfileInfoTile(icon: Icons.location_on_outlined,
                  title: 'Location', value: member.location),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About', style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(height: 8),
                      Text(member.bio, style: TextStyle(
                        color: Colors.grey[700], height: 1.5,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(
        color: Colors.grey[600], fontSize: 12,
      )),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ),
  );
}
