  Future<Map<String, dynamic>> prepareDelegations({
    @required String session,
    @required Wallet wallet,
    @required StakingNode node,
  }) async {
    assert(session?.isNotEmpty == true && wallet != null && node != null);
    return await transactionsNetworkDataProvider.prepareDelegations(
      session: session,
      wallet: wallet,
      node: node,
    );
  }

  Future<Map<String, dynamic>> prepareIconDelegations({
    @required String session,
    @required Wallet wallet,
    @required List<StakeData> stakedNodes,
    @required List<StakingNode> nodes,
    @required StakingNode node,
  }) async {
    assert(session?.isNotEmpty == true &&
        wallet != null &&
        node != null &&
        nodes?.isNotEmpty == true);
    return await transactionsNetworkDataProvider.prepareIconDelegations(
      session: session,
      wallet: wallet,
      stakedNodes: stakedNodes,
      nodes: nodes,
      node: node,
    );
  }
