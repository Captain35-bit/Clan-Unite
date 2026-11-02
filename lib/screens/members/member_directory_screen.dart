import 'package:flutter/material.dart';

import 'clan_member.dart';
import 'member_profile_screen.dart';

class MemberDirectoryScreen extends StatefulWidget {
  const MemberDirectoryScreen({super.key});

  @override
  State<MemberDirectoryScreen> createState() => _MemberDirectoryScreenState();
}

class _MemberDirectoryScreenState extends State<MemberDirectoryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClanMember> get _visibleMembers {
    final query = _searchController.text.trim().toLowerCase();
    return sampleClanMembers.where((member) {
      final matchesQuery = query.isEmpty ||
          member.name.toLowerCase().contains(query) ||
          member.role.toLowerCase().contains(query) ||
          member.location.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 'All' || member.isOnline;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final members = _visibleMembers;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            tooltip: 'Invite member',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Member invites are coming soon.')),
            ),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search name, role, or location',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text('Clan directory', style: TextStyle(
                      fontSize: 21, fontWeight: FontWeight.bold,
                    )),
                  ),
                  Text('${members.length} members',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['All', 'Online'].map((filter) => ChoiceChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                )).toList(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: members.isEmpty
                    ? Center(child: Text(
                        'No members found. Try another search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ))
                    : ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: member.color.withOpacity(0.14),
                                child: Text(member.initials, style: TextStyle(
                                  color: member.color,
                                  fontWeight: FontWeight.bold,
                                )),
                              ),
                              title: Text(member.name, style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(member.role,
                                        style: TextStyle(color: member.color)),
                                    const SizedBox(height: 3),
                                    Text('${member.status} · ${member.location}'),
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => MemberProfileScreen(member: member),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 4),
              Text('Sample directory preview', style: TextStyle(
                fontSize: 12, color: Colors.grey[500],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
