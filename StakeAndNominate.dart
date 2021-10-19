 Future<Map<String, dynamic>> polkadotPrepareStakeAndNominate({
    @required String session,
    @required Wallet wallet,
    @required List<StakeData> stakedNodes,
    @required StakingNode node,
  }) async {
    await connectivityCheck();
    final delegations = List<String>();

    for (int i = 0; i < stakedNodes.length; i++) {
      delegations.add(stakedNodes[i].current);
    }

    final body = {
      "delegations": delegations,
      "amount": node.stakeAmount,
      "tip": node.fee,
    };
    final headers = {'Content-Type': 'application/json', 'Cookie': session};
    final request = http.Request(
        'GET',
        Uri.parse(
            '$apiUrl/polkadot/${wallet.address}/prepareStakeAndNominate'));
    request.body = json.encode(body);
    request.headers.addAll(headers);

    final response = await request.send();
    final result = await response.stream.bytesToString();
    return json.decode(result);
  }

