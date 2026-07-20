import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);

class CategoriesSettingsScreen extends StatefulWidget {
  final String direction; // 'in' or 'out'

  const CategoriesSettingsScreen({
    super.key,
    required this.direction,
  });

  @override
  State<CategoriesSettingsScreen> createState() =>
      _CategoriesSettingsScreenState();
}

class _CategoriesSettingsScreenState
    extends State<CategoriesSettingsScreen> {
  List<Category> _categories = [];
  bool _loading = true;

  String get _title =>
      widget.direction == 'out' ? 'Expense categories' : 'Income types';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await db.getCategories(widget.direction);
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F3),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _gold))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: _green,
                    width: double.infinity,
                    padding:
                        const EdgeInsets.fromLTRB(20, 56, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back,
                              color: _gold.withOpacity(0.7),
                              size: 20),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _gold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'System categories can be renamed but not deleted.',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.4)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ..._categories.map((c) => _buildRow(c)),
                      const SizedBox(height: 16),
                      _buildAddButton(),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRow(Category c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(
                  c.isSystem ? 'System' : 'Custom',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          // Rename
          GestureDetector(
            onTap: () => _showRename(c),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Rename',
                  style: TextStyle(
                      fontSize: 11,
                      color: _green,
                      fontWeight: FontWeight.w500)),
            ),
          ),
          if (!c.isSystem) ...[
            const SizedBox(width: 8),
            // Delete (custom only)
            GestureDetector(
              onTap: () => _showDelete(c),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Delete',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: _green.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: _green, size: 16),
            const SizedBox(width: 8),
            Text('Add new',
                style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showRename(Category c) {
    final controller =
        TextEditingController(text: c.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Rename',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: _gold,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2))),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: _gold)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    await db.renameCategory(c.id, name);
                    if (mounted) {
                      Navigator.pop(ctx);
                      _load();
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Save',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _green)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdd() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add ${widget.direction == 'out' ? 'category' : 'income type'}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: _gold,
                decoration: InputDecoration(
                  hintText: widget.direction == 'out'
                      ? 'e.g. Entertainment'
                      : 'e.g. Rental income',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2))),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: _gold)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    await db.addCategory(
                        name, widget.direction, false);
                    if (mounted) {
                      Navigator.pop(ctx);
                      _load();
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Add',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _green)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDelete(Category c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _green,
        title: Text('Delete "${c.name}"?',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        content: Text(
          'This will hide the category. Existing transactions using it are not affected.',
          style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () async {
              await db.deactivateCategory(c.id);
              if (mounted) {
                Navigator.pop(context);
                _load();
              }
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}