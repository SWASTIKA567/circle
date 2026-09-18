import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/societies_controller.dart';
import '../models/society_model.dart';
import '../../auth/controllers/auth_controller.dart';

class SocietiesView extends GetView<SocietiesController> {
  const SocietiesView({super.key});

  static const primaryIndigo = Colors.indigo;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header & Search Area
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.indigo.shade50)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Member Status Card
                Obx(() {
                  final user = authController.currentUser.value;
                  final isSocietyMember = user?.isSocietyMember ?? false;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSocietyMember
                            ? [Colors.indigo.shade700, Colors.indigo.shade900]
                            : [Colors.indigo.shade50, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSocietyMember ? Colors.indigo.shade800 : Colors.indigo.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isSocietyMember
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.indigo.shade100,
                          child: Icon(
                            isSocietyMember ? Icons.verified_rounded : Icons.groups_rounded,
                            color: isSocietyMember ? Colors.white : primaryIndigo,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSocietyMember
                                    ? 'Verified Society Member'
                                    : 'Campus Societies & Clubs',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSocietyMember ? Colors.white : primaryIndigo,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSocietyMember
                                    ? 'You can create and manage your society with password.'
                                    : 'Explore societies, events, and recruitment links.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSocietyMember
                                      ? Colors.white.withValues(alpha: 0.85)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),

                // Search Bar
                Obx(() => TextField(
                  controller: controller.searchController,
                  onChanged: controller.updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Search societies, domains, department...',
                    hintStyle: TextStyle(color: Colors.indigo.shade200, fontSize: 13.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: primaryIndigo),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                            onPressed: controller.clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.indigo.shade50.withValues(alpha: 0.35),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo.shade100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: primaryIndigo, width: 1.8),
                    ),
                  ),
                )),
                const SizedBox(height: 10),

                // Category Chips
                Obx(() => SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = controller.categories[index];
                      final isSelected = controller.selectedCategory.value == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : primaryIndigo,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        selectedColor: primaryIndigo,
                        backgroundColor: Colors.indigo.shade50.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: isSelected ? primaryIndigo : Colors.indigo.shade100,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) controller.selectCategory(cat);
                        },
                      );
                    },
                  ),
                )),
              ],
            ),
          ),

          // Societies List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: primaryIndigo));
              }

              final filtered = controller.filteredSocieties;
              if (filtered.isEmpty) {
                return RefreshIndicator(
                  color: primaryIndigo,
                  onRefresh: controller.fetchSocieties,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.groups_outlined, size: 52, color: primaryIndigo.shade400),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchQuery.value.trim().isNotEmpty
                                  ? 'No societies matching "${controller.searchQuery.value.trim()}"'
                                  : 'No societies listed yet',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              authController.currentUser.value?.isSocietyMember == true
                                  ? 'Tap "+ Create Society" below to register your club.'
                                  : 'Societies and campus clubs will appear here.',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                            if (controller.searchQuery.value.trim().isNotEmpty) ...[
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryIndigo,
                                  side: const BorderSide(color: primaryIndigo),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Clear Search'),
                                onPressed: controller.clearSearch,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryIndigo,
                onRefresh: controller.fetchSocieties,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final soc = filtered[index];
                    return _buildSocietyCard(context, soc, authController);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Society', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _handleCreateSocietyPressed(context, authController),
      ),
    );
  }

  void _handleCreateSocietyPressed(BuildContext context, AuthController authController) {
    final user = authController.currentUser.value;
    final isSocietyMember = user?.isSocietyMember ?? false;

    if (!isSocietyMember) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              const Text('Member Only', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Only verified society members can create and manage societies.\n\n'
            'Non-members can explore and view all society details, events, and recruitment links.',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Got it', style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    _showCreateSocietyModal(context);
  }

  Widget _buildSocietyCard(
    BuildContext context,
    SocietyModel soc,
    AuthController authController,
  ) {
    final user = authController.currentUser.value;
    final isSocietyMember = user?.isSocietyMember ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      soc.name.isNotEmpty ? soc.name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        soc.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              soc.department,
                              style: const TextStyle(
                                fontSize: 11,
                                color: primaryIndigo,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              soc.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              soc.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
            ),
            const SizedBox(height: 10),

            // Domains Chips
            if (soc.domains.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: soc.domains.take(4).map((d) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Upcoming Event banner if exists
            if (soc.upcomingEvents.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, size: 16, color: Colors.amber.shade900),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Upcoming: ${soc.upcomingEvents.first.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            Row(
              children: [
                // Non-members & Members can view
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryIndigo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () => _showSocietyDetailsModal(context, soc),
                  ),
                ),

                // Members with password can edit
                if (isSocietyMember) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryIndigo,
                      side: const BorderSide(color: primaryIndigo),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    icon: const Icon(Icons.lock_outline_rounded, size: 15),
                    label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () => _promptSocietyPasswordAndEdit(context, soc),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- View Details Modal (For All Students) ---
  void _showSocietyDetailsModal(BuildContext context, SocietyModel soc) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Department
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        soc.name.isNotEmpty ? soc.name[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryIndigo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          soc.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                soc.department,
                                style: const TextStyle(fontSize: 11, color: primaryIndigo, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                soc.category,
                                style: TextStyle(fontSize: 11, color: Colors.purple.shade700, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              const Text('About Society', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                soc.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Domains
              if (soc.domains.isNotEmpty) ...[
                const Text('Domains & Focus Areas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: soc.domains.map((d) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(fontSize: 12, color: primaryIndigo, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
              ],

              // External Links (Website & Registration)
              if (soc.websiteLink.isNotEmpty || soc.registrationLink.isNotEmpty) ...[
                const Text('Official Links', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (soc.websiteLink.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryIndigo,
                            side: const BorderSide(color: primaryIndigo),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.language_rounded, size: 18),
                          label: const Text('Website'),
                          onPressed: () => controller.launchExternalUrl(soc.websiteLink),
                        ),
                      ),
                    if (soc.websiteLink.isNotEmpty && soc.registrationLink.isNotEmpty)
                      const SizedBox(width: 10),
                    if (soc.registrationLink.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                          label: const Text('Join / Register'),
                          onPressed: () => controller.launchExternalUrl(soc.registrationLink),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // Upcoming Events
              if (soc.upcomingEvents.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.upcoming_rounded, size: 18, color: Colors.amber.shade800),
                    const SizedBox(width: 6),
                    const Text('Upcoming Events', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                ...soc.upcomingEvents.map((evt) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              evt.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            if (evt.date.isNotEmpty)
                              Text(
                                evt.date,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                              ),
                          ],
                        ),
                        if (evt.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(evt.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                        ],
                        if (evt.registrationLink.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: primaryIndigo,
                                padding: EdgeInsets.zero,
                              ),
                              icon: const Icon(Icons.open_in_new_rounded, size: 14),
                              label: const Text('Register for Event', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () => controller.launchExternalUrl(evt.registrationLink),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
              ],

              // Recent Events
              if (soc.recentEvents.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.history_edu_rounded, size: 18, color: Colors.indigo.shade700),
                    const SizedBox(width: 6),
                    const Text('Past / Recent Events', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                ...soc.recentEvents.map((evt) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              evt.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            if (evt.date.isNotEmpty)
                              Text(evt.date, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                        if (evt.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(evt.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Password Prompt to Edit Society ---
  void _promptSocietyPasswordAndEdit(BuildContext context, SocietyModel soc) {
    final passwordController = TextEditingController();
    final isPasswordHidden = true.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: primaryIndigo),
            const SizedBox(width: 8),
            const Text('Society Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the password for "${soc.name}" to edit details, events, and links.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            Obx(() => TextField(
              controller: passwordController,
              obscureText: isPasswordHidden.value,
              decoration: InputDecoration(
                hintText: 'Enter society password',
                prefixIcon: const Icon(Icons.key_rounded, color: primaryIndigo),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.grey,
                  ),
                  onPressed: () => isPasswordHidden.toggle(),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.indigo.shade100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.indigo.shade100),
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final pass = passwordController.text.trim();
              if (pass.isEmpty) {
                Get.snackbar('Password Required', 'Please enter society password.');
                return;
              }

              Get.back(); // close password dialog
              final verified = await controller.verifySocietyPassword(soc.id, pass);
              if (verified && context.mounted) {
                _showEditSocietyModal(context, soc, pass);
              }
            },
            child: const Text('Verify & Edit'),
          ),
        ],
      ),
    );
  }

  // --- Create Society Modal (Mandatory & Optional Fields) ---
  void _showCreateSocietyModal(BuildContext context) {
    final nameController = TextEditingController();
    final deptController = TextEditingController();
    final descController = TextEditingController();
    final passwordController = TextEditingController();
    final websiteController = TextEditingController();
    final registrationController = TextEditingController();
    final domainsController = TextEditingController();
    final logoController = TextEditingController();

    // Initial Upcoming Event
    final upcomingTitleController = TextEditingController();
    final upcomingDateController = TextEditingController();
    final upcomingLinkController = TextEditingController();
    final upcomingDescController = TextEditingController();

    // Initial Recent Event
    final recentTitleController = TextEditingController();
    final recentDateController = TextEditingController();
    final recentDescController = TextEditingController();

    final selectedCategory = 'Technical'.obs;
    final isPasswordHidden = true.obs;

    final categories = ['Technical', 'Cultural', 'Literary', 'Sports', 'General'];

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_business_rounded, color: primaryIndigo),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Create New Society',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- Mandatory Fields Section ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 6),
                        const Text(
                          'Mandatory Details',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Society Name *
                    _buildTextField(
                      controller: nameController,
                      label: 'Society Name *',
                      hint: 'e.g. Google Developer Student Club',
                    ),
                    const SizedBox(height: 10),

                    // Department *
                    _buildTextField(
                      controller: deptController,
                      label: 'Department *',
                      hint: 'e.g. Computer Science / IT / General',
                    ),
                    const SizedBox(height: 10),

                    // Description *
                    _buildTextField(
                      controller: descController,
                      label: 'Description *',
                      hint: 'Brief summary of the society purpose and activities...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),

                    // Society Password *
                    const Text(
                      'Society Password * (for future edits)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => TextField(
                      controller: passwordController,
                      obscureText: isPasswordHidden.value,
                      decoration: InputDecoration(
                        hintText: 'Set a password (min 4 characters)',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.lock_rounded, color: primaryIndigo, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => isPasswordHidden.toggle(),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.indigo.shade100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.indigo.shade100),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Optional Details Section ---
              const Text('Optional Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Category Selector
              const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory.value,
                    isExpanded: true,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) selectedCategory.value = v;
                    },
                  ),
                ),
              )),
              const SizedBox(height: 10),

              // Website link
              _buildTextField(
                controller: websiteController,
                label: 'Website Link',
                hint: 'e.g. https://gdsc-college.org',
              ),
              const SizedBox(height: 10),

              // Registration / Join link
              _buildTextField(
                controller: registrationController,
                label: 'Registration / Join Link',
                hint: 'e.g. https://forms.gle/recruitment',
              ),
              const SizedBox(height: 10),

              // Domains
              _buildTextField(
                controller: domainsController,
                label: 'Domains / Focus Areas (comma separated)',
                hint: 'e.g. Web Development, AI/ML, Cloud, Design',
              ),
              const SizedBox(height: 10),

              // Logo URL
              _buildTextField(
                controller: logoController,
                label: 'Logo URL (optional)',
                hint: 'https://...',
              ),
              const SizedBox(height: 16),

              // Upcoming Event (Optional)
              ExpansionTile(
                title: const Text('Add Upcoming Event (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                tilePadding: EdgeInsets.zero,
                children: [
                  _buildTextField(controller: upcomingTitleController, label: 'Event Title', hint: 'e.g. Hackathon 2026'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: upcomingDateController, label: 'Event Date', hint: 'e.g. 25 Oct 2026'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: upcomingLinkController, label: 'Registration Link', hint: 'https://...'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: upcomingDescController, label: 'Description', hint: 'Brief about the event...'),
                  const SizedBox(height: 10),
                ],
              ),

              // Recent Event (Optional)
              ExpansionTile(
                title: const Text('Add Recent / Past Event (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                tilePadding: EdgeInsets.zero,
                children: [
                  _buildTextField(controller: recentTitleController, label: 'Event Title', hint: 'e.g. Annual Tech Summit'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: recentDateController, label: 'Event Date', hint: 'e.g. 15 Jan 2026'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: recentDescController, label: 'Summary', hint: 'Brief summary of achievements...'),
                  const SizedBox(height: 10),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar('Name Required', 'Please enter society name.');
                            return;
                          }
                          if (deptController.text.trim().isEmpty) {
                            Get.snackbar('Department Required', 'Please enter department.');
                            return;
                          }
                          if (descController.text.trim().isEmpty) {
                            Get.snackbar('Description Required', 'Please enter society description.');
                            return;
                          }
                          if (passwordController.text.trim().length < 4) {
                            Get.snackbar('Password Required', 'Society password must be at least 4 characters.');
                            return;
                          }

                          // Process domains
                          final domainList = domainsController.text
                              .split(',')
                              .map((d) => d.trim())
                              .where((d) => d.isNotEmpty)
                              .toList();

                          // Process events
                          List<SocietyEventModel> upcoming = [];
                          if (upcomingTitleController.text.trim().isNotEmpty) {
                            upcoming.add(SocietyEventModel(
                              title: upcomingTitleController.text.trim(),
                              date: upcomingDateController.text.trim(),
                              registrationLink: upcomingLinkController.text.trim(),
                              description: upcomingDescController.text.trim(),
                            ));
                          }

                          List<SocietyEventModel> recent = [];
                          if (recentTitleController.text.trim().isNotEmpty) {
                            recent.add(SocietyEventModel(
                              title: recentTitleController.text.trim(),
                              date: recentDateController.text.trim(),
                              description: recentDescController.text.trim(),
                            ));
                          }

                          final success = await controller.createSociety(
                            name: nameController.text.trim(),
                            department: deptController.text.trim(),
                            description: descController.text.trim(),
                            societyPassword: passwordController.text.trim(),
                            websiteLink: websiteController.text.trim(),
                            registrationLink: registrationController.text.trim(),
                            logoUrl: logoController.text.trim(),
                            domains: domainList,
                            upcomingEvents: upcoming,
                            recentEvents: recent,
                            category: selectedCategory.value,
                          );

                          if (success) {
                            Get.back(); // close modal
                          }
                        },
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Register Society', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Edit Society Modal (Protected with Society Password) ---
  void _showEditSocietyModal(BuildContext context, SocietyModel soc, String currentPassword) {
    final descController = TextEditingController(text: soc.description);
    final deptController = TextEditingController(text: soc.department);
    final websiteController = TextEditingController(text: soc.websiteLink);
    final registrationController = TextEditingController(text: soc.registrationLink);
    final domainsController = TextEditingController(text: soc.domains.join(', '));
    final newPasswordController = TextEditingController();

    // Event additions
    final eventTitleController = TextEditingController();
    final eventDateController = TextEditingController();
    final eventLinkController = TextEditingController();
    final eventDescController = TextEditingController();
    final isUpcoming = true.obs;

    final selectedCategory = soc.category.obs;
    final categories = ['Technical', 'Cultural', 'Literary', 'Sports', 'General'];

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: primaryIndigo),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit "${soc.name}"',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(controller: deptController, label: 'Department', hint: 'e.g. CSE'),
              const SizedBox(height: 10),

              _buildTextField(controller: descController, label: 'Description', hint: 'About society...', maxLines: 3),
              const SizedBox(height: 10),

              // Category
              const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory.value,
                    isExpanded: true,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) selectedCategory.value = v;
                    },
                  ),
                ),
              )),
              const SizedBox(height: 10),

              _buildTextField(controller: websiteController, label: 'Website Link', hint: 'https://...'),
              const SizedBox(height: 10),

              _buildTextField(controller: registrationController, label: 'Join / Recruitment Link', hint: 'https://...'),
              const SizedBox(height: 10),

              _buildTextField(controller: domainsController, label: 'Domains (comma separated)', hint: 'Web, AI, Cloud'),
              const SizedBox(height: 16),

              // Add an event
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add an Event', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Obx(() => Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Upcoming Event'),
                          selected: isUpcoming.value,
                          onSelected: (_) => isUpcoming.value = true,
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Past / Recent Event'),
                          selected: !isUpcoming.value,
                          onSelected: (_) => isUpcoming.value = false,
                        ),
                      ],
                    )),
                    const SizedBox(height: 8),
                    _buildTextField(controller: eventTitleController, label: 'Event Title', hint: 'e.g. TechSprint 2026'),
                    const SizedBox(height: 8),
                    _buildTextField(controller: eventDateController, label: 'Date', hint: 'e.g. 15 Nov 2026'),
                    const SizedBox(height: 8),
                    Obx(() => isUpcoming.value
                        ? _buildTextField(controller: eventLinkController, label: 'Registration Link', hint: 'https://...')
                        : const SizedBox.shrink()),
                    const SizedBox(height: 8),
                    _buildTextField(controller: eventDescController, label: 'Description', hint: 'Details...'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Change Society Password
              _buildTextField(
                controller: newPasswordController,
                label: 'Change Society Password (Optional)',
                hint: 'Leave blank to keep existing password',
              ),
              const SizedBox(height: 20),

              // Submit Update
              Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          final domainList = domainsController.text
                              .split(',')
                              .map((d) => d.trim())
                              .where((d) => d.isNotEmpty)
                              .toList();

                          // Append new event if filled
                          List<SocietyEventModel> updatedUpcoming = List.from(soc.upcomingEvents);
                          List<SocietyEventModel> updatedRecent = List.from(soc.recentEvents);

                          if (eventTitleController.text.trim().isNotEmpty) {
                            final newEvent = SocietyEventModel(
                              title: eventTitleController.text.trim(),
                              date: eventDateController.text.trim(),
                              registrationLink: eventLinkController.text.trim(),
                              description: eventDescController.text.trim(),
                            );

                            if (isUpcoming.value) {
                              updatedUpcoming.add(newEvent);
                            } else {
                              updatedRecent.add(newEvent);
                            }
                          }

                          final success = await controller.updateSociety(
                            societyId: soc.id,
                            societyPassword: currentPassword,
                            department: deptController.text.trim(),
                            description: descController.text.trim(),
                            category: selectedCategory.value,
                            websiteLink: websiteController.text.trim(),
                            registrationLink: registrationController.text.trim(),
                            domains: domainList,
                            upcomingEvents: updatedUpcoming,
                            recentEvents: updatedRecent,
                            newSocietyPassword: newPasswordController.text.trim().isNotEmpty
                                ? newPasswordController.text.trim()
                                : null,
                          );

                          if (success) {
                            Get.back(); // close modal
                          }
                        },
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryIndigo, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
