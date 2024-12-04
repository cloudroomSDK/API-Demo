import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtcsdk_demo/src/controller/permission_controller.dart';

class InterceptorMiddleware extends GetMiddleware {
  List<Permission>? permissions;
  InterceptorMiddleware({this.permissions});

  PermissionController get permissionLogic => Get.find<PermissionController>();

  // redirectDelegate必须使用GetMaterialApp.router（app.dart）, initialRoute默认第一个Page，可加GetMiddleware用redirectDelegate来决定跳哪一个
  // @override
  // Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
  //   debugPrint('redirectDelegate 检查权限 $route');
  //   if (permissions != null) {
  //     await permissionLogic.checkPermission(permissions!);
  //   }
  //   return await super.redirectDelegate(route);
  // }

  // @override
  // RouteSettings? redirect(String? route) {
  //   debugPrint('redirect $route');
  //   return null;
  // }

  // 在创建任何内容之前调用此页面时，将调用此函数，您可以使用它来更改页面的某些内容或为其提供新页面
  // @override
  // GetPage? onPageCalled(GetPage? page) {
  //   debugPrint('onPageCalled ${page?.name}');
  //   return page;
  // }

  // 该函数将在绑定初始化之前调用。您可以在此处更改此页面的绑定。
  // OnBindingsStart

  // 该函数将在绑定初始化后立即调用。在创建绑定之后、创建页面小部件之前，您可以在此处执行一些操作
  // OnPageBuildStart

  // 该函数将在调用 GetPage.page 函数后立即调用，并向您提供该函数的结果。并获取将要显示的小部件。
  // OnPageBuilt

  // 该函数将在处理完页面的所有相关对象（控制器、视图等）后立即调用。
  // OnPageDispose
}
