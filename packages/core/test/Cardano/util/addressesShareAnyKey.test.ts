import { Cardano } from '../../../src/index.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';

const pairs = <T>(arr: T[]) => arr.flatMap((v, i) => arr.slice(i + 1).map((w) => [v, w] as const));
const allAddressesShareAnyKey = (addresses: Array<{ toAddress(): Cardano.Address }>) =>
  pairs(addresses.map((addr) => addr.toAddress().toBech32() as Cardano.PaymentAddress)).every(([addr1, addr2]) =>
    Cardano.util.addressesShareAnyKey(addr1, addr2)
  );

describe('addressesShareAnyKey', () => {
  const paymentKeyHash1 = Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80c');
  const paymentKeyHash2 = Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');
  const stakeKeyHash1 = Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80e');
  const stakeKeyHash2 = Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80f');
  const stakeKeyPointer: Cardano.Pointer = {
    certIndex: Cardano.CertIndex(1),
    slot: Cardano.Slot(123),
    txIndex: Cardano.TxIndex(2)
  };

  it('returns false when addresses do not share any key', () => {
    expect(
      Cardano.util.addressesShareAnyKey(
        Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
        Cardano.PaymentAddress(
          'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
        )
      )
    ).toBe(false);
  });

  it('returns true when address equals', () => {
    expect(
      Cardano.util.addressesShareAnyKey(
        Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'),
        Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t')
      )
    ).toBe(true);
    expect(
      Cardano.util.addressesShareAnyKey(
        Cardano.PaymentAddress('5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg'),
        Cardano.PaymentAddress('5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg')
      )
    ).toBe(true);
  });

  it('returns true when addresses have the same payment credential key hash', () => {
    const mainnetEnterpriseAddr = Cardano.EnterpriseAddress.fromCredentials(Cardano.NetworkId.Mainnet, {
      hash: paymentKeyHash1,
      type: Cardano.CredentialType.KeyHash
    });
    const testnetEnterpriseAddr = Cardano.EnterpriseAddress.fromCredentials(Cardano.NetworkId.Testnet, {
      hash: paymentKeyHash1,
      type: Cardano.CredentialType.ScriptHash
    });
    const mainnetBaseStake1Addr = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      {
        hash: paymentKeyHash1,
        type: Cardano.CredentialType.KeyHash
      },
      {
        hash: stakeKeyHash1,
        type: Cardano.CredentialType.ScriptHash
      }
    );
    const testnetBaseStake2Addr = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Testnet,
      {
        hash: paymentKeyHash1,
        type: Cardano.CredentialType.KeyHash
      },
      {
        hash: stakeKeyHash2,
        type: Cardano.CredentialType.ScriptHash
      }
    );
    const mainnetPointer = Cardano.PointerAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      {
        hash: paymentKeyHash1,
        type: Cardano.CredentialType.KeyHash
      },
      stakeKeyPointer
    );

    expect(
      allAddressesShareAnyKey([
        mainnetBaseStake1Addr,
        testnetBaseStake2Addr,
        testnetEnterpriseAddr,
        mainnetEnterpriseAddr,
        mainnetPointer
      ])
    ).toBe(true);
  });

  it('returns true when addresses have the same stake credential key hash', () => {
    const addr1 = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      {
        hash: paymentKeyHash1,
        type: Cardano.CredentialType.KeyHash
      },
      {
        hash: stakeKeyHash1,
        type: Cardano.CredentialType.ScriptHash
      }
    );
    const addr2 = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Testnet,
      {
        hash: paymentKeyHash2,
        type: Cardano.CredentialType.KeyHash
      },
      {
        hash: stakeKeyHash1,
        type: Cardano.CredentialType.ScriptHash
      }
    );

    expect(allAddressesShareAnyKey([addr1, addr2])).toBe(true);
  });

  it('returns true when addresses have the same stake key pointer', () => {
    const addr1 = Cardano.PointerAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      {
        hash: paymentKeyHash1,
        type: Cardano.CredentialType.KeyHash
      },
      stakeKeyPointer
    );
    const addr2 = Cardano.PointerAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      {
        hash: paymentKeyHash2,
        type: Cardano.CredentialType.KeyHash
      },
      stakeKeyPointer
    );

    expect(allAddressesShareAnyKey([addr1, addr2])).toBe(true);
  });
});
