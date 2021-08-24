methods.getDelegationBalanceInfo = async (address) => {
	await api.isReadyOrError;
	const { vestedClaimable, availableBalance } = await api.derive.balances.all(address);
	const { redeemable, stakingLedger, unlocking } = await api.derive.staking.account(address);
	
	let { index: activeEra, start: startDate } = (await api.query.staking.activeEra()).toHuman();
	startDate = new Date(parseInt(startDate.replace(/,/g, '')));
	activeEra = parseInt(activeEra);
	
	let frozenBalance = 0;
	if (unlocking) {
		unlocking.forEach((i) => {
			frozenBalance += i.value / DOT_DECIMAL_PLACES;
		});
	}
