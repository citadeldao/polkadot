The [Citadel.one](http://citadel.one/) mobile app is written in the Dart language and uses the Flutter framework. This is a cross-platform application for iOS and Android.

We use [js library](https://github.com/citadeldao/citadel-lib) to work with Polka.  In order to execute the js code in the mobile app, we use [invisible WebView](https://pub.dev/packages/flutter_inappwebview). The WebView contains only one script with the library code:


```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <script src="citadel-lib.js"></script>
</head>
</html>
```

On the dart side we made a JSBridge class, which is responsible for sending and receiving data between the library and the mobile application code. This is what creating a wallet looks like, for example:

```dart
@override
Future<JSCreateWalletByMnemonicResponse> createWalletByMnemonic(
  JSCreateWalletByMnemonicArgs args,
) {
  return controller.callAsyncJavaScript(
    functionBody:
        '''return await citadel.createWalletByMnemonic(${serializeToJS(args)})''',
  ).then(
    (it) => deserialize<JSCreateWalletByMnemonicResponse>(
      jsonDecode(it!.value),
    )!,
  );
}
```


The library has sockets. We listen to events from them as follows:

```dart
controller.addJavaScriptHandler(
  handlerName: 'onSocketEvent',
  callback: onSocketEvent,
);
```

Next we convert the js data into dart code:

```dart
Future<ClientMnemonicWallet> createWalletByMnemonic({
  required String net,
  required String mnemonic,
  String? derivationPath,
  String? passphrase,
  String? account,
}) async {
  final result = await _jsEngine.createWalletByMnemonic(
    net: net,
    mnemonic: mnemonic,
    derivationPath: derivationPath,
    passphrase: passphrase,
    account: account,
  );

  final oldWallet = getAllWallets().firstWhereOrNull(
    (it) => it.mainToken.net == result.net && it.address == result.address,
  );

  return ClientMnemonicWallet(
    (b) => b
      ..address = result.address
      ..publicKey = result.publicKey
      ..derivationPath = result.derivationPath
      ..privateKey = result.privateKey
      ..type = result.type.toTypeOfWallet()
      ..code = result.code
      ..networkName = result.networkName
      ..net = result.net
      ..addedBefore =
          oldWallet != null && oldWallet.type != TypeOfWallet.public,
  );
}
```

And the data is already rendered on the ui. For example:

```dart
class OverallWalletWidget extends StatelessWidget {
  const OverallWalletWidget({
    required this.wallet,
    required this.balanceVisible,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final ClientWallet wallet;
  final bool balanceVisible;
  final VoidCallback? onTap;

...........
Widget _title() {
    return Text(
      addressShort(
        wallet.title.isNotNullOrEmpty ? wallet.title : wallet.address,
      ),
      style: appTextStyles.headline5Bold17.copyWith(
        color: appColors.typographyTitle,
        fontSize: 17.sp,
      ),
    );
  }
...........
```

All private data stored in secure storage. We use [flutter_keychain](https://pub.dev/packages/flutter_keychain) with [hive](https://pub.dev/packages/hive). All business logic takes place locally on the mobile phone, and only ready signed transactions we send to the backend. To give you an example, this is how shipping is done. First, we create a transaction:

```dart
@override
Future<JSRawResponse> prepareTransfer(
    String walletId, JSPrepareTransferOptions options) {
  return controller.callAsyncJavaScript(
    functionBody:
        '''return await citadel.prepareTransfer(${serializeToJS(walletId)}, ${serializeToJS(options)})''',
  ).then(
    (it) => deserialize<JSRawResponse>(jsonDecode(it!.value))!,
  );
}

```

And then, we sign it and send it to the backend:
