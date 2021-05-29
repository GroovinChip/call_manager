import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bluejay/bluejay.dart';
import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/theme/app_colors.dart';
import 'package:call_manager/widgets/call_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:rxdart/rxdart.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({Key? key}) : super(key: key);

  @override
  _DesktopHomeScreenState createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen>
    with Provided, FirebaseMixin {
  int screenIndex = 0;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final textColor =
        MacosTheme.brightnessOf(context).isDark ? Colors.white : Colors.black;

    return WindowTitleBarBox(
      child: MoveWindow(
        child: Stack(
          children: [
            MacosScaffold(
              sidebar: Sidebar(
                minWidth: 225,
                startWidth: 225,
                maxWidth: 225,
                scaffoldBreakpoint: 700,
                builder: (context, scrollController) {
                  return SidebarItems(
                    currentIndex: screenIndex,
                    onChanged: (i) => setState(() => screenIndex = i),
                    items: [
                      SidebarItem(
                        selectedColor: AppColors.primaryColor,
                        selectedHoverColor: AppColors.primaryColor,
                        unselectedHoverColor: Color(0x00000000),
                        leading: Icon(
                          CupertinoIcons.calendar,
                          color: screenIndex == 0
                              ? Colors.white
                              : AppColors.accentColor,
                        ),
                        label: Text('Upcoming Calls'),
                      ),
                      SidebarItem(
                        selectedColor: AppColors.primaryColor,
                        selectedHoverColor: AppColors.primaryColor,
                        unselectedHoverColor: Color(0x00000000),
                        leading: Icon(
                          CupertinoIcons.checkmark_seal,
                          color: screenIndex == 1
                              ? Colors.white
                              : AppColors.accentColor,
                        ),
                        label: Text('Completed Calls'),
                      ),
                    ],
                  );
                },
              ),
              children: [
                ContentArea(
                  builder: (context, scrollController) {
                    return StreamBuilder<List<FirestoreDocument>>(
                      stream: CombineLatestStream.combine2(
                        firestore.upcomingCalls.snapshots(),
                        firestore.completedCalls.snapshots(),
                        (a, b) => <FirestoreDocument>[
                          a as FirestoreDocument,
                          b as FirestoreDocument,
                        ],
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: ProgressCircle(),
                          );
                        } else {
                          return IndexedStack(
                            index: screenIndex,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 30.0,
                                      top: 50.0,
                                    ),
                                    child: Text(
                                      'Upcoming',
                                      style: MacosTheme.of(context)
                                          .typography
                                          .largeTitle
                                          .copyWith(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  if (snapshot.data!.first.docs.isNotEmpty) ...[
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(16.0),
                                        itemCount:
                                            snapshot.data!.first.docs.length,
                                        itemBuilder: (context, index) {
                                          final call = Call.fromJsonWithDocId(
                                            snapshot.data!.first.docs[index]
                                                .data(),
                                            snapshot.data!.first.docs[index].id,
                                          );

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CallCard(
                                              call: call,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Tap "Add Call" to get started!',
                                          style: Platform.isMacOS
                                              ? MacosTheme.of(context)
                                                  .typography
                                                  .title1
                                              : Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 30.0,
                                      top: 50.0,
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: MacosTheme.of(context)
                                          .typography
                                          .largeTitle
                                          .copyWith(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  if (snapshot.data!.last.docs.isNotEmpty) ...[
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(16.0),
                                        itemCount:
                                            snapshot.data!.last.docs.length,
                                        itemBuilder: (context, index) {
                                          final call = Call.fromJsonWithDocId(
                                            snapshot.data!.last.docs[index]
                                                .data(),
                                            snapshot.data!.last.docs[index].id,
                                          );

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CallCard(
                                              call: call,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Nothing here!',
                                          style: Platform.isMacOS
                                              ? MacosTheme.of(context)
                                                  .typography
                                                  .title1
                                              : Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: MacosIconButton(
                icon: Icon(
                  CupertinoIcons.add,
                  color: textColor,
                ),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(7),
                backgroundColor: MacosTheme.brightnessOf(context).isDark
                    ? MacosColors.unemphasizedSelectedContentBackgroundColor
                    : Colors.grey.shade300,
                onPressed: () async {
                  final newCallNotifiers = NewCallNotifiers();

                  final result = showDialog<bool?>(
                    context: context,
                    builder: (_) => Form(
                      key: formKey,
                      child: SimpleDialog(
                        backgroundColor: MacosTheme.of(context).canvasColor,
                        title: Text(
                          'New Call',
                          style: MacosTheme.of(context).typography.title1,
                        ),
                        children: [
                          ValueListenableBuilder<String?>(
                            valueListenable: newCallNotifiers.name,
                            builder: (_, value, __) {
                              return TextEditingControllerBuilder(
                                text: value ?? '',
                                builder: (_, controller) {
                                  return MacosTextField(
                                    controller: controller,
                                    prefix: Icon(CupertinoIcons.person),
                                    placeholder: 'Name',
                                    decoration: BoxDecoration(
                                      color: MacosTheme.of(context).canvasColor,
                                      border: Border.all(
                                        color: MacosTheme.brightnessOf(context)
                                                .isDark
                                            ? MacosColors
                                                .alternatingContentBackgroundColor
                                            : Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    onChanged: (newValue) {
                                      newCallNotifiers.name.value = newValue;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder<String?>(
                            valueListenable: newCallNotifiers.phoneNumber,
                            builder: (_, value, __) {
                              return TextEditingControllerBuilder(
                                text: value ?? '',
                                builder: (_, controller) {
                                  return MacosTextField(
                                    prefix: Icon(CupertinoIcons.phone),
                                    placeholder: 'Phone number',
                                    decoration: BoxDecoration(
                                      color: MacosTheme.of(context).canvasColor,
                                      border: Border.all(
                                        color: MacosTheme.brightnessOf(context)
                                                .isDark
                                            ? MacosColors
                                                .alternatingContentBackgroundColor
                                            : Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    onChanged: (newValue) {
                                      newCallNotifiers.phoneNumber.value =
                                          newValue;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder<String?>(
                            valueListenable: newCallNotifiers.description,
                            builder: (_, value, __) {
                              return TextEditingControllerBuilder(
                                text: value ?? '',
                                builder: (_, controller) {
                                  return MacosTextField(
                                    prefix: Icon(CupertinoIcons.text_bubble),
                                    placeholder: 'Description',
                                    maxLines: 5,
                                    decoration: BoxDecoration(
                                      color: MacosTheme.of(context).canvasColor,
                                      border: Border.all(
                                        color: MacosTheme.brightnessOf(context)
                                                .isDark
                                            ? MacosColors
                                                .alternatingContentBackgroundColor
                                            : Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    onChanged: (newValue) {
                                      newCallNotifiers.description.value =
                                          newValue;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          ButtonBar(
                            children: [
                              PushButton(
                                buttonSize: ButtonSize.small,
                                child: Text('Save'),
                                onPressed: () {
                                  if (newCallNotifiers.name.value != null &&
                                      newCallNotifiers.phoneNumber.value !=
                                          null) {
                                    if (newCallNotifiers
                                            .name.value!.isNotEmpty &&
                                        newCallNotifiers
                                            .phoneNumber.value!.isNotEmpty) {
                                      Call call = Call(
                                        name: newCallNotifiers.name.value,
                                        phoneNumber:
                                            newCallNotifiers.phoneNumber.value,
                                        description:
                                            newCallNotifiers.description.value,
                                      );
                                      firestore.upcomingCalls
                                          .add(call.toJson());
                                      newCallNotifiers.name.value = null;
                                      newCallNotifiers.phoneNumber.value = null;
                                      newCallNotifiers.description.value = null;
                                      Navigator.of(context).pop(true);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  if (result == false) {
                    newCallNotifiers.name.value = null;
                    newCallNotifiers.phoneNumber.value = null;
                    newCallNotifiers.description.value = null;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewCallNotifiers {
  ValueNotifier<String?> name = ValueNotifier<String?>(null);
  ValueNotifier<String?> phoneNumber = ValueNotifier<String?>(null);
  ValueNotifier<String?> description = ValueNotifier<String?>(null);
}
