	const controller = (await api.query.staking.bonded(fromAddress)).toHuman();
	const bond = !controller ? api.tx.staking.bond(fromAddress, amount, 0) : api.tx.staking.bondExtra(amount);

	let transaction = bond.toHex();
	if (difference) {
		const { stakingLedger: { active } } = await api.derive.staking.account(fromAddress);
		const minimumBond = await api.query.staking.minNominatorBond() / DOT_DECIMAL_PLACES;
		if (BigNumber(amount).plus(active).div(DOT_DECIMAL_PLACES).toNumber() >= minimumBond) {
			transaction = api.tx.utility.batch([ bond, api.tx.staking.nominate(validators) ]).toHex();
		} else {
			throw new Error(`Can not stake with value less than ${minimumBond} DOTs`);
		}
