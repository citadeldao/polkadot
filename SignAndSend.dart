Future<Map<String, dynamic>> polkadotSignAndSend({
    @required String session,
    @required String address,
    @required String signature,
    @required String payload,
    @required String unsignedTx,
  }) async {
    await connectivityCheck();
    dioCookie.session = session;

    try {
      final response =
          await dioCookie.instance.post('$apiUrl/polkadot/$address/signAndSend',
              data: json.encode({
                "unsignedTx": unsignedTx,
                "signature": signature,
                "payload": payload,
              }));
      return response?.data;
    } on DioError catch (e) {
      if (e.response != null &&
          e.response.data != null &&
          e.response.data['error'] != null) {
        if (e.response.data['error'] is List &&
            e.response.data['error'][0]['msg'] != null) {
          throw TransactionException(e.response.data['error'][0]['msg']);
        } else {
          if (e.response.data['error']['message']?.isNotEmpty ?? false) {
            throw TransactionException(e.response.data['error']['message']);
          } else {
            throw TransactionException(e.response.data['error']?.toString());
          }
        }
      }
      throw TransactionException(e.error);
    } catch (e) {
      throw TransactionException("An error occurred please try again.");
    }
  }
