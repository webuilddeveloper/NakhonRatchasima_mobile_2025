import 'package:flutter/material.dart';
import 'package:ratchasima/component/header.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/key_search.dart';
import 'package:ratchasima/shared/api_provider.dart' as service;

import 'knowledge_list_vertical.dart' as grid;

import 'package:pull_to_refresh/pull_to_refresh.dart';

class KnowledgeList extends StatefulWidget {
  const KnowledgeList({super.key, this.title});
  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _KnowledgeList createState() => _KnowledgeList();
}

class _KnowledgeList extends State<KnowledgeList> {
  grid.KnowledgeListVertical? gridView;
  final txtDescription = TextEditingController();
  bool hideSearch = true;
  String? keySearch;
  String? category;
  late Future<dynamic> _futureCategory;
  int _limit = 10;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    gridView = grid.KnowledgeListVertical(
      site: 'DDPM',
      model: service
          .post('${service.knowledgeApi}read', {'skip': 0, 'limit': _limit}),
    );
    _futureCategory = service.postCategory(
      '${service.knowledgeCategoryApi}read',
      {'skip': 0, 'limit': 100},
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      gridView = new grid.KnowledgeListVertical(
        site: 'DDPM',
        model: service.post('${service.knowledgeApi}read', {
          'skip': 0,
          'limit': _limit,
          'category': category,
          "keySearch": keySearch
        }),
      );
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: header(
        context,
        goBack,
        title: 'คลังความรู้',
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: const ClassicFooter(
            loadingText: ' ',
            canLoadingText: ' ',
            idleText: ' ',
            idleIcon: Icon(
              Icons.arrow_upward,
              color: Colors.transparent,
            ),
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: ListView(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 16.0),
              KeySearch(
                show: hideSearch,
                hintext: 'ค้นหาคลังความรู้',
                onKeySearchChange: (value) {
                  setState(() {
                    keySearch = value;
                    _loadResults();
                  });
                },
              ),
              const SizedBox(height: 12.0),
              _buildCategory(),
              const SizedBox(height: 12.0),
              gridView!,
            ],
          ),
        ),
      ),
    );
  }

  void _loadResults() {
    gridView = grid.KnowledgeListVertical(
      site: 'DDPM',
      model: service.post('${service.knowledgeApi}read', {
        'skip': 0,
        'limit': _limit,
        'category': category ?? '',
        'keySearch': keySearch ?? '',
      }),
    );
  }

  Widget _buildCategory() {
    return FutureBuilder<dynamic>(
      future: _futureCategory,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data.isEmpty) {
          return const SizedBox(height: 48);
        }

        final tabWidth = (MediaQuery.of(context).size.width - 48) /
            snapshot.data.length;
        return Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              final item = snapshot.data[index];
              final selected = (category ?? '') == (item['code'] ?? '');
              return GestureDetector(
                onTap: () {
                  setState(() {
                    category = item['code'];
                    _loadResults();
                  });
                },
                child: SizedBox(
                  width: tabWidth,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
