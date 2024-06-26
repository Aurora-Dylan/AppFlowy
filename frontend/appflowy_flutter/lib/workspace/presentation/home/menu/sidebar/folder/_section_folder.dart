import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/workspace/application/menu/sidebar_sections_bloc.dart';
import 'package:appflowy/workspace/application/sidebar/folder/folder_bloc.dart';
import 'package:appflowy/workspace/application/tabs/tabs_bloc.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/folder/_folder_header.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/rename_view_dialog.dart';
import 'package:appflowy/workspace/presentation/home/menu/view/view_item.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SectionFolder extends StatelessWidget {
  const SectionFolder({
    super.key,
    required this.title,
    required this.categoryType,
    required this.views,
    this.isHoverEnabled = true,
  });

  final String title;
  final FolderCategoryType categoryType;
  final List<ViewPB> views;
  final bool isHoverEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FolderBloc>(
      create: (context) => FolderBloc(type: categoryType)
        ..add(
          const FolderEvent.initial(),
        ),
      child: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, state) {
          return Column(
            children: [
              FolderHeader(
                title: title,
                expandButtonTooltip: expandButtonTooltip,
                addButtonTooltip: addButtonTooltip,
                onPressed: () => context
                    .read<FolderBloc>()
                    .add(const FolderEvent.expandOrUnExpand()),
                onAdded: () {
                  createViewAndShowRenameDialogIfNeeded(
                    context,
                    LocaleKeys.newPageText.tr(),
                    (viewName, _) {
                      if (viewName.isNotEmpty) {
                        context.read<SidebarSectionsBloc>().add(
                              SidebarSectionsEvent.createRootViewInSection(
                                name: viewName,
                                index: 0,
                                viewSection: categoryType.toViewSectionPB,
                              ),
                            );

                        context.read<FolderBloc>().add(
                              const FolderEvent.expandOrUnExpand(
                                isExpanded: true,
                              ),
                            );
                      }
                    },
                  );
                },
              ),
              if (state.isExpanded)
                ...views.map(
                  (view) => ViewItem(
                    key: ValueKey(
                      '${categoryType.name} ${view.id}',
                    ),
                    categoryType: categoryType,
                    isFirstChild: view.id == views.first.id,
                    view: view,
                    level: 0,
                    leftPadding: 16,
                    isFeedback: false,
                    onSelected: (view) {
                      if (HardwareKeyboard.instance.isControlPressed) {
                        context.read<TabsBloc>().openTab(view);
                      }

                      context.read<TabsBloc>().openPlugin(view);
                    },
                    onTertiarySelected: (view) =>
                        context.read<TabsBloc>().openTab(view),
                    isHoverEnabled: isHoverEnabled,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String get expandButtonTooltip {
    return switch (categoryType) {
      FolderCategoryType.public => LocaleKeys.sideBar_clickToHidePublic.tr(),
      FolderCategoryType.private => LocaleKeys.sideBar_clickToHidePrivate.tr(),
      _ => '',
    };
  }

  String get addButtonTooltip {
    return switch (categoryType) {
      FolderCategoryType.public => LocaleKeys.sideBar_addAPageToPublic.tr(),
      FolderCategoryType.private => LocaleKeys.sideBar_addAPageToPrivate.tr(),
      _ => '',
    };
  }
}
