 Future<Map<String, dynamic>> polkadotprepareUndelegation({
    @required String session,
    @required Wallet wallet,
    @required List<StakeData> stakedNodes,
  }) async {
    await connectivityCheck();
    final delegations = List<String>();

    for (int i = 0; i < stakedNodes.length; i++) {
      delegations.add(stakedNodes[i].current);
    }

    final body = {
      "delegations": delegations,
    };
    final headers = {'Content-Type': 'application/json', 'Cookie': session};
    final request = http.Request(
        'GET',
        Uri.parse(
            '$apiUrl/polkadot/${wallet.address}/prepareUndelegation'));
    request.body = json.encode(body);
    request.headers.addAll(headers);

    final response = await request.send();
    final result = await response.stream.bytesToString();
    return json.decode(result);
  }

  String content(Uint8List bytes) {
    return utf8.decode(bytes, allowMalformed: true);
  }

