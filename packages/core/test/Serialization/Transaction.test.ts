import { Transaction, TransactionBody } from '../../src/Serialization';
import { TxCBOR } from '../../src';
import { babbageTx, tx as coreTx, signature, vkey } from '../CBOR/testData';

const TX =
  '84af00818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000181825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc820aa3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c411832581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e020a031903e804828304581c26b17b78de4f035dc0bfce60d1d3c3a8085c38dcce5fb8767e518bed1901f48405581c0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4581ca646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a582003170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c11131405a1581de013cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d0050758202ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa08186409a3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c413831581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e0b58206199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de0d818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5010e81581c6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d3910825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc820aa3581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c411832581c7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373a240182846504154415445181e11186412818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d500a700818258206199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d395840bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c891875501868205186482041901f48200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f548201818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f548202818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54830301818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f540281845820deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01584064676273786767746f6768646a7074657476746b636f6376796669647171676775726a687268716169697370717275656c6876797071786565777072796676775820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b45041a003815820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450049f187bff0582840100d87a9f187bff82190bb8191b58840201d87a9f187bff821913881907d006815820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450f5a6011904d2026373747203821904d2637374720445627974657305a2667374726b6579187b81676c6973746b65796873747276616c75650626';

const TX2 =
  '84a60081825820260aed6e7a24044b1254a87a509468a649f522a4e54e830ac10f27ea7b5ec61f01018383581d70b429738bd6cc58b5c7932d001aa2bd05cfea47020a556c8c753d44361a004c4b40582007845f8f3841996e3d8157954e2f5e2fb90465f27112fc5fe9056d916fae245b82583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba1a0463676982583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba821a00177a6ea2581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff198a5447742544319271044774554481a0031f9194577444f47451a0056898d4577555344431a000fc589467753484942411a000103c2581c659ab0b5658687c2e74cd10dba8244015b713bf503b90557769d77a7a14a57696e675269646572731a02269552021a0002e665031a01353f84081a013531740b58204107eada931c72a600a6e3305bd22c7aeb9ada7c3f6823b155f4db85de36a69aa20081825820e686ade5bc97372f271fd2abc06cfd96c24b3d9170f9459de1d8e3dd8fd385575840653324a9dddad004f05a8ac99fa2d1811af5f00543591407fb5206cfe9ac91bb1412404323fa517e0e189684cd3592e7f74862e3f16afbc262519abec958180c0481d8799fd8799fd8799fd8799f581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68ffd8799fd8799fd8799f581c042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339baffffffff581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c681b000001863784a12ed8799fd8799f4040ffd8799f581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff1984577444f4745ffffffd8799fd87980190c8efffff5f6';

const CLI_TX =
  '84a40081825820f6dd880fb30480aa43117c73bfd09442ba30de5644c3ec1a91d9232fbe715aab000182a20058390071213dc119131f48f54d62e339053388d9d84faedecba9d8722ad2cad9debf34071615fc6452dfc743a4963f6bec68e488001c7384942c13011b0000000253c8e4f6a300581d702ed2631dbb277c84334453c5c437b86325d371f0835a28b910a91a6e011a001e848002820058209d7fee57d1dbb9b000b2a133256af0f2c83ffe638df523b2d1c13d405356d8ae021a0002fb050b582088e4779d217d10398a705530f9fb2af53ffac20aef6e75e85c26e93a00877556a10481d8799fd8799f40ffd8799fa1d8799fd8799fd87980d8799fd8799f581c71213dc119131f48f54d62e339053388d9d84faedecba9d8722ad2caffd8799fd8799fd8799f581cd9debf34071615fc6452dfc743a4963f6bec68e488001c7384942c13ffffffffffd8799f4040ffff1a001e8480a0a000ffd87c9f9fd8799fd8799fd8799fd87980d8799fd8799f581caa47de0ab3b7f0b1d8d196406b6af1b0d88cd46168c49ca0557b4f70ffd8799fd8799fd8799f581cd4b8fc88aec1d1c2f43ca5587898d88da20ef73964b8cf6f8f08ddfbffffffffffd8799fd87980d8799fd8799f581caa47de0ab3b7f0b1d8d196406b6af1b0d88cd46168c49ca0557b4f70ffd8799fd8799fd8799f581cd4b8fc88aec1d1c2f43ca5587898d88da20ef73964b8cf6f8f08ddfbffffffffffd8799f4040ffd87a9f1a00989680ffffd87c9f9fd8799fd87a9fd8799f4752656c65617365d8799fd87980d8799fd8799f581caa47de0ab3b7f0b1d8d196406b6af1b0d88cd46168c49ca0557b4f70ffd8799fd8799fd8799f581cd4b8fc88aec1d1c2f43ca5587898d88da20ef73964b8cf6f8f08ddfbffffffffffff9fd8799f0101ffffffd87c9f9fd8799fd87b9fd9050280ffd87980ffff1b000001884e1fb1c0d87980ffffff1b000001884e1fb1c0d87980ffffff1b000001884e1fb1c0d87980fffff5f6';

