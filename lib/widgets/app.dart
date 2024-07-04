import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/zulip_localizations.dart';

import '../model/localizations.dart';
import '../model/narrow.dart';
import 'about_zulip.dart';
import 'inbox.dart';
import 'login.dart';
import 'message_list.dart';
import 'page.dart';
import 'recent_dm_conversations.dart';
import 'store.dart';
import 'subscription_list.dart';
import 'text.dart';
import 'theme.dart';

class ZulipApp extends StatefulWidget {
  const ZulipApp({super.key, this.navigatorObservers});

  /// Whether the app's widget tree is ready.
  ///
  /// This begins as false.  It transitions to true when the
  /// [GlobalStore] has been loaded and the [MaterialApp] has been mounted,
  /// and then remains true.
  static ValueListenable<bool> get ready => _ready;
  static ValueNotifier<bool> _ready = ValueNotifier(false);

  /// The navigator for the whole app.
  ///
  /// This is always the [GlobalKey.currentState] of [navigatorKey].
  /// If [navigatorKey] is already mounted, this future completes immediately.
  /// Otherwise, it waits for [ready] to become true and then completes.
  static Future<NavigatorState> get navigator {
    final state = navigatorKey.currentState;
    if (state != null) return Future.value(state);

    assert(!ready.value);
    final completer = Completer<NavigatorState>();
    ready.addListener(() {
      assert(ready.value);
      completer.complete(navigatorKey.currentState!);
    });
    return completer.future;
  }

  /// A key for the navigator for the whole app.
  ///
  /// For code that exists entirely outside the widget tree and has no natural
  /// [BuildContext] of its own, this enables interacting with the app's
  /// navigation, by calling [GlobalKey.currentState] to get a [NavigatorState].
  ///
  /// During the app's early startup, this key will not yet be mounted.
  /// It will always be mounted before [ready] becomes true,
  /// and naturally before any widgets are mounted which are part of the
  /// app's main UI managed by the navigator.
  ///
  /// See also [navigator], to asynchronously wait for the navigator
  /// to be mounted.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Reset the state of [ZulipApp] statics, for testing.
  ///
  /// TODO refactor this better, perhaps unify with ZulipBinding
  @visibleForTesting
  static void debugReset() {
    _ready.dispose();
    _ready = ValueNotifier(false);
  }

  /// A list to pass through to [MaterialApp.navigatorObservers].
  /// Useful in tests.
  final List<NavigatorObserver>? navigatorObservers;

  void _declareReady() {
    assert(navigatorKey.currentContext != null);
    _ready.value = true;
  }

  @override
  State<ZulipApp> createState() => _ZulipAppState();
}

class _ZulipAppState extends State<ZulipApp> with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(routeInformation) async {
    if (routeInformation
        case RouteInformation(
          uri: Uri(scheme: 'zulip', host: 'login') && var url
        )) {
      await LoginPage.handleWebAuthUrl(url);
      return true;
    }
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = zulipThemeData(context);
    return GlobalStoreWidget(child: Builder(builder: (context) {
      final globalStore = GlobalStoreWidget.of(context);
      // TODO(#524) choose initial account as last one used
      final initialAccountId = globalStore.accounts.firstOrNull?.id;
      return MaterialApp(
          title: 'Zulip',
          localizationsDelegates: ZulipLocalizations.localizationsDelegates,
          supportedLocales: ZulipLocalizations.supportedLocales,
          theme: themeData,
          navigatorKey: ZulipApp.navigatorKey,
          navigatorObservers: widget.navigatorObservers ?? const [],
          builder: (BuildContext context, Widget? child) {
            if (!ZulipApp.ready.value) {
              SchedulerBinding.instance
                  .addPostFrameCallback((_) => widget._declareReady());
            }
            GlobalLocalizations.zulipLocalizations =
                ZulipLocalizations.of(context);
            return child!;
          },

          // We use onGenerateInitialRoutes for the real work of specifying the
          // initial nav state.  To do that we need [MaterialApp] to decide to
          // build a [Navigator]... which means specifying either `home`, `routes`,
          // `onGenerateRoute`, or `onUnknownRoute`.  Make it `onGenerateRoute`.
          // It never actually gets called, though: `onGenerateInitialRoutes`
          // handles startup, and then we always push whole routes with methods
          // like [Navigator.push], never mere names as with [Navigator.pushNamed].
          onGenerateRoute: (_) => null,
          onGenerateInitialRoutes: (_) {
            return [
              MaterialWidgetRoute(page: const ChooseAccountPage()),
              if (initialAccountId != null) ...[
                RedHome.buildRoute(accountId: initialAccountId),
                //HomePage.buildRoute(accountId: initialAccountId)
                //InboxPage.buildRoute(accountId: initialAccountId),
              ],
            ];
          });
    }));
  }
}

