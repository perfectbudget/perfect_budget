import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/common/util/helper.dart';
import 'package:monsey/common/widget/bottom_button.dart';
import 'package:monsey/feature/onboarding/bloc/user/bloc_user.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/env.dart';
import '../../../common/constant/styles.dart';
import '../../../translations/export_lang.dart';
import '../../onboarding/widget/web_view_privacy.dart';
import 'consumable_store.dart';

final bool _kAutoConsume = Platform.isIOS || true;
final String _nonSubscriptionId =
    (Platform.isIOS || Platform.isMacOS) ? 'your_id' : 'your_id';
final List<String> _kProductIds = <String>[
  _nonSubscriptionId,
];

class UpgradePremium extends StatefulWidget {
  const UpgradePremium({Key? key}) : super(key: key);
  @override
  State<UpgradePremium> createState() => UpgradePremiumState();
}

class UpgradePremiumState extends State<UpgradePremium> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  bool isChecked = false;

  Widget createPrivacy({BuildContext? context, String? input, String? url}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context!).pushNamed(Routes.webViewPrivacy,
            arguments: WebViewPrivacy(
              title: input,
              url: url!,
            ));
      },
      child: Text(
        input!,
        style: headline(color: bleuDeFrance),
      ),
    );
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }
    try {
      final ProductDetailsResponse productDetailResponse =
          await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
      print(productDetailResponse.productDetails);
      if (productDetailResponse.error != null) {
        setState(() {
          _products = productDetailResponse.productDetails;
          _purchases = <PurchaseDetails>[];
        });
        return;
      }

      if (productDetailResponse.productDetails.isEmpty) {
        setState(() {
          _products = productDetailResponse.productDetails;
          _purchases = <PurchaseDetails>[];
        });
        return;
      }
      setState(() {
        _products = productDetailResponse.productDetails;
      });
    } catch (e) {
      print(e);
    }
  }

  void showPendingUI() {
    AppWidget.showLoading(context: context);
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == _nonSubscriptionId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      setState(() {});
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return true;
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        Navigator.of(context).pop();
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          Navigator.of(context).pushReplacementNamed(Routes.premiumSuccess);
          BlocProvider.of<UserBloc>(context).add(UpdatePremiumUser());
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume &&
              purchaseDetails.productID == _nonSubscriptionId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // GooglePlayPurchaseDetails? _getOldSubscription(
  //     ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
  //   GooglePlayPurchaseDetails? oldSubscription;
  //   if (productDetails.id == _nonSubscriptionId) {
  //     oldSubscription =
  //         purchases[_nonSubscriptionId]! as GooglePlayPurchaseDetails;
  //   }
  //   return oldSubscription;
  // }

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final Map<String, PurchaseDetails> purchases =
    //     Map<String, PurchaseDetails>.fromEntries(
    //         _purchases.map((PurchaseDetails purchase) {
    //   if (purchase.pendingCompletePurchase) {
    //     _inAppPurchase.completePurchase(purchase);
    //   }
    //   return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    // }));
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      if (state is UserLoading) {
        return const Center(child: CupertinoActivityIndicator());
      }
      if (state is UserLoaded) {
        return checkPremium(state.user.datePremium)
            ? const SizedBox()
            : BottomButton(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          activeColor: emerald,
                          value: isChecked,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = !isChecked;
                            });
                          },
                        ),
                        Row(
                          children: [
                            Text(
                              LocaleKeys.agreeToThe.tr(),
                              style: headline(context: context),
                            ),
                            createPrivacy(
                                context: context,
                                input: 'Terms of Use',
                                url: EnvValue.legalInappPurchase),
                          ],
                        ),
                      ],
                    ),
                    AppWidget.typeButtonStartAction(
                        context: context,
                        input: LocaleKeys.upgradeNow.tr(),
                        onPressed: isChecked
                            ? () {
                                late PurchaseParam purchaseParam;
                                if (Platform.isAndroid) {
                                  // final GooglePlayPurchaseDetails?
                                  //     oldSubscription = _getOldSubscription(
                                  //         _products[0], purchases);

                                  purchaseParam = GooglePlayPurchaseParam(
                                    productDetails: _products[0],
                                    // changeSubscriptionParam:
                                    //     (oldSubscription != null)
                                    //         ? ChangeSubscriptionParam(
                                    //             oldPurchaseDetails:
                                    //                 oldSubscription,
                                    //             prorationMode: ProrationMode
                                    //                 .immediateWithTimeProration,
                                    //           )
                                    //         : null
                                  );
                                } else {
                                  purchaseParam = PurchaseParam(
                                    productDetails: _products[0],
                                  );
                                }
                                if (_products[0].id == _nonSubscriptionId) {
                                  _inAppPurchase.buyConsumable(
                                      purchaseParam: purchaseParam,
                                      autoConsume: _kAutoConsume);
                                } else {
                                  _inAppPurchase.buyNonConsumable(
                                      purchaseParam: purchaseParam);
                                }
                              }
                            : () {},
                        bgColor: isChecked ? emerald : grey4,
                        textColor: white),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: AppWidget.typeButtonStartAction(
                          context: context,
                          input: LocaleKeys.restorePurchases.tr(),
                          onPressed: isChecked
                              ? () {
                                  _inAppPurchase.restorePurchases();
                                }
                              : () {},
                          bgColor: isChecked ? bleuDeFrance : grey4,
                          textColor: white),
                    ),
                  ],
                ),
              );
      }
      return const SizedBox();
    });
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
