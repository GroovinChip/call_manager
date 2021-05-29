import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bluejay/bluejay.dart';
import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/theme/app_colors.dart';
import 'package:call_manager/widgets/desktop/desktop_calls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({Key? key}) : super(key: key);

  @override
  _DesktopHomeScreenState createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen>
    with Provided, FirebaseMixin {
  final formKey = GlobalKey<FormState>();
  int screenIndex = 0;

  @override
  // ignore: code-metrics
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
                    return DesktopCalls(
                      screenIndex: screenIndex,
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
                                    prefix: Icon(
                                      CupertinoIcons.person,
                                      color: AppColors.primaryColor,
                                    ),
                                    placeholder: 'Name',
                                    decoration: BoxDecoration(
                                      color: MacosTheme.of(context).canvasColor,
                                      border: Border.all(
                                        color: MacosColors
                                            .alternatingContentBackgroundColor,
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
                                    prefix: Icon(
                                      CupertinoIcons.phone,
                                      color: AppColors.primaryColor,
                                    ),
                                    placeholder: 'Phone number',
                                    decoration: BoxDecoration(
                                      color: MacosTheme.of(context).canvasColor,
                                      border: Border.all(
                                        color: MacosColors
                                            .alternatingContentBackgroundColor,
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
                                    prefix: Icon(
                                      CupertinoIcons.text_bubble,
                                      color: AppColors.primaryColor,
                                    ),
                                    placeholder: 'Description',
                                    maxLines: 5,
                                    decoration: BoxDecoration(
                                      color: MacosTheme.of(context).canvasColor,
                                      border: Border.all(
                                        color: MacosColors
                                            .alternatingContentBackgroundColor,
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
  ValueNotifier<String?> description = ValueNotifier<String?>(null);
  ValueNotifier<String?> name = ValueNotifier<String?>(null);
  ValueNotifier<String?> phoneNumber = ValueNotifier<String?>(null);
}