class RedHome extends StatelessWidget {
  final int accountId;

  const RedHome({required this.accountId, super.key});

  static Route<void> buildRoute({required int accountId}) {
    return MaterialAccountWidgetRoute(
      accountId: accountId,
      page: RedHome(accountId: accountId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final globalStore = GlobalStoreWidget.of(context);
    final store = PerAccountStoreWidget.of(context);
double screenHeight = MediaQuery.of(context).size.height;
    var account = globalStore.getAccount(accountId);
    final user = store.users[account!.userId];
    print(account);
    print(user);


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xffffffff)),
        title: const Text('RedBangle',style: TextStyle(color: Color(0xffffffff), fontWeight: FontWeight.w300),),
        centerTitle: true,
        automaticallyImplyLeading:true,
        elevation: 10,
        backgroundColor: kRedBangleBrandColor,
        shadowColor:kRedBangleBrandColor,
        surfaceTintColor: kRedBangleBrandColor,

        actions: [
          Padding(
           padding: const EdgeInsets.only(right: 8.0),
            child: Container(

               width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color:const Color(0xffffffff),
                            ),

            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset('assets/bangle/icon.png'),
            )),
          ),],
      ),
       drawer:Drawer(

        child:ListView(

            padding: EdgeInsets.zero,
            children: const <Widget>[
             DrawerHeader(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.zero,
    color: kRedBangleBrandColor,
  ),
  child: Stack(
    children: [
      // Rest of your DrawerHeader content (optional)

      Positioned(
        bottom: 16.0, // Adjust padding as needed
        left: 16.0, // Adjust horizontal position as needed
        child: Text(
          'Subscribed channels',
          style: TextStyle(
            color: Color(0xffffffff),
            fontSize: 24,
          ),
        ),
      ),
    ],
  ),
),
              SubscriptionListPage()
            ],
          ),
       ),
      body:  Builder(
        builder: (context) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(0.0),
            sliver: SliverAppBar(
              backgroundColor: kRedBangleBrandColor,
              pinned: true,
              floating: true,
              title: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  user!.fullName,
                  textAlign:
                      TextAlign.center, // Center align the text horizontally
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffffffff)),
                ),
              ),
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.only(left: 4.0, top: 10),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color:const Color(0xffffffff),
                              ),
                              child: Text(
                                user.fullName.substring(0, 1).toUpperCase(),
                                textAlign: TextAlign
                                    .center, // Center align the text horizontally
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff000000)),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              expandedHeight: 100,
              collapsedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(

                centerTitle: true,
title: const Padding(
  padding:  EdgeInsets.only(left:10.0,right: 10),
  child:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, // Align vertically
        children: [
          Text(
            "Combined feed",
            style:  TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          ),
        ],
      ),
),
                background: Container(color: kRedBangleBrandColor),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, top: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color:const Color(0xffffffff),
                      padding: const EdgeInsets.all(2.0),
                      child: Stack(
                        // Use Stack for efficient status dot positioning
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10.0), // Adjust as needed
                            child: Image.network(
                              user.avatarUrl ?? '',
                              width: 30.0,
                              height: 30.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            // Precisely position the status dot
                            bottom: 2.0, // Adjust top padding for dot placement
                            right:
                                2.0, // Adjust right padding for dot placement
                            child: Container(
                              width: 8.0, // Adjust dot size as desired
                              height: 8.0, // Adjust dot size as desired
                              decoration: BoxDecoration(
                                color: user.isActive
                                    ? Colors.green
                                    : Colors
                                        .red, // Dynamic color based on user status
                                shape:
                                    BoxShape.circle, // Ensure a circular shape
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(

              child: SizedBox(
                    height: screenHeight - 150,
                    child: const MessageListPage(narrow: CombinedFeedNarrow(),)),
            );
          }, childCount: 1),
        ),
        ],
      ),
      ),
      bottomNavigationBar:BottomNavigationBar(
        selectedItemColor:const Color(0xff000000),
        backgroundColor:const Color(0xffffffff),
        currentIndex: 0,
        onTap: (int index) {
          if(index == 0){
          MessageListPage.buildRoute(
                      context: context, narrow: const CombinedFeedNarrow());

          }else if(index == 1){
          Navigator.push(
                  context, InboxPage.buildRoute(context: context));
          }if(index == 2){
              Navigator.push(context,
                  RecentDmConversationsPage.buildRoute(context: context));
          }

        },
        // Add your navigation bar items here
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_rounded),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment_outlined),
            label: 'Direct Messages',
          ),
        ],)
    );
  }

}