describe('Transaction', () => {
  it('round trip serializations produce the same CBOR output', () => {
    const tx = Transaction.fromCbor(TxCBOR(TX));
    expect(tx.toCbor()).toBe(TX);
  });

  it('correctly deserialize a CBOR transaction', () => {
    const tx = Transaction.fromCbor(TxCBOR(TX));
    expect(tx.toCore()).toEqual(babbageTx);
  });

  it('correctly converts from a Core transaction', () => {
    const tx = Transaction.fromCore(coreTx);

    expect(tx.body()).toBeInstanceOf(TransactionBody);
    const witnessSet = tx.witnessSet();
    const vKeys = witnessSet.vkeys();
    const witness = vKeys!.values()[0];
    const witnessSignature = witness.signature();
    const vKey = witness.vkey();
    expect(vKey).toBe(vkey);
    expect(witnessSignature).toBe(signature);

    expect(tx.toCore()).toEqual(coreTx);
  });

  it('correctly converts from a Babbage Core transaction', () => {
    const tx = Transaction.fromCore(babbageTx);

    expect(tx.toCore()).toEqual(babbageTx);
  });

  it('can set the isValid flag on the transaction', () => {
    const tx = Transaction.fromCbor(TxCBOR(TX));
    expect(tx.isValid()).toEqual(true);

    tx.setIsValid(false);

    // Perform a round trip serialization.
    const tx2 = Transaction.fromCbor(tx.toCbor());
    expect(tx2.isValid()).toEqual(false);
  });

  it('can set the txBody on the transaction', () => {
    const tx = Transaction.fromCbor(TxCBOR(TX));
    const tx2 = Transaction.fromCbor(TxCBOR(TX2));

    tx.setBody(tx2.body());

    // Perform a round trip serialization.
    const tx3 = Transaction.fromCbor(tx.toCbor());

    expect(tx3.body().toCbor()).toEqual(tx2.body().toCbor());
  });

  it('can set the witness set on the transaction', () => {
    const tx = Transaction.fromCbor(TxCBOR(TX));
    const tx2 = Transaction.fromCbor(TxCBOR(TX2));

    tx.setWitnessSet(tx2.witnessSet());

    // Perform a round trip serialization.
    const tx3 = Transaction.fromCbor(tx.toCbor());

    expect(tx3.witnessSet().toCbor()).toEqual(tx2.witnessSet().toCbor());
  });

  it('can set the witness set on the transaction', () => {
    const tx = Transaction.fromCbor(TxCBOR(TX));
    const tx2 = Transaction.fromCbor(TxCBOR(TX2));

    tx.setAuxiliaryData(tx2.auxiliaryData());

    // Perform a round trip serialization.
    const tx3 = Transaction.fromCbor(tx.toCbor());

    expect(tx3.auxiliaryData()).toEqual(undefined);
  });

  it('can perform a deep clone of the object', () => {
    const referenceTx = Transaction.fromCbor(TxCBOR(TX));
    const tx = Transaction.fromCbor(TxCBOR(TX));
    const cloned = tx.clone();
    const tx2 = Transaction.fromCbor(TxCBOR(TX2));

    // Change original TX object
    tx.setBody(tx2.body());

    // Perform a round trip serialization on the cloned object.
    const tx3 = Transaction.fromCbor(cloned.toCbor());

    expect(tx3.body().toCbor()).toEqual(referenceTx.body().toCbor());
    expect(tx3.body().toCbor()).not.toEqual(tx.body().toCbor());
  });

  it('can compute the right Tx ID', () => {
    expect(Transaction.fromCbor(TxCBOR(TX)).getId()).toEqual(
      '856c8bc6ce3725188b496d62fa389f2beff2f701e6d35af39d3f3464bbce0cec'
    );

    // This transaction was created with the CLI and will cause a round trip difference in the body.
    // If we can compute the right Tx ID it means we are handling the round trip difference correctly.
    //
    // The correct hash can be verified using the cardano-cli as follows:
    //
    // cardano-cli transaction txid --tx-file ./tx  <-- tx contains the CBOR of the transaction.
    //
    // For this particular transaction it should yield the value: '2d7f290c815e061fb7c27e91d2a898bd7b454a71c9b7a26660e2257ac31ebe32'
    expect(Transaction.fromCbor(TxCBOR(CLI_TX)).getId()).toEqual(
      '2d7f290c815e061fb7c27e91d2a898bd7b454a71c9b7a26660e2257ac31ebe32'
    );
  });
});
