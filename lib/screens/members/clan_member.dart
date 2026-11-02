import 'package:flutter/material.dart';

class ClanMember {
  const ClanMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.email,
    required this.location,
    required this.bio,
    required this.color,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String role;
  final String status;
  final String email;
  final String location;
  final String bio;
  final Color color;
  final bool isOnline;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join()
      .toUpperCase();
}

/// Preview data for the member screens; replace with clan data when available.
const sampleClanMembers = <ClanMember>[
  ClanMember(
    id: 'member-1', name: 'Alex Morgan', role: 'Clan Lead', status: 'Active',
    email: 'alex@example.test', location: 'Nairobi',
    bio: 'Helps coordinate clan activities and keep members connected.',
    color: Color(0xFF3B82F6), isOnline: true,
  ),
  ClanMember(
    id: 'member-2', name: 'Jordan Lee', role: 'Treasurer', status: 'Available',
    email: 'jordan@example.test', location: 'Kisumu',
    bio: 'Keeps an eye on shared contributions and clan finances.',
    color: Color(0xFF22A06B), isOnline: true,
  ),
  ClanMember(
    id: 'member-3', name: 'Sam Taylor', role: 'Event Coordinator', status: 'Away',
    email: 'sam@example.test', location: 'Mombasa',
    bio: 'Organizes gatherings, meetings, and community celebrations.',
    color: Color(0xFF8B5CF6), isOnline: false,
  ),
  ClanMember(
    id: 'member-4', name: 'Casey Kim', role: 'Member', status: 'Active',
    email: 'casey@example.test', location: 'Nakuru',
    bio: 'Enjoys helping members stay informed and involved.',
    color: Color(0xFFF59E0B), isOnline: true,
  ),
  ClanMember(
    id: 'member-5', name: 'Riley Chen', role: 'Member', status: 'Away',
    email: 'riley@example.test', location: 'Eldoret',
    bio: 'Shares updates and celebrates clan milestones with everyone.',
    color: Color(0xFFEC4899), isOnline: false,
  ),
];