class ListItemWidget extends StatelessWidget {
  final int accountId;

  const ListItemWidget({required this.accountId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Dynamic Content for Account $accountId'),
      onTap: () {
        Navigator.of(context).push(RedHome.buildRoute(accountId: accountId));
      },
    );
  }
}

class ChooseAccountPage extends StatelessWidget {
  const ChooseAccountPage({super.key});

  Widget _buildAccountItem(
    BuildContext context, {
    required int accountId,
    required Widget title,
    Widget? subtitle,
  }) {
    return Card(
        clipBehavior: Clip.hardEdge,
        child: ListTile(
          tileColor: kRedBangleBrandColor,
            title: title,
            textColor: const Color(0xffffffff),
            subtitle: subtitle,
            onTap: () => Navigator.push(
                context, RedHome.buildRoute(accountId: accountId))));
  }

  @override
  Widget build(BuildContext context) {
    final zulipLocalizations = ZulipLocalizations.of(context);
    assert(!PerAccountStoreWidget.debugExistsOf(context));
    final globalStore = GlobalStoreWidget.of(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Container(
            width: 120,
            height: 140, // Adjust the height as needed
            child: Image.asset(
                'assets/bangle/logo.png'), // Replace with your image path
          ),
          actions: const [ChooseAccountPageOverflowButton()],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final (:accountId, :account)
                                      in globalStore.accountEntries)
                                    _buildAccountItem(context,
                                        accountId: accountId,
                                        title:
                                            Text(account.realmUrl.toString()),
                                        subtitle: Text(account.email)),
                                ]))),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
    backgroundColor: kRedBangleBrandColor,
  ),
                        onPressed: () => Navigator.push(
                            context, AddAccountPage.buildRoute()),
                        child: Text(zulipLocalizations
                            .chooseAccountButtonAddAnAccount,style:const TextStyle(color: Color(0xffffffff)),)),
                  ]))),
        ));
  }
}

enum ChooseAccountPageOverflowMenuItem { aboutZulip }

class ChooseAccountPageOverflowButton extends StatelessWidget {
  const ChooseAccountPageOverflowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ChooseAccountPageOverflowMenuItem>(
        itemBuilder: (BuildContext context) => const [
              PopupMenuItem(
                  value: ChooseAccountPageOverflowMenuItem.aboutZulip,
                  child: Text('About Redbangle')),
            ],
        onSelected: (item) {
          switch (item) {
            case ChooseAccountPageOverflowMenuItem.aboutZulip:
              Navigator.push(context, AboutZulipPage.buildRoute(context));
          }
        });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> buildRoute({required int accountId}) {
    return MaterialAccountWidgetRoute(
        accountId: accountId, page: const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final store = PerAccountStoreWidget.of(context);
    final zulipLocalizations = ZulipLocalizations.of(context);

    InlineSpan bold(String text) => TextSpan(
        style: const TextStyle()
            .merge(weightVariableTextStyle(context, wght: 700)),
        text: text);

    int? testStreamId;
    if (store.connection.realmUrl.origin == 'https://chat.redbangle.com') {
      testStreamId = 7; // i.e. `#test here`; TODO cut this scaffolding hack
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/bangle/icon.png'),
            )
          ],
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
              child: Column(children: [])),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MessageListPage.buildRoute(
                      context: context, narrow: const CombinedFeedNarrow())),
              child: Text(zulipLocalizations.combinedFeedPageTitle)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context, InboxPage.buildRoute(context: context)),
              child: const Text("Inbox")), // TODO(i18n)
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context, SubscriptionListPage.buildRoute(context: context)),
              child: const Text("Subscribed channels")),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () => Navigator.push(context,
                  RecentDmConversationsPage.buildRoute(context: context)),
              child: Text(zulipLocalizations.recentDmConversationsPageTitle)),
          if (testStreamId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MessageListPage.buildRoute(
                        context: context, narrow: StreamNarrow(testStreamId!))),
                child: const Text("#test here")), // scaffolding hack, see above
          ],
        ])));
  }
}
