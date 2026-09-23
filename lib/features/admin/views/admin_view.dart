import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../notes/controllers/notes_controller.dart';
import '../../notes/models/note_model.dart';
import '../../societies/controllers/societies_controller.dart';
import '../../societies/models/society_model.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  static const primaryIndigo = Colors.indigo;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    final notesController = Get.isRegistered<NotesController>()
        ? Get.find<NotesController>()
        : Get.put(NotesController());
    final societiesController = Get.isRegistered<SocietiesController>()
        ? Get.find<SocietiesController>()
        : Get.put(SocietiesController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: primaryIndigo,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Management Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Review & approve notes and societies',
                style: TextStyle(
                  color: Color(0xFFC7D2FE),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Refresh queue',
              onPressed: controller.fetchAllPending,
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.indigo.shade200,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Obx(() => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 16),
                        const SizedBox(width: 6),
                        const Text('Notes'),
                        if (controller.pendingNotes.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.pendingNotes.length}',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),
              Obx(() => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.groups_rounded, size: 16),
                        const SizedBox(width: 6),
                        const Text('Societies'),
                        if (controller.pendingSocieties.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.pendingSocieties.length}',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),
              const Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, size: 16),
                    SizedBox(width: 6),
                    Text('Overview'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: primaryIndigo));
          }

          return TabBarView(
            children: [
              _buildPendingNotesTab(context, controller, notesController),
              _buildPendingSocietiesTab(context, controller, societiesController),
              _buildOverviewTab(context, controller),
            ],
          );
        }),
      ),
    );
  }

  // --- TAB 1: PENDING NOTES ---
  Widget _buildPendingNotesTab(
    BuildContext context,
    AdminController controller,
    NotesController notesController,
  ) {
    if (controller.pendingNotes.isEmpty) {
      return RefreshIndicator(
        color: primaryIndigo,
        onRefresh: controller.fetchAllPending,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.22),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_outline_rounded,
                        size: 56, color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All Caught Up!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No pending notes awaiting approval.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryIndigo,
      onRefresh: controller.fetchAllPending,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: controller.pendingNotes.length,
        itemBuilder: (context, index) {
          final note = controller.pendingNotes[index];
          return _buildPendingNoteCard(context, note, controller, notesController);
        },
      ),
    );
  }

  Widget _buildPendingNoteCard(
    BuildContext context,
    NoteModel note,
    AdminController controller,
    NotesController notesController,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            // Status tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 12, color: Colors.amber.shade900),
                      const SizedBox(width: 4),
                      Text(
                        'Awaiting Approval',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  note.pages,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Note Title & Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded by: ${note.author}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Subject / Unit / Semester tags
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note.subject,
                    style: const TextStyle(
                        fontSize: 11, color: primaryIndigo, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note.unit,
                    style: TextStyle(
                        fontSize: 11, color: Colors.purple.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note.semester,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Action Buttons: Preview, Approve, Reject
            Row(
              children: [
                // Preview PDF Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryIndigo,
                    side: const BorderSide(color: primaryIndigo),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('Preview PDF', style: TextStyle(fontSize: 12)),
                  onPressed: () => notesController.openNotePdf(note),
                ),
                const Spacer(),

                // Reject Button
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Reject Note',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        content: Text('Are you sure you want to reject "${note.title}"?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () {
                              Get.back();
                              controller.rejectNote(note.id);
                            },
                            child: const Text('Reject & Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),

                // Approve Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => controller.approveNote(note.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: PENDING SOCIETIES ---
  Widget _buildPendingSocietiesTab(
    BuildContext context,
    AdminController controller,
    SocietiesController societiesController,
  ) {
    if (controller.pendingSocieties.isEmpty) {
      return RefreshIndicator(
        color: primaryIndigo,
        onRefresh: controller.fetchAllPending,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.22),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_outlined, size: 56, color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Pending Societies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All society registrations are reviewed.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryIndigo,
      onRefresh: controller.fetchAllPending,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: controller.pendingSocieties.length,
        itemBuilder: (context, index) {
          final soc = controller.pendingSocieties[index];
          return _buildPendingSocietyCard(context, soc, controller, societiesController);
        },
      ),
    );
  }

  Widget _buildPendingSocietyCard(
    BuildContext context,
    SocietyModel soc,
    AdminController controller,
    SocietiesController societiesController,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            // Status tag
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 12, color: Colors.amber.shade900),
                      const SizedBox(width: 4),
                      Text(
                        'Awaiting Approval',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Created by: ${soc.createdByName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Society Header
            Row(
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
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${soc.department} • ${soc.category}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
            ),
            const SizedBox(height: 10),

            // Domains
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
                    child: Text(d, style: TextStyle(fontSize: 11, color: Colors.grey.shade800)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            const Divider(height: 1),
            const SizedBox(height: 12),

            // Action Buttons: Reject, Approve
            Row(
              children: [
                // Links preview if available
                if (soc.websiteLink.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.language_rounded, size: 20, color: primaryIndigo),
                    tooltip: 'Visit Website',
                    onPressed: () => societiesController.launchExternalUrl(soc.websiteLink),
                  ),
                if (soc.registrationLink.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.link_rounded, size: 20, color: Colors.green),
                    tooltip: 'Join Link',
                    onPressed: () => societiesController.launchExternalUrl(soc.registrationLink),
                  ),
                const Spacer(),

                // Reject Button
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Reject Society',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        content: Text('Are you sure you want to reject "${soc.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () {
                              Get.back();
                              controller.rejectSociety(soc.id);
                            },
                            child: const Text('Reject & Remove'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),

                // Approve Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => controller.approveSociety(soc.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: OVERVIEW / STATS ---
  Widget _buildOverviewTab(BuildContext context, AdminController controller) {
    final stats = controller.stats;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'System Status & Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 14),

        // Grid of Stats
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                title: 'Pending Notes',
                value: '${stats['pendingNotes'] ?? controller.pendingNotes.length}',
                color: Colors.amber.shade700,
                icon: Icons.pending_actions_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatTile(
                title: 'Approved Notes',
                value: '${stats['totalNotes'] ?? '0'}',
                color: Colors.green.shade600,
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                title: 'Pending Societies',
                value: '${stats['pendingSocieties'] ?? controller.pendingSocieties.length}',
                color: Colors.orange.shade700,
                icon: Icons.group_add_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatTile(
                title: 'Active Societies',
                value: '${stats['totalSocieties'] ?? '0'}',
                color: primaryIndigo,
                icon: Icons.groups_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatTile(
          title: 'Registered Users & Students',
          value: '${stats['totalUsers'] ?? '0'}',
          color: Colors.purple.shade700,
          icon: Icons.people_outline_rounded,
        ),
        const SizedBox(height: 20),

        // Admin guide card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: primaryIndigo, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Admin Workflow Guidelines',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryIndigo),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '• All new notes uploaded by students require manual review before appearing in the app.\n'
                '• You can preview PDFs directly to verify educational quality and appropriateness.\n'
                '• Society registrations are held in the pending queue until approved by an administrator.\n'
                '• Normal users have zero visibility of this Admin Panel or unapproved items.',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
