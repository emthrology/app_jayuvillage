import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_ex/screen/manager_exclusive_menus/ex_menus_index.dart';
import 'package:webview_ex/screen/manager_exclusive_menus/organization_item_status/branch_manager_itemlist.dart';
import 'package:webview_ex/screen/manager_exclusive_menus/organization_item_status/general_manager_itemlist.dart';
import 'package:webview_ex/screen/manager_exclusive_menus/organization_item_status/search_delivery_address_screen.dart';

import '../screen/contents/audio_screen.dart';
import '../screen/contents/contents_index_screen.dart';
import '../screen/contents/share_screen.dart';
import '../screen/error_screen.dart';
import '../screen/home_screen.dart';
import '../screen/manager_exclusive_menus/organization_item_status/complete_screen.dart';
import '../screen/manager_exclusive_menus/organization_manager_status/organization_manager_index_screen.dart';
final goRouter = GoRouter(

  initialLocation: '/',
  routes: [
    GoRoute(
        path:'/',
        builder: (context, state){
          debugPrint('routed here');
          return HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com'), pageId:'0');
        }
    ),
    GoRoute(
      path:'/organization',
      builder: (context,state) {
        return HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com/organization'), pageId:'0', navIndex: 2);
      }
    ),
    GoRoute(
        path:'/chat/:id',
        builder: (context,state) {
          debugPrint(state.uri.toString());
          return HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com/chat/live?groupId=${state.pathParameters['id']!}'), pageId: '0');
        }
    ),
    GoRoute(
        path:'/confirm/jay',
        builder: (context,state) {
          debugPrint(state.uri.toString());
          final id = state.uri.queryParameters['id'];
          final name = state.uri.queryParameters['name'];
          return HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com/confirm/jay?id=$id&name=$name'), pageId: '0');
        }
    ),
    GoRoute(
        path:'/contents',
        builder:(context, state) {
          return ContentsIndexScreen(pageIndex:'1');
        }
    ),
    GoRoute(
        path:'/contents/:index',
        builder:(context,state) {
          return ContentsIndexScreen(pageIndex:state.pathParameters['index']!);
        }
    ),
    GoRoute(
      path:'/posts/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return HomeScreen(homeUrl: state.uri, pageId:'$id');
      },
    ),
    GoRoute(
        path:'/notices/:id',
        builder:(context, state) {
          final id = state.pathParameters['id'];
          return HomeScreen(homeUrl: state.uri, pageId:'$id');
        }
    ),
    GoRoute(
        path:'/audio/player',
        builder:(context,state) {
          return AudioScreen();
        }
    ),
    GoRoute(
        path:'/audio/:id',
        builder:(context, state) {
          return ShareScreen(itemId:state.pathParameters['id']!);
        }
    ),
    GoRoute(
        path:'/organization/manager',
        builder:(context, state) {
          return ExMenusIndex();
        }
    ),
    GoRoute(
        path:'/organization/manager/items/:id',
        builder:(context, state) {
          if(int.parse(state.pathParameters['id']!) < 10) {
            return OrganizationManagerIndexScreen();
          }else {
            final position = state.uri.queryParameters['position'];
            if(position == '총괄팀장') {
              return GeneralManagerItemlist();
            }else { //position == '실행위원장'
              return BranchManagerItemlist(phone: state.uri.queryParameters['phone']!);
            }
            // return OrganizationItemIndexScreen();
          }
        }
    ),
    GoRoute(
      path:'/organization/manager/address',
      builder:(context, state) {
        return SearchDeliveryAddressScreen(
          state: state.uri.queryParameters['state']!,
          election: state.uri.queryParameters['election']!,
        );
      }
    ),
    GoRoute(
        path:'/organization/manager/complete',
        builder:(context, state) {
          return CompleteScreen(
            clientName: state.uri.queryParameters['name']!,
            clientPhone: state.uri.queryParameters['phone']!,
            clientAddress: state.uri.queryParameters['address']!,
          );
        }
    )
  ],
  errorBuilder: (context, state) {
    return ErrorScreen(error: state.error.toString());
  },
  redirect: (BuildContext context, GoRouterState state) {
    // 딥링크 처리 로직
    debugPrint('redirect-state:$state');
    final deepLink = state.uri.toString();
    debugPrint('deepLink:$deepLink');
    if (deepLink.isNotEmpty) {
      // 딥링크에 따른 리다이렉션 로직
      return deepLink;
    }
    return null; // 리다이렉션이 필요 없는 경우
  },
  debugLogDiagnostics: true,
);