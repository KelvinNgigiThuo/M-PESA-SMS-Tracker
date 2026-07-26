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

  bool get _isIncome => widget.direction == 'in';

  String get _title => _isIncome ? 'Income types' : 'Expense categories';

  List<Category> get _trueIncome =>
      _categories.where((c) => c.group == 'true_income').toList();

  List<Category> get _otherIncome =>
      _categories.where((c) => c.group != 'true_income').toList();

  List<Category> get _topLevel =>
      _categories.where((c) => c.parentId == null).toList();

  List<Category> _childrenOf(int parentId) =>
      _categories.where((c) => c.parentId == parentId).toList();

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
                          'Add, rename or remove any of these freely.',
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
                    delegate: SliverChildListDelegate(
                      _isIncome ? _buildIncomeSections() : _buildExpenseList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildExpenseList() {
    final widgets = <Widget>[];
    for (final parent in _topLevel) {
      final children = _childrenOf(parent.id);
      widgets.add(_buildRow(parent));
      for (final child in children) {
        widgets.add(_buildRow(child, indent: true));
      }
      widgets.add(const SizedBox(height: 4));
      widgets.add(_buildAddButton('Add subcategory to ${parent.name}',
          parentId: parent.id));
      widgets.add(const SizedBox(height: 16));
    }
    widgets.add(_buildAddButton('Add category', group: null));
    return widgets;
  }

  List<Widget> _buildIncomeSections() {
    return [
      _sectionTitle('True income'),
      ..._trueIncome.map((c) => _buildRow(c)),
      const SizedBox(height: 8),
      _buildAddButton('Add true income type', group: 'true_income'),
      const SizedBox(height: 20),
      _sectionTitle('Other'),
      ..._otherIncome.map((c) => _buildRow(c)),
      const SizedBox(height: 8),
      _buildAddButton('Add other income type', group: 'other'),
    ];
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildRow(Category c, {bool indent = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 6, left: indent ? 20 : 0),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: indent ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(c.name,
                style: TextStyle(
                    fontSize: indent ? 12 : 13,
                    fontWeight: FontWeight.w500)),
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
          const SizedBox(width: 8),
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
      ),
    );
  }

  Widget _buildAddButton(String label, {String? group, int? parentId}) {
    return GestureDetector(
      onTap: () => _showAdd(group: group, parentId: parentId),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(left: parentId != null ? 20 : 0),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: _green.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: _green, size: 15),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: _green,
                    fontSize: 12,
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

  void _showAdd({String? group, int? parentId}) {
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
              Text(
                  parentId != null
                      ? 'Add subcategory'
                      : 'Add ${widget.direction == 'out' ? 'category' : 'income type'}',
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
                  hintText: parentId != null
                      ? 'e.g. Breakfast'
                      : widget.direction == 'out'
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
                        name, widget.direction, false,
                        group: group, parentId: parentId);
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
    final children = c.parentId == null ? _childrenOf(c.id) : <Category>[];
    final hasChildren = children.isNotEmpty;

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
          hasChildren
              ? 'This will hide the category and its ${children.length} subcategories. Existing transactions using them are not affected.'
              : 'This will hide the category. Existing transactions using it are not affected.',
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
              if (hasChildren) {
                await db.deactivateCategoryAndChildren(c.id);
              } else {
                await db.deactivateCategory(c.id);
              }
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
