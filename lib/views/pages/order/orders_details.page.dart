import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/views/pages/order/widgets/order_actions.dart';
import 'package:fuodz/views/pages/order/widgets/recipient_info.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/amount_tile.dart';
import 'package:fuodz/widgets/cards/order_summary.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/order_product.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/translations/order_details.i18n.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({this.order, Key key}) : super(key: key);

  //
  final Order order;

  @override
  Widget build(BuildContext context) {
    //
    return ViewModelBuilder<OrderDetailsViewModel>.reactive(
      viewModelBuilder: () => OrderDetailsViewModel(context, order),
      onModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          title: "Order Details".i18n,
          showAppBar: true,
          showLeadingAction: true,
          onBackPressed: vm.onBackPressed,
          isLoading: vm.isBusy,
          body: vm.isBusy
              ? BusyIndicator().centered()
              : VStack(
                  [
                    //code & total amount
                    HStack(
                      [
                        //
                        VStack(
                          [
                            "Code".i18n.text.gray500.medium.sm.make(),
                            "#${vm.order.code}".text.medium.xl.make(),
                          ],
                        ).expand(),
                        //total amount
                        AppStrings.currencySymbol.text.medium.lg.make().px4(),
                        (vm.order.total ?? 0.00)
                            .numCurrency
                            .text
                            .medium
                            .xl2
                            .make(),
                      ],
                    ).pOnly(bottom: Vx.dp20),

                    //show package delivery addresses
                    vm.order.isPackageDelivery
                        ? VStack(
                            [
                              //pickup location routing
                              HStack(
                                [
                                  //
                                  VStack(
                                    [
                                      "Pickup Location"
                                          .i18n
                                          .text
                                          .gray500
                                          .medium
                                          .sm
                                          .make(),
                                      vm.order.pickupLocation.name.text.xl
                                          .medium
                                          .make(),
                                      vm.order.pickupLocation.address.text
                                          .make()
                                          .pOnly(bottom: Vx.dp20),
                                    ],
                                  ).expand(),

                                  //route
                                  vm.order.canChatCustomer
                                      ? CustomButton(
                                          icon: FlutterIcons.navigation_fea,
                                          iconColor: Colors.white,
                                          color: AppColor.primaryColor,
                                          shapeRadius: Vx.dp20,
                                          onPressed: () => vm.routeToLocation(
                                              vm.order.pickupLocation),
                                        ).wh(Vx.dp64, Vx.dp40).p12()
                                      : UiSpacer.emptySpace(),
                                ],
                              ),

                              //dropoff location routing
                              HStack(
                                [
                                  //
                                  VStack(
                                    [
                                      "Dropoff Location"
                                          .i18n
                                          .text
                                          .gray500
                                          .medium
                                          .sm
                                          .make(),
                                      vm.order.dropoffLocation.name.text.xl
                                          .medium
                                          .make(),
                                      vm.order.dropoffLocation.address.text
                                          .make()
                                          .pOnly(bottom: Vx.dp20),
                                    ],
                                  ).expand(),

                                  //route
                                  vm.order.canChatCustomer
                                      ? CustomButton(
                                          icon: FlutterIcons.navigation_fea,
                                          iconColor: Colors.white,
                                          color: AppColor.primaryColor,
                                          shapeRadius: Vx.dp20,
                                          onPressed: () => vm.routeToLocation(
                                              vm.order.dropoffLocation),
                                        ).wh(Vx.dp64, Vx.dp40).p12()
                                      : UiSpacer.emptySpace(),
                                ],
                              ),
                            ],
                          )
                        :
                        //regular delivery address
                        HStack(
                            [
                              VStack(
                                [
                                  "Deliver To"
                                      .i18n
                                      .text
                                      .gray500
                                      .medium
                                      .sm
                                      .make(),
                                  vm.order.deliveryAddress != null
                                      ? vm.order.deliveryAddress.name.text.xl
                                          .medium
                                          .make()
                                      : UiSpacer.emptySpace(),
                                  vm.order.deliveryAddress != null
                                      ? vm.order.deliveryAddress.address.text
                                          .make()
                                          .pOnly(bottom: Vx.dp20)
                                      : UiSpacer.emptySpace(),
                                ],
                              ).expand(),
                              //route
                              vm.order.canChatCustomer &&
                                      vm.order.deliveryAddress != null
                                  ? CustomButton(
                                      icon: FlutterIcons.navigation_fea,
                                      iconColor: Colors.white,
                                      color: AppColor.primaryColor,
                                      shapeRadius: Vx.dp20,
                                      onPressed: () => vm.routeToLocation(
                                          vm.order.deliveryAddress),
                                    ).wh(Vx.dp64, Vx.dp40).p12()
                                  : UiSpacer.emptySpace(),
                            ],
                          ),

                    //
                    (!vm.order.isPackageDelivery &&
                            vm.order.deliveryAddress == null)
                        ? "Customer Order Pickup"
                            .i18n
                            .text
                            .xl
                            .semiBold
                            .make()
                            .pOnly(bottom: Vx.dp20)
                        : UiSpacer.emptySpace(),

                    //status
                    "Status".i18n.text.gray500.medium.sm.make(),
                    vm.order.status.i18n
                        .allWordsCapitilize()
                        .text
                        .color(AppColor.getStausColor(vm.order.status))
                        .medium
                        .xl
                        .make()
                        .pOnly(bottom: Vx.dp20),

                    //Payment status
                    VStack(
                      [
                        //
                        "Payment Status".i18n.text.gray500.medium.sm.make(),
                        //
                        vm.order.paymentStatus.i18n
                            .allWordsCapitilize()
                            .text
                            .color(
                                AppColor.getStausColor(vm.order.paymentStatus))
                            .medium
                            .xl
                            .make(),
                        //
                      ],
                    ).pOnly(bottom: Vx.dp20),

                    //driver
                    vm.order.driver != null
                        ? HStack(
                            [
                              //
                              VStack(
                                [
                                  "Driver".i18n.text.gray500.medium.sm.make(),
                                  vm.order.driver.name
                                      .allWordsCapitilize()
                                      .text
                                      .medium
                                      .xl
                                      .make()
                                      .pOnly(bottom: Vx.dp20),
                                ],
                              ).expand(),
                              //call
                              CustomButton(
                                icon: FlutterIcons.phone_call_fea,
                                iconColor: Colors.white,
                                color: AppColor.primaryColor,
                                shapeRadius: Vx.dp20,
                                onPressed: vm.callDriver,
                              ).wh(Vx.dp64, Vx.dp40).p12(),
                            ],
                          )
                        : UiSpacer.emptySpace(),

                    //chat
                    vm.order.canChatDriver
                        ? CustomButton(
                            icon: FlutterIcons.chat_ent,
                            iconColor: Colors.white,
                            title: "Chat with driver".i18n,
                            color: AppColor.primaryColor,
                            onPressed: vm.chatDriver,
                          ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20)
                        : UiSpacer.emptySpace(),

                    //customer
                    HStack(
                      [
                        //
                        VStack(
                          [
                            "Customer".i18n.text.gray500.medium.sm.make(),
                            vm.order.user.name
                                .allWordsCapitilize()
                                .text
                                .medium
                                .xl
                                .make()
                                .pOnly(bottom: Vx.dp20),
                          ],
                        ).expand(),
                        //call
                        vm.order.canChatCustomer
                            ? CustomButton(
                                icon: FlutterIcons.phone_call_fea,
                                iconColor: Colors.white,
                                color: AppColor.primaryColor,
                                shapeRadius: Vx.dp20,
                                onPressed: vm.callCustomer,
                              ).wh(Vx.dp64, Vx.dp40).p12()
                            : UiSpacer.emptySpace(),
                      ],
                    ),
                    vm.order.canChatCustomer
                        ? CustomButton(
                            icon: FlutterIcons.chat_ent,
                            iconColor: Colors.white,
                            title: "Chat with customer".i18n,
                            color: AppColor.primaryColor,
                            onPressed: vm.chatCustomer,
                          ).h(Vx.dp48).pOnly(top: Vx.dp12, bottom: Vx.dp20)
                        : UiSpacer.emptySpace(),

                    //recipient
                    RecipientInfo(
                      callRecipient: vm.callRecipient,
                      order: vm.order,
                    ),

                    //note
                    "Note".i18n.text.gray500.medium.sm.make(),
                    (vm.order.note ?? "--")
                        .text
                        .medium
                        .xl
                        .italic
                        .make()
                        .pOnly(bottom: Vx.dp20),

                    // either products/package details
                    (vm.order.isPackageDelivery
                            ? "Package Details"
                            : "Products")
                        .i18n
                        .text
                        .gray500
                        .semiBold
                        .xl
                        .make()
                        .pOnly(bottom: Vx.dp10),
                    vm.order.isPackageDelivery
                        ? VStack(
                            [
                              AmountTile(
                                "Package Type".i18n,
                                vm.order.packageType.name,
                              ),
                              AmountTile("Width".i18n, vm.order.width + "cm"),
                              AmountTile("Length".i18n, vm.order.length + "cm"),
                              AmountTile("Height".i18n, vm.order.height + "cm"),
                              AmountTile("Weight".i18n, vm.order.weight + "kg"),
                            ],
                            crossAlignment: CrossAxisAlignment.end,
                          )
                        : CustomListView(
                            noScrollPhysics: true,
                            dataSet: vm.order.orderProducts,
                            itemBuilder: (context, index) {
                              //
                              final orderProduct =
                                  vm.order.orderProducts[index];
                              return OrderProductListItem(
                                orderProduct: orderProduct,
                              );
                            },
                          ),

                    //order summary
                    OrderSummary(
                      subTotal: vm.order.subTotal,
                      discount: vm.order.discount,
                      deliveryFee: vm.order.deliveryFee,
                      tax: vm.order.tax,
                      vendorTax: ((vm.order.tax / vm.order.total) * 100)
                          .toDoubleStringAsFixed(),
                      total: vm.order.total,
                    ).pOnly(top: Vx.dp20, bottom: Vx.dp56),
                  ],
                )
                  .p20()
                  .pOnly(bottom: context.percentHeight * 30)
                  .scrollVertical(),

          //
          bottomSheet: vm.order.canShowActions ?  OrderActions(
            order: vm.order,
            canChatCustomer: vm.order.canChatCustomer,
            busy: vm.isBusy || vm.busy(vm.order),
            onEditPressed: vm.changeOrderStatus,
            onAssignPressed: vm.assignOrder,
            onCancelledPressed: vm.processOrderCancellation,
          ): null,
        );
      },
    );
  }
}
