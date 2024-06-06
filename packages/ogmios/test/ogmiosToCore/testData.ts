import { Cardano } from '@cardano-sdk/core';
import { fromSerializableObject } from '@cardano-sdk/util';
import type { Ogmios } from '../../src/index.js';

// Mock data extracted using ogmios chain-sync api from the preprod network
export const mockByronBlock: Ogmios.Schema.Byron = {
  byron: {
    body: { dlgPayload: [], txPayload: [], updatePayload: { proposal: null, votes: [] } },
    hash: '5c3103bd0ff5ea85a62b202a1d2500cf3ebe0b9d793ed09e7febfe27ef12c968',
    header: {
      blockHeight: 42,
      genesisKey:
        '63e55a8f421a31eab4fa85a342be61884978124f9c5ac2aaee6b9f4cee30b9ed91e80e80325a840c857bbd8b1ddcd656a261b90c6730480c3612fd4ccf6e8b20',
      prevHash: 'dd8d7559a9b6c1177c0f5a328eb82967af68155d58cbcdc0a59de39a38aaf3f0',
      proof: {
        delegation: 'afc0da64183bf2664f3d4eec7238d524ba607faeeab24fc100eb861dba69971b',
        update: '4e66280cd94d591072349bec0a3090a53aa945562efb6d08d56e53654b0e4098',
        utxo: {
          number: 0,
          root: '0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8',
          witnessesHash: 'afc0da64183bf2664f3d4eec7238d524ba607faeeab24fc100eb861dba69971b'
        }
      },
      protocolMagicId: 1,
      protocolVersion: { major: 2, minor: 0, patch: 0 },
      signature: {
        dlgCertificate: {
          delegateVk:
            '618b625df30de53895ff29e7a3770dca56c2ff066d4aa05a6971905deecef6dbb7dd10ea1f9175e5293eadec97bf16b167af379a7b3ed4af032cd07b99ecc1ea',
          epoch: 0,
          issuerVk:
            '63e55a8f421a31eab4fa85a342be61884978124f9c5ac2aaee6b9f4cee30b9ed91e80e80325a840c857bbd8b1ddcd656a261b90c6730480c3612fd4ccf6e8b20',
          signature: 'yjjmiOdZGDtX0IymVoJIuRyN3YHlbQ0xw/Oibso1dUOHxfMB7wF9r65FOpN1fTmg4tMm6+Wc8x1cGyL8hhasAA=='
        },
        signature: 'k8f+GE++0EqaU15eHwyRmjx1q4PkKYsGYNn5+4+HqyIhUJp+U3c8UCQfGJzJkmPXNuBpYwNpMqR0dlyFFo06AQ=='
      },
      slot: 77_761,
      softwareVersion: { appName: 'cardano-sl', number: 1 }
    }
  }
};

export const mockShelleyBlock: Ogmios.Schema.Shelley = {
  shelley: {
    body: [],
    header: {
      blockHash: '1033376be025cb705fd8dd02eda11cc73975a062b5d14ffd74d6ff69e69a2ff7',
      blockHeight: 1087,
      blockSize: 3,
      issuerVk: '8b0960d234bda67d52432c5d1a26aca2bfb5b9a09f966d9592a7bf0c728a1ecd',
      issuerVrf: 'phWWpLfWnf+u6GEWsVxOHNAHjY17sXED7jgH0mnpBTk=',
      leaderValue: {
        output: 'ZF97DP3S397Nfq92ONpp71blPUGj0cbYQVo97NMHeGBYPWd4EaWZ84ZaMLzfJhMZUjQFEGIqu1Ud9IHESeDWlA==',
        proof:
          'epv9SsB1F5Qxl+c+ICvg5zVlcl3KoxRsjUYLTEB2/HFVO2axpas3yxdl3dogc/FjDnSywZuABeo6mlzbqinTB1gb0OJEi94409TxnMh4kQk='
      },
      nonce: {
        output: '91OdoWjut1k57TgBVwn8skB+vaW41UPjhIat9FxkeqwjJmjFwleniCd6lt1/jPoK7kM9CTGjjeMlM0Hx1PpyBQ==',
        proof:
          'FoVPvE8WXWZPGV6N34UKGO4eYqTq9nJ9HXYYNcRwRMStIFU1IcXycZYfQDbQmBNM4G8MoGbkLwtjmQNof/Gkt/fgQaenzuR2AYQ16Y0TxAk='
      },
      opCert: {
        count: 0,
        hotVk: 'ZE19caAXs+5318K36Z6qxqgqa+BbMorotBNPORRoWlY=',
        kesPeriod: 0,
        sigma: 'JFL7hL7IjPzyuTcPLNDVmbPolzSbH+NyGkzP6hsPeSCMtzX0ZgoDGLCfgw8Iw3rxdyg8VypMklmG2Pzv3iGVBg=='
      },
      prevHash: '8d5d930981710fc8c6ca9fc8e0628665283f7efb28c7e6bddeee2d289f012dee',
      protocolVersion: { major: 3, minor: 0 },
      signature:
        '3nZG/HqNVVrPk5AMIt36PXFU4aKE2r0PDWFPq6+3j9wwg6YohJSFbHdE2BJjWN/WKbqCwUD17o3OB05EiFh7BJy4fKozuTpJrsr2GXgzR+UrtygDE3xR+WPp8JF5JAWkXrMD8fuRnwrYi1QUE7ApMl1220qkkgqisPSS9omTNbuNNUkaayjsNJC7q2X0rK67Mz/fybA7NQ8KSlynEshQeXe9CrE13qpm0xM1HgnbRLx+cqin4vCxjD/dLppQdrv3F9a3Jez0HbjO3EMZR1QpCr4dasw26Bv5omfdmnqeot48N42t1S7LIjXneFCBBkWA/L+4wPcet9eo8vlRYchpKRpb4+GReHk+B8BhigH6dqTtiQP97+dr/guRX+bPso/zlg2H1zTJFGHEZlkQuvabNVQ7rtGdCVbDNFnpJoXxvPJRXOK3U7xREuPQwM6RKTmUYgC/g4C3jAM1nWtbrpy+3wYZlRayG6z/vR4Bc1FXMGzImVvJciiGNB73MEPaLUJkZ8Sq84PdB5uKVn6OLd3EtDUHdDLzv+j47ErAPPuTx4FsnMvRXRQsi9M008/XE/jKqp7vKuuWGDVPOC7bpjhvLA==',
      slot: 107_220
    },
    headerHash: '071fceb6c20a412b9a9b57baedfe294e3cd9de641cd44c4cf8d0d56217e083ac'
  }
};

export const mockAlonzoBlock: Ogmios.Schema.Alonzo = {
  alonzo: {
    body: [
      {
        body: {
          certificates: [
            {
              stakeDelegation: {
                delegatee: 'pool15erywju02scjv9gxkmp885c8catf5n4ke9459h2299fq57u9c3e',
                delegator: 'f2f6381fa7a3dcc144939b47dffb7dad677856dfbbee4c4b7e426049'
              }
            },
            {
              stakeKeyDeregistration: 'f2f6381fa7a3dcc144939b47dffb7dad677856dfbbee4c4b7e426049'
            },
            {
              poolRetirement: {
                poolId: 'pool15erywju02scjv9gxkmp885c8catf5n4ke9459h2299fq57u9c3e',
                retirementEpoch: 123
              }
            },
            {
              genesisDelegation: {
                delegateKeyHash: 'e0a714319812c3f773ba04ec5d6b3ffcd5aad85006805b047b082541',
                verificationKeyHash: 'b16b56f5ec064be6ac3cab6035efae86b366cc3dc4a0d571603d70e5',
                vrfVerificationKeyHash: '95c3003a78585e0db8c9496f6deef4de0ff000994b8534cd66d4fe96bb21ddd3'
              }
            }
          ],
          collaterals: [],
          fee: 202_549n,
          inputs: [
            { index: 0, txId: '1a3380c51384d151b876de02b7a4c5ca7eda7b1d1d744660aee4647516fd9a81' },
            { index: 1, txId: '1a3380c51384d151b876de02b7a4c5ca7eda7b1d1d744660aee4647516fd9a81' }
          ],
          mint: { assets: {}, coins: 0n },
          network: null,
          outputs: [
            {
              address: 'addr_test1vpfwv0ezc5g8a4mkku8hhy3y3vp92t7s3ul8g778g5yegsgalc6gc',
              datum: null,
              datumHash: null,
              value: { assets: {}, coins: 999_978n }
            },
            {
              address: 'addr_test1vpfwv0ezc5g8a4mkku8hhy3y3vp92t7s3ul8g778g5yegsgalc6gc',
              datum: 'c5dfa8c3cbd5a959829618a7b46e163078cb3f1b39f152514d0c3686d553529a',
              datumHash: 'c5dfa8c3cbd5a959829618a7b46e163078cb3f1b39f152514d0c3686d553529a',
              value: { assets: {}, coins: 8_286_924_731n }
            }
          ],
          requiredExtraSignatures: [],
          scriptIntegrityHash: null,
          update: null,
          validityInterval: { invalidBefore: null, invalidHereafter: 5_581_748 },
          withdrawals: {}
        },
        id: 'bb81604e09c4530ad02de6b80a0c13d82949fb307402dd0c2b447e211bdc621d',
        inputSource: Cardano.InputSource.inputs,
        metadata: {
          body: {
            blob: {
              '674': {
                map: [
                  {
                    k: { string: 'msg' },
                    v: {
                      list: [
                        { string: 'Auto-Loop-Transaction #338666 by ATADA' },
                        { string: '' },
                        { string: 'Live Epoch 16, we have 061h 17m 32s left until the next one' },
                        { string: "It's Montag - 22 August 2022 - 12:42:28 in Austria" },
                        { string: '' },
                        { string: '📈 The current ADA Price on Kraken is: $0.451502 / ADA' },
                        { string: '' },
                        { string: 'A random Zen-Quote for you: 🙏' },
                        { string: 'There are three classes of people: those who see. Those who see' },
                        { string: 'when they are shown. Those who do not see. - Leonardo da Vinci' },
                        { string: '' },
                        { string: 'Node-Revision: 950c4e222086fed5ca53564e642434ce9307b0b9' },
                        { string: '' },
                        { string: 'PreProd-Chain is awesome, have some fun! 😍' },
                        { string: ' Best regards, Martin :-)' }
                      ]
                    }
                  }
                ]
              }
            },
            scripts: []
          },
          hash: '0ad6d4a6e10182157142994b2cce2aebee9406e3e2be31bfb1574ed2409a71dc'
        },
        raw: 'hKUAgoJYIBozgMUThNFRuHbeArekxcp+2nsdHXRGYK7kZHUW/ZqBAIJYIBozgMUThNFRuHbeArekxcp+2nsdHXRGYK7kZHUW/ZqBAQGCglgdYFLmPyLFEH7XdrcPe5IkiwJVL9CPPnR7x0UJlEEaAA9CKoJYHWBS5j8ixRB+13a3D3uSJIsCVS/Qjz50e8dFCZRBGwAAAAHt8G+7AhoAAxc1AxoAVSu0B1ggCtbUpuEBghVxQplLLM4q6+6UBuPivjG/sVdO0kCacdyhAIGCWCB0LYrzVDNJtbGPPLoo8jstbkZbnBNsQuH65rI5D1ZUJ1hASE0MJCvCQBY6GshFaPv4cNg8//csJTLCrLUdEqIium57YzPIgSPubgTKeMPGHC1ZMuogYsWQk6lfzEw1w0EyBvXZAQOhAKEZAqKhY21zZ494JkF1dG8tTG9vcC1UcmFuc2FjdGlvbiAjMzM4NjY2IGJ5IEFUQURBYHg7TGl2ZSBFcG9jaCAxNiwgd2UgaGF2ZSAwNjFoIDE3bSAzMnMgbGVmdCB1bnRpbCB0aGUgbmV4dCBvbmV4Mkl0J3MgTW9udGFnIC0gMjIgQXVndXN0IDIwMjIgLSAxMjo0MjoyOCBpbiBBdXN0cmlhYHg48J+TiCBUaGUgY3VycmVudCBBREEgUHJpY2Ugb24gS3Jha2VuIGlzOiAkMC40NTE1MDIgLyBBREFgeCBBIHJhbmRvbSBaZW4tUXVvdGUgZm9yIHlvdTog8J+Zj3g/VGhlcmUgYXJlIHRocmVlIGNsYXNzZXMgb2YgcGVvcGxlOiB0aG9zZSB3aG8gc2VlLiBUaG9zZSB3aG8gc2VleD53aGVuIHRoZXkgYXJlIHNob3duLiBUaG9zZSB3aG8gZG8gbm90IHNlZS4gLSBMZW9uYXJkbyBkYSBWaW5jaWB4N05vZGUtUmV2aXNpb246IDk1MGM0ZTIyMjA4NmZlZDVjYTUzNTY0ZTY0MjQzNGNlOTMwN2IwYjlgeC1QcmVQcm9kLUNoYWluIGlzIGF3ZXNvbWUsIGhhdmUgc29tZSBmdW4hIPCfmI14GSBCZXN0IHJlZ2FyZHMsIE1hcnRpbiA6LSk=',
        witness: {
          bootstrap: [],
          datums: {},
          redeemers: {},
          scripts: {},
          signatures: {
            '742d8af3543349b5b18f3cba28f23b2d6e465b9c136c42e1fae6b2390f565427':
              'SE0MJCvCQBY6GshFaPv4cNg8//csJTLCrLUdEqIium57YzPIgSPubgTKeMPGHC1ZMuogYsWQk6lfzEw1w0EyBg=='
          }
        }
      }
    ],
    header: {
      blockHash: '81f6f3ded8f36d7a2c2ca7ce2e17e92ed1c89a10614ce3809147e00c62737be2',
      blockHeight: 100_000,
      blockSize: 836,
      issuerVk: 'a9d974fd26bfaf385749113f260271430276bed6ef4dad6968535de6778471ce',
      issuerVrf: 'CeFCQT5qIMSNzwvB4WBNIuxsFoKAIhLBML2LCIj6klo=',
      leaderValue: {
        output: 'AFDmQN+gYm96xAXIPUC2xxydypzSwqAXls3zO59QANqqORSy1kudgcx5rhatWwIsezanVHdTGgN7u3/2w9O1hw==',
        proof:
          '1JXMj5k6O+rFp070XnPkgvZB7oPmcv7iPOYTiMZyKRYNSIPTt45+VQqTPMqJYqDVblVMK+fX/2IGaZLjqbZ4k3E1b8PXV6Qc5Dz87hxq9AI='
      },
      nonce: {
        output: 'FyuHnIpMWP7WL0W+O1+ME20w9nXwLX7lDY2Erw06ooEM7+vXnGAsRz1rfSnR4OmOO820Qpt8HvTUpi/XRgAKFw==',
        proof:
          'GLq7HB8ieEIJ4Ibnd/c1+llYsF7kzGXDgtjwzwCv3z6YFk2Y+FlEmv0+Ro1P2hm/s654hd8XHZkaa/51ZACkClwfYhLVxYsiTzpkrrZuiAI='
      },
      opCert: {
        count: 0,
        hotVk: 'ysODGAjAo6l3jFFhqfsy10OYCuDBhPp3y3n0uKdy5rI=',
        kesPeriod: 0,
        sigma: 'RjhSh4wwXa0vokE78kBsN2W52PxEDRa8ZJykaTZg3rPzgBvMGtsv/XeAesGBl1pEJYkF59voPnSUYqg+4ugIBg=='
      },
      prevHash: '518a24a3fb0cc6ee1a31668a63994e4dbda70ede5ff13be494a3b4c1bb7709c8',
      protocolVersion: { major: 7, minor: 2 },
      signature:
        '4tQuhpOv/vlwSHuhsiYh0M7bbTnH2fss3C9pAvQmWZ07ZG1ADzlFE7oe4a5Gm1lhoqeLQbTE4gJbemsM6ppaAE+K3XZfRhjOM6TwRMJKjeu37aCvGRGKgRg9vZmXrglVAX6GjThReulcxrhmotP+3SrovbP9Ip48ZMbfqxF1ZHQ6odHxnVcc65Mr6lIM8fLnhwxrDKdmN1E0ItzqAbSGVQgeFTqd+RM5r6EPoYkY028Q1o30sPH09a+Ub7qACDHpwHiVlOGolUlAnkks00hY5lvOL9awe4w2bhahOEwixaCChsj6IA1cDAYhWD+6ZK1crxJGOPMoZJ2OXnhmnvYO6eshfDGVbwT+qnssvL6g0TdZzA4Rk6YcLTd9UWLHIt977deE6ZRhiRORRA5Zmv7aFThYGaDwIM9MTxrVtMb87xEJXT2WElA72r39H8vnz7UIeKcw3vLldwmGVTcmH0Y0qUCey+y0mDXAIIYkx0530AmPbOz/nAcOhfSJdL9lPfiPK61Nm/kU13a/OOvdFi26Cg5NKFsmDkGJEvGQj+eBmYcyAwtBRiJbpudUJ6/mdYEtPUz0SFgjnPDXUThJs4LYdA==',
      slot: 5_481_752
    },
    headerHash: '514f8be63ef25c46bee47a90658977f815919c06222c0b480be1e29efbd72c49'
  }
};

export const mockAlonzoBlockEmptyBody: Ogmios.Schema.Alonzo = {
  alonzo: {
    body: [],
    header: {
      blockHash: '29571d16f081709b3c48651860077bebf9340abb3fc7133443c54f1f5a5edcf1',
      blockHeight: 23_000,
      blockSize: 4,
      issuerVk: '9691ed9d98a5b79d5bc46c4496a6dba7e103f668f525c8349b6b92676cb3eae4',
      issuerVrf: '6knkZSxGC57m2q/vyZnKZn++XrXXp66rvf9v4ZwaPJ8=',
      leaderValue: {
        output: 'AwPhdFUfEYbokiJq1cjwieRXR8r5/QpEj2SXdyzgs86T9dX4tdZCrSSmTHTWroIWjbxSqjoH+ttov1jymhk3JQ==',
        proof:
          'tx5VXLJtU7zbTH/mhU7vCiGt2AFA287y/OzGXNu1NGre0juZPbEsLNgY9BaO9AMg3FPLmu39O+Ka4xOp0ewL0EwbLmIc8iXLGysAqYN3MwE='
      },
      nonce: {
        output: 'jdnCzYdUjUpxzT4Hb3j3U0E9+XX/Fip5eSknNcin5wlTVoBGIJI9yul5bfCs8LdXFuupdRRZpZHcmWnFcJShlQ==',
        proof:
          '/6l+pabQB4QlQWR8kKMjplgnDyBQj2efijEhHj9nzF1HNkgeY642La8069fEuFvojXVszcBcC23u1Qg8csC2HIGKRm7WwnOBkTXPQLbNMAU='
      },
      opCert: {
        count: 0,
        hotVk: '5493ENKPo6J9IQ56RhQAHh/vnih8nEdv04SBWXz8VN8=',
        kesPeriod: 0,
        sigma: '3T+5K94zX11ty1Ha8pje6tbyoWTgeMS441rtY1UB5pbS/oPugKt4E0qUTeIOx50FzHAuuJ6qcXEYsXuhryt/Dw=='
      },
      prevHash: 'e08f4606b4da6226261ba3f7c95e16f9d4ef57a3800c9e42aba908939dd759d9',
      protocolVersion: { major: 6, minor: 0 },
      signature:
        'PuxzmKb+HPYKp/i8qusmz1Wr5Npx7G6Fi38flIQ2mq8/aXv12T0isyk0ZrxQJ7Su00IdCjWzru5eszlQ1Fh4A7jhuEBC7a2a7+d/J+nS4BbW51VMAVkpFvMuhkI53f5bZReEaNUowh6FIHzYZD+LAPwE83S3sfpM4tFqwC/lklC5ekjzQXB8ZThou0/+y1VaTWsM5vRDtoFg1tua5PH+l/56FOIJC2ff8ZUM2fPr8z3mGcCPl4A8Xi6WS3Lu0pw5Kdn0ExkkIu0flpnHi8uKYiyf7ifJgCOcCBjppr5lIm9CABPBJjBrbD7GDAJPQCopp3GWcV1AIbDYgUkz7zGsQm1sC5Ilz5CRqFN2dyDiodvLeO6s8Cf3Veb6TTLSceoWRz7z7eOjcPwGddHq783xyoHff0OiojvfmNEks5fC/sP3eWnLfpK3ii1mB+p01T8epBtd3fGwsMZBQ9VDpsnovvRHJgfFLY1PrMzTFp8h5jVIQ9gVAzue7z/Vfi20QKIzz3nA5arNY3WDUEmJe128fvjIUifXO6J1XHcu1vitHCledw4FGlzDyA/fWOwlv4rs1LxqAvUtZt1k67f8lBtaaA==',
      slot: 3_900_835
    },
    headerHash: '1b1af00bfa1ecdf2844bb9a3fb703e57d5854d077f444cbddefa7c107c908040'
  }
};

// Data from ogmios test data
export const mockAllegraBlock: Ogmios.Schema.Allegra = {
  allegra: {
    body: [
      {
        body: {
          certificates: [],
          fee: 724n,
          inputs: [{ index: 2, txId: '03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314' }],
          outputs: [],
          update: { epoch: 57_293, proposal: {} },
          validityInterval: { invalidBefore: null, invalidHereafter: 79_985 },
          withdrawals: {}
        },
        id: '8ba812bad0c356ec842365720acb4a4ea18f03d40b03ad1cc785426170d542f5',
        metadata: {
          body: {
            blob: { '2': { list: [{ int: 9_798_604_473_814_314_674n }, { bytes: '7a43' }] } },
            scripts: [
              { native: 'b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54' },
              { native: 'a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a' },
              {
                native: {
                  all: [
                    { any: [] },
                    '58e1b65718531b42494610c506cef10ff031fa817a8ff75c0ab180e7',
                    { any: [{ expiresAt: 15_272 }] },
                    { startsAt: 44_521 },
                    { startsAt: 91_998 }
                  ]
                }
              }
            ]
          },
          hash: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25'
        },
        raw: 'g6YAgYJYIAMXCi51l7e349hMBTkdE5pisVfnh4bYwILync9MERMUAgGAAhkC1AMaAAE4cQaCoBnfzQdYIO4VWs6cQCkgdMtq/4yczdJzyBZI/xFJ7za86m67ij4logCCglggiNacI7VLJ/JTqlGXFFi9IbXXAKkfAv6iNzv3bmnTOsFYQLej5LvyQ1sxt1RvfiFztIokFgDyUzxiFFGLJPa/jc3Xo1nryRrlzuIYtCO5vqoSUa7Gp/ykZmGCO4+uxz4euYKCWCAMa+ZqZpp+WY1JusIIo3YPcC7S9ZNp9O+/S+8+JamUKFhAUoOamH2dMBoP4TGfLCtH/e+UeWtnQArGF1JwiTTE/2N4pdC8aAP+pj9Qc+mn+DDrP0+GMa2OEP5j+OsZ6uPK8QKFhFgg5zHRhxzJIvbaxJ4xMMA/3XBsVl4snWTAK25amlI5umdYQG9zd3F5bXhzd2V5bmN3YmhkaW56Z3lnaGFjZHNlYWp1bXVvdHR0eW9oaWJ1Ym5jdHR6bmV1a2dnbG1qdml1aW9Evrp2J0RKfmTJhFgg8PX/pDLnk24fRwkqqAWtNPGYvSsAuvsZULQdyGS0eHRYQGl1c2J0Y3p3cGppYXphaW9qYnlqZHhzZGZqdGl5aGl2Z2p4ZXhyd2dlcXdjZm9sZmF2Ynlib3R2ZXlibWVrb2xAQnRQhFggUB0hoDiDKjfR0c7Bd2l620mJVOP6QxVJgQjJykjQ5RtYQBD21s0wtG5e7hq/l8Z89CbiN2rEEJRcEBgj87Oyif6kIprlJJk/N1XL865plJJyxGE6Azq1JffWWg/IVp9flXhEBndwA0CEWCC5mr4xcA8HyqYLGsb39V8A5ckm3qBsAkUaiO7+noGi+lhAZG9zbnpqaXZ0aWVrbGt1dGZiaHVycHdiY2phbHRjZXdpYWxqdXRlc2FvdGFhem16dXZwdWJxZWF1dHFibm90ZUGCQTOEWCDPsKmIUWNkAQdV/ksAmC3TfMZ4+tT+Z7v3uP+Fry2keFhAwMMYEVUlWj+nr4N/2RpZmhxUNDgeajgjmyZg8ivHs3iC31dsgHu9OFJ1tWZHxwayT8nWtSAIPE+GW9T0trFgeUHMQSyCoQKCG4f7otqMQW6yQnpDg4IAWBy1rmY6rqjlABV730uq/W9boM5XWffNQQH8Ey9UggBYHKZGR0uPVDEmFQa2wnPTB8dWmk62yWtC3UopUgqCAYWCAoCCAFgcWOG2VxhTG0JJRhDFBs7xD/Ax+oF6j/dcCrGA54ICgYIFGTuoggQZremCBBoAAWde',
        witness: {
          bootstrap: [
            {
              addressAttributes: 'Sn5kyQ==',
              chainCode: 'beba7627',
              key: 'e731d1871cc922f6dac49e3130c03fdd706c565e2c9d64c02b6e5a9a5239ba67',
              signature: 'b3N3cXlteHN3ZXluY3diaGRpbnpneWdoYWNkc2VhanVtdW90dHR5b2hpYnVibmN0dHpuZXVrZ2dsbWp2aXVpbw=='
            },
            {
              addressAttributes: 'dFA=',
              chainCode: null,
              key: 'f0f5ffa432e7936e1f47092aa805ad34f198bd2b00bafb1950b41dc864b47874',
              signature: 'aXVzYnRjendwamlhemFpb2pieWpkeHNkZmp0aXloaXZnanhleHJ3Z2Vxd2Nmb2xmYXZieWJvdHZleWJtZWtvbA=='
            },
            {
              addressAttributes: null,
              chainCode: '06777003',
              key: '501d21a038832a37d1d1cec177697adb498954e3fa4315498108c9ca48d0e51b',
              signature: 'EPbWzTC0bl7uGr+Xxnz0JuI3asQQlFwQGCPzs7KJ/qQimuUkmT83VcvzrmmUknLEYToDOrUl99ZaD8hWn1+VeA=='
            },
            {
              addressAttributes: 'Mw==',
              chainCode: '82',
              key: 'b99abe31700f07caa60b1ac6f7f55f00e5c926dea06c02451a88eefe9e81a2fa',
              signature: 'ZG9zbnpqaXZ0aWVrbGt1dGZiaHVycHdiY2phbHRjZXdpYWxqdXRlc2FvdGFhem16dXZwdWJxZWF1dHFibm90ZQ=='
            },
            {
              addressAttributes: 'LA==',
              chainCode: 'cc',
              key: 'cfb0a988516364010755fe4b00982dd37cc678fad4fe67bbf7b8ff85af2da478',
              signature: 'wMMYEVUlWj+nr4N/2RpZmhxUNDgeajgjmyZg8ivHs3iC31dsgHu9OFJ1tWZHxwayT8nWtSAIPE+GW9T0trFgeQ=='
            }
          ],
          scripts: {},
          signatures: {
            '0c6be66a669a7e598d49bac208a3760f702ed2f59369f4efbf4bef3e25a99428':
              'UoOamH2dMBoP4TGfLCtH/e+UeWtnQArGF1JwiTTE/2N4pdC8aAP+pj9Qc+mn+DDrP0+GMa2OEP5j+OsZ6uPK8Q==',
            '88d69c23b54b27f253aa51971458bd21b5d700a91f02fea2373bf76e69d33ac1':
              't6Pku/JDWzG3VG9+IXO0iiQWAPJTPGIUUYsk9r+NzdejWevJGuXO4hi0I7m+qhJRrsan/KRmYYI7j67HPh65gg=='
          }
        }
      }
    ],
    header: {
      blockHash: '03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314',
      blockHeight: 13,
      blockSize: 503,
      issuerVk: '60337a64656bf2646f66c90ab4a546bbf3c3f5f8f00bf06fcc1d9f7d01d924f6',
      issuerVrf: 'nIRtRLQUxE0H2Z5U0DvE94YKiT3ISOUzW8oBPl8h2lA=',
      leaderValue: {
        output: 'RhkcpJCfqui0ksnrpt7kV9S1NEMsrC/w+0BpswUyhm8i+Dcb5/2tGE7Rbmr1mO5cKapCtwwXJiAZozrYWO3wOQ==',
        proof:
          'vVZ7Pzx5hTsa2iTBvbnVA4+xRIaD0/kNe1uC95zskUQFVcQ5k5k2IUPtkKnKH8q8qWrgZSWcbVM3wEOpXzq3olLrdWlseKdkObh5ObLy/w4='
      },
      nonce: {
        output: 'C0vcKTwQRIMJCVDbDSmjTsBiKfzMvbweRg6PhHRKrJ0Wzp4TmbVMREZbAH8B+JO8XXsbo5yz6/KhkFngJSULBA==',
        proof:
          'T08Xle7VEJ/DcQFs+5j6j4eJuov1t8w+E0QVBghQsBdma2BX79smiGbFviHqNoUWho0ZxpHBwrnVMuJt+z/VxUGEsz/KmHi87aA0rUzOJQ0='
      },
      opCert: {
        count: 1,
        hotVk: 'lE8fWiClGVIGkGvy6IqxUhnqFPc5Jkhsr+GNNaJhe7k=',
        kesPeriod: 1,
        sigma: 'emQIwhlN83mtldrYI2orhkk6CSzO79ohGMIoZldBOSv2WZ7suQ1yeymQXvkbdjsmQptX/S2gSNXNoLt6AFgcCQ=='
      },
      prevHash: 'bb30a42c1e62f0afda5f0a4e8a562f7a13a24cea00ee81917b86b89e801314aa',
      protocolVersion: { major: 0, minor: 0 },
      signature:
        'ghmQHjsix7e6begTi1VxLsqciECKFjnHWSl1RePg4bY+4H0NPdeHD6Rda46rDHorfB54xiVM9xh+mXJfbWC+DittNEdQBsnS70eV3uHWsdgoIba+pSgQKNap98X1C/hrVqOFS/9VxXkvZFQy00cHiXCApbjkrz81hmb/jQpUXsAY6vOj+MafwkWoePsuHoez6WvFdLgPH+81f6Oynj7RMI652xDCaFUjrHAlgiLBz3HlG+blms2pGrR+tPKvlnmMpPehzkJTh/NKgCZKARIRLfzxo48pBKS7K/RnXOiwPV7ROoJC0aF5ojWST3dxMP4AoTuJqT85HAl/wnce0jg9Z2Ab5ZpIaJ4hq+SWN8IxFvwVg2C3ADN60fQ+3fR5S84H6rrfTQkjJ5tr7kGCBgJX5sgVGCqjgqTbmGNCp8PiPA+tWXt/JRgSMiw/RFzVq0bei8jGz13MT2fM3S5Vz4DfglDEATOYtm2bB66+ny3Xi2JqfDvLiIeNMHl7KGhkTJvoGXpzdQB19BzBshvG2g+e0T9Wf+QIrZ11ScfaVoi7vQ/KjljBxZhgrWJwxH/HWYri2JK2wF2y7T7jTlMER8pnGQ==',
      slot: 9
    },
    headerHash: 'bb30a42c1e62f0afda5f0a4e8a562f7a13a24cea00ee81917b86b89e801314aa'
  }
};

export const mockMaryBlock: Ogmios.Schema.Mary = {
  mary: {
    body: [
      {
        body: {
          certificates: [
            { stakeKeyRegistration: 'b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54' },
            {
              genesisDelegation: {
                delegateKeyHash: 'a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a',
                verificationKeyHash: '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4',
                vrfVerificationKeyHash: '03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314'
              }
            }
          ],
          fee: 125n,
          inputs: [{ index: 0, txId: '0268be9dbd0446eaa217e1dec8f399249305e551d7fc1437dd84521f74aa621c' }],
          mint: { assets: { a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a: -1n }, coins: 0n },
          outputs: [
            {
              address:
                'EqGAuA8vHnNpWh2vRvJSVMGRnu1r5SnDHJMQcHB1vbMSvMxgA8qwpMpsRJeSk2KaTZgJRTKwgDrLNaCQFVK1WisAZLVQ5oXZT6dqLDHDryZAkgwgZqf6S8x',
              value: { assets: {}, coins: 2n }
            }
          ],
          update: null,
          validityInterval: { invalidBefore: 30_892, invalidHereafter: null },
          withdrawals: { stake1uyxefct5wvh0n2h88uu44dz9q7l6nq7k2q3uzx54ruxr9eq8cjal2: 157n }
        },
        id: 'f138917a172058f68c93de999592c5fb7cafc9265add9723eb2e8b9c12654654',
        metadata: null,
        raw: 'g6cAgYJYIAJovp29BEbqohfh3sjzmSSTBeVR1/wUN92EUh90qmIcAAGBglhXgtgYWE2DWBxGUQ+/G19B/lOoSXpmwK8MYRGJS6lnhClyVAfbogFYIlggeHZ2dnhud3d4dHdrcGxzemFnYnZhbWp5dmRpY2hwdXgCRRrLg+d6ABqgcWz5AgIYfQSCggCCAFgcta5mOq6o5QAVe99Lqv1vW6DOV1n3zUEB/BMvVIQFWBwNlOF0cy75quc/OVq0RQe/qYPWUCPBGpUfDDLkWBymRkdLj1QxJhUGtsJz0wfHVppOtslrQt1KKVIKWCADFwoudZe3t+PYTAU5HROaYrFX54eG2MCC8p3PTBETFAWhWB3hDZThdHMu+arnPzlatEUHv6mD1lAjwRqVHwwy5BidCBl4rAmhWBymRkdLj1QxJhUGtsJz0wfHVppOtslrQt1KKVIKoUAgogGBggKDggUZOHCCBRoAAV2pgwMAgAKDhFggNdJZ7TrTK9pHsL8qTwSUQPfCmOHGkZUYtVzHXiawZxZYQHFpeW93amxodWRvZ2hjbWJwc3piYmhhaWFmdHZxYmxrenpramVhYnJlenllY3JudnRsaXh3a213b2F0cGtkcmJCV9dE/0dj0YRYILofhoA3rTUZT3Gf6WSvFFCcv59hGhVanRpSre2atK4CWEApDhGuXal8MytAql+eZJpC5l+mBtIXNaWERkQ9iBYcPi810DAqMOHwRV69PbzuEhMIme/qXJ23s9ahf0k9MwTWQEMYmh6EWCADXQxlKPxc+EJhXFsy+gMbSjmZ6cm8bEQ1vs5b08/95VhAYWlubnB1eWFqbGtkdHp3ZW1heHd6aWRybWZscGxxeXp4ZGt1ZXlxanNtcXB3a3dkb3pwY3JnZXBpdXd0bmh4Z0Izb0H7gqIAGxVoXr1IsurhAoVCCgNCLGhgQBv0tvwFaCFI0YGCBBkbAA==',
        witness: {
          bootstrap: [
            {
              addressAttributes: '/0dj0Q==',
              chainCode: '57d7',
              key: '35d259ed3ad32bda47b0bf2a4f049440f7c298e1c6919518b55cc75e26b06716',
              signature: 'cWl5b3dqbGh1ZG9naGNtYnBzemJiaGFpYWZ0dnFibGt6emtqZWFicmV6eWVjcm52dGxpeHdrbXdvYXRwa2RyYg=='
            },
            {
              addressAttributes: 'GJoe',
              chainCode: null,
              key: 'ba1f868037ad35194f719fe964af14509cbf9f611a155a9d1a52aded9ab4ae02',
              signature: 'KQ4Rrl2pfDMrQKpfnmSaQuZfpgbSFzWlhEZEPYgWHD4vNdAwKjDh8EVevT287hITCJnv6lydt7PWoX9JPTME1g=='
            },
            {
              addressAttributes: '+w==',
              chainCode: '336f',
              key: '035d0c6528fc5cf842615c5b32fa031b4a3999e9c9bc6c4435bece5bd3cffde5',
              signature: 'YWlubnB1eWFqbGtkdHp3ZW1heHd6aWRybWZscGxxeXp4ZGt1ZXlxanNtcXB3a3dkb3pwY3JnZXBpdXd0bmh4Zw=='
            }
          ],
          scripts: {
            a5de7cbbbfdda912df57b236dde5d44c12dbd50bd1f2a7da565d700b: {
              native: { any: [{ expiresAt: 14_448 }, { expiresAt: 89_513 }, { '0': [] }] }
            }
          },
          signatures: {}
        }
      },
      {
        body: {
          certificates: [
            {
              poolRegistration: {
                cost: 810n,
                id: 'pool15erywju02scjv9gxkmp885c8catf5n4ke9459h2299fq57u9c3e',
                margin: '0/1',
                metadata: null,
                owners: ['3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e'],
                pledge: 525n,
                relays: [],
                rewardAccount: 'stake_test1uz66ue36465w2qq40005h2hadad6pnjht8mu6sgplsfj74q9f9d7l',
                vrf: 'bb30a42c1e62f0afda5f0a4e8a562f7a13a24cea00ee81917b86b89e801314aa'
              }
            }
          ],
          fee: 720n,
          inputs: [
            { index: 0, txId: '0268be9dbd0446eaa217e1dec8f399249305e551d7fc1437dd84521f74aa621c' },
            { index: 0, txId: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25' }
          ],
          mint: { assets: { '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4': 1n }, coins: 0n },
          outputs: [
            {
              address: 'addr_test1grs2w9p3nqfv8amnhgzwchtt8l7dt2kc2qrgqkcy0vyz2sgqqqqs2wje25',
              value: { assets: { '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4': 2n }, coins: 2n }
            },
            {
              address: 'addr1g8s2w9p3nqfv8amnhgzwchtt8l7dt2kc2qrgqkcy0vyz2sgqqqqqx8489p',
              value: { assets: { e0a714319812c3f773ba04ec5d6b3ffcd5aad85006805b047b082541: 2n }, coins: 1n }
            }
          ],
          update: { epoch: 91_022, proposal: {} },
          validityInterval: { invalidBefore: null, invalidHereafter: 83_856 },
          withdrawals: {
            stake_test17z66ue36465w2qq40005h2hadad6pnjht8mu6sgplsfj74qvpedfl: 608n,
            stake17x66ue36465w2qq40005h2hadad6pnjht8mu6sgplsfj74qttn0dz: 324n
          }
        },
        id: '77c4a3c21573c57f0599499bc780de457c35c1d95bfb7e2370d3328b49327117',
        metadata: {
          body: { blob: { '1': { int: -16_613_019_303_347_710_699n }, '2': { bytes: '6573' } }, scripts: [] },
          hash: 'ae85d245a3d00bfde01f59f3c4fe0b4bfae1cb37e9cf91929eadcea4985711de'
        },
        raw: 'g6kAgoJYIAJovp29BEbqohfh3sjzmSSTBeVR1/wUN92EUh90qmIcAIJYIO4VWs6cQCkgdMtq/4yczdJzyBZI/xFJ7za86m67ij4lAAGCglggQOCnFDGYEsP3c7oE7F1rP/zVqthQBoBbBHsIJUEAAAGCAqFYHA2U4XRzLvmq5z85WrRFB7+pg9ZQI8EalR8MMuShQAKCWCBB4KcUMZgSw/dzugTsXWs//NWq2FAGgFsEewglQQAAAIIBoVgc4KcUMZgSw/dzugTsXWs//NWq2FAGgFsEewglQaFAAgIZAtADGgABR5AEgYoDWBymRkdLj1QxJhUGtsJz0wfHVppOtslrQt1KKVIKWCC7MKQsHmLwr9pfCk6KVi96E6JM6gDugZF7hriegBMUqhkCDRkDKtgeggABWB3gta5mOq6o5QAVe99Lqv1vW6DOV1n3zUEB/BMvVIFYHDVCrLOmTYDCkwImDWLDuHp0KtFKv4VevGczCB6A9gWiWB3wta5mOq6o5QAVe99Lqv1vW6DOV1n3zUEB/BMvVBkCYFgd8bWuZjquqOUAFXvfS6r9b1ugzldZ981BAfwTL1QZAUQGgqAaAAFjjgdYIK6F0kWj0Av94B9Z88T+C0v64cs36c+Rkp6tzqSYVxHeCaFYHA2U4XRzLvmq5z85WrRFB7+pg9ZQI8EalR8MMuShQAGiAIOCWCCwBfDgl2DCNxt8yNaotn3Qugn3Hy/r3JzXlCUfGFZzKVhAVjYvpOSGRTBrgKkud+Op2bFZa/KdFFa9sWaFJUjBbM1o3PB7a+CGEYNhzUSLaFtjpPFK78t0eIAGXt27bVOTx4JYIJe6hbW+rdA8irfqJgpT9zzUe4fZwu9iuY+b0jk0v/hSWECENEZfj4FjBvN3KMJO+zSVZHDFpCNQMjgGh1Kq0sK+xZDB1qBKdOHxuS3N+IfIrfDraM+8a5heBsK4wTgz3wRTglggGc/QF0GZKFivqhqLmfJiJzi0wDpouSgwJ2QLlDGBxLZYQJZi+foJl1bYw4dGPnS4Y71JeuIlU3UbcNIEje1+3SUHEfO08numSgjQNpNLrJVay6KpmonDHQEDroWkjZXFszcBg4IAWBxKzydzkXx7VHxXan/xENK6VzPB8cqc3GWa6jpWggGDggBYHL0Dn5VvSzAvOrb8fEusM1ClQPRK+BqEkhlN0sKCAoWCBRk3QYIAWByxa1b17AZL5qw8q2A1766Gs2bMPcSg1XFgPXDlggBYHKZGR0uPVDEmFQa2wnPTB8dWmk62yWtC3UopUgqCAFgcWOG2VxhTG0JJRhDFBs7xD/Ax+oF6j/dcCrGA54IEGgABE2eDAwCCggGEggBYHKZGR0uPVDEmFQa2wnPTB8dWmk62yWtC3UopUgqCAFgcduYH2yoxyaLDJ2HSQxoYalUMwyH3nNjWqCspuIIAWBzgpxQxmBLD93O6BOxdaz/81arYUAaAWwR7CCVBggBYHLWuZjquqOUAFXvfS6r9b1ugzldZ981BAfwTL1SDAwKFggBYHOCnFDGYEsP3c7oE7F1rP/zVqthQBoBbBHsIJUGCAFgc4KcUMZgSw/dzugTsXWs//NWq2FAGgFsEewglQYIAWBwNlOF0cy75quc/OVq0RQe/qYPWUCPBGpUfDDLkggBYHDVCrLOmTYDCkwImDWLDuHp0KtFKv4VevGczCB6CAFgcZfxwml4Bm4q6dvaXfByHcOSzb6dvQ078WIdHt4IAWBwNlOF0cy75quc/OVq0RQe/qYPWUCPBGpUfDDLkgqIBO+aNTQluv2rqAkJlc4A=',
        witness: {
          bootstrap: [],
          scripts: {
            '4afe6bb5d653d742fd39a93285f6817312662ea627143639bd548ee5': {
              native: '4acf2773917c7b547c576a7ff110d2ba5733c1f1ca9cdc659aea3a56'
            },
            '8dd8c0b8c1e0c91de6f0bba3e2058235bbd3cf826e8a5b4e146207b8': {
              native: {
                all: [
                  'bd039f956f4b302f3ab6fc7c4bac3350a540f44af81a8492194dd2c2',
                  {
                    any: [
                      { expiresAt: 14_145 },
                      'b16b56f5ec064be6ac3cab6035efae86b366cc3dc4a0d571603d70e5',
                      'a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a',
                      '58e1b65718531b42494610c506cef10ff031fa817a8ff75c0ab180e7',
                      { startsAt: 70_503 }
                    ]
                  },
                  {
                    '0': [
                      {
                        all: [
                          'a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a',
                          '76e607db2a31c9a2c32761d2431a186a550cc321f79cd8d6a82b29b8',
                          'e0a714319812c3f773ba04ec5d6b3ffcd5aad85006805b047b082541',
                          'b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'
                        ]
                      },
                      {
                        '2': [
                          'e0a714319812c3f773ba04ec5d6b3ffcd5aad85006805b047b082541',
                          'e0a714319812c3f773ba04ec5d6b3ffcd5aad85006805b047b082541',
                          '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4',
                          '3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e',
                          '65fc709a5e019b8aba76f6977c1c8770e4b36fa76f434efc588747b7'
                        ]
                      }
                    ]
                  }
                ]
              }
            },
            d9e0c75fb59dba0a82897cf42bb81ad4dba7ca78159b7b1b9f5ee56e: {
              native: '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4'
            }
          },
          signatures: {
            '19cfd01741992858afaa1a8b99f2622738b4c03a68b9283027640b943181c4b6':
              'lmL5+gmXVtjDh0Y+dLhjvUl64iVTdRtw0gSN7X7dJQcR87Tye6ZKCNA2k0uslVrLoqmaicMdAQOuhaSNlcWzNw==',
            '97ba85b5beadd03c8ab7ea260a53f73cd47b87d9c2ef62b98f9bd23934bff852':
              'hDRGX4+BYwbzdyjCTvs0lWRwxaQjUDI4BodSqtLCvsWQwdagSnTh8bktzfiHyK3w62jPvGuYXgbCuME4M98EUw==',
            b005f0e09760c2371b7cc8d6a8b67dd0ba09f71f2febdc9cd794251f18567329:
              'VjYvpOSGRTBrgKkud+Op2bFZa/KdFFa9sWaFJUjBbM1o3PB7a+CGEYNhzUSLaFtjpPFK78t0eIAGXt27bVOTxw=='
          }
        }
      }
    ],
    header: {
      blockHash: 'bb30a42c1e62f0afda5f0a4e8a562f7a13a24cea00ee81917b86b89e801314aa',
      blockHeight: 20,
      blockSize: 243,
      issuerVk: '60337a64656bf2646f66c90ab4a546bbf3c3f5f8f00bf06fcc1d9f7d01d924f6',
      issuerVrf: 'nIRtRLQUxE0H2Z5U0DvE94YKiT3ISOUzW8oBPl8h2lA=',
      leaderValue: {
        output: 'MG69pkhk7nsRHRKPRAcTmCe/uglD8lVMmktQXnb1NdbYZEB8SA2YU0GXNq97li+s8VciXD4oiNbaeTJ/C/9D+w==',
        proof:
          'vazur4eDSrWa1Ej0D4oJkYD+p/5lnB6KV2814zX2U70tlnMG21reO8TjRutmz48lxGEA+UVCgLdgjmgkZW9OEdQeNDel0a90UDHi3xfO4gI='
      },
      nonce: {
        output: '7iNfV5Ud/689t4ZH7sq1+ZG2cFCgvQjGk09PW0znFROzt3VB/QcTsTB1+6ZnnxYMhsQ2A0JHnF2y+5aXf6Glag==',
        proof:
          'QoU+Mgu8U0syFzaFyIFD7+AE0+AIgodtJzNOuhdHluPD7P0yV6Ss76S7rol8hIX7/BOZERZZBp3M6CFy2vat0yYVEKpy1SR3fCHdGriV3Q8='
      },
      opCert: {
        count: 1,
        hotVk: 'lE8fWiClGVIGkGvy6IqxUhnqFPc5Jkhsr+GNNaJhe7k=',
        kesPeriod: 1,
        sigma: 'emQIwhlN83mtldrYI2orhkk6CSzO79ohGMIoZldBOSv2WZ7suQ1yeymQXvkbdjsmQptX/S2gSNXNoLt6AFgcCQ=='
      },
      prevHash: 'ae85d245a3d00bfde01f59f3c4fe0b4bfae1cb37e9cf91929eadcea4985711de',
      protocolVersion: { major: 0, minor: 0 },
      signature:
        'OvOjILwJ2nrmtwXLyWBt/R/k0T8u3WZW59wHKvdegnC0f3jU9wWTMrDs5vrupA0osJkYi3yXc3c98WjdCdslACttNEdQBsnS70eV3uHWsdgoIba+pSgQKNap98X1C/hrVqOFS/9VxXkvZFQy00cHiXCApbjkrz81hmb/jQpUXsAY6vOj+MafwkWoePsuHoez6WvFdLgPH+81f6Oynj7RMI652xDCaFUjrHAlgiLBz3HlG+blms2pGrR+tPKvlnmMpPehzkJTh/NKgCZKARIRLfzxo48pBKS7K/RnXOiwPV7ROoJC0aF5ojWST3dxMP4AoTuJqT85HAl/wnce0jg9Z2Ab5ZpIaJ4hq+SWN8IxFvwVg2C3ADN60fQ+3fR5S84H6rrfTQkjJ5tr7kGCBgJX5sgVGCqjgqTbmGNCp8PiPA+tWXt/JRgSMiw/RFzVq0bei8jGz13MT2fM3S5Vz4DfglDEATOYtm2bB66+ny3Xi2JqfDvLiIeNMHl7KGhkTJvoGXpzdQB19BzBshvG2g+e0T9Wf+QIrZ11ScfaVoi7vQ/KjljBxZhgrWJwxH/HWYri2JK2wF2y7T7jTlMER8pnGQ==',
      slot: 3
    },
    headerHash: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25'
  }
};

export const mockBabbageBlock: Ogmios.Schema.Babbage = {
  babbage: {
    body: [
      {
        body: {
          certificates: [
            { moveInstantaneousRewards: { pot: 'reserves', value: 712n } },
            {
              poolRegistration: {
                cost: 290n,
                id: 'pool1kkhxvw4w4rjsq9tmma964lt0twsvu46e7lx5zq0uzvh4ge9n0hc',
                margin: '1/2',
                metadata: {
                  hash: '2738e2233800ab7f82bd2212a9a55f52d4851f9147f161684c63e6655bedb562',
                  url: 'https://public.bladepool.com/metadata.json'
                },
                owners: [],
                pledge: 229n,
                relays: [
                  { ipv4: '192.0.2.1', ipv6: '2001:db8::1', port: null },
                  { hostname: 'foo.example.com', port: null }
                ],
                rewardAccount: 'stake_test1urs2w9p3nqfv8amnhgzwchtt8l7dt2kc2qrgqkcy0vyz2sgcp89zz',
                vrf: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25'
              }
            }
          ],
          collateralReturn: null,
          collaterals: [{ index: 2, txId: '0268be9dbd0446eaa217e1dec8f399249305e551d7fc1437dd84521f74aa621c' }],
          fee: 58n,
          inputs: [],
          mint: {
            assets: {
              '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4': -1n,
              '1d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4': 2n
            },
            coins: 0n
          },
          network: 'mainnet',
          outputs: [
            {
              address: 'addr1vxnyv36t3a2rzfs4q6mvyu7nqlr4dxjwkmykkskafg54yzsv3uzfs',
              datum: null,
              datumHash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
              script: { 'plutus:v2': '46010000220011' },
              value: { assets: {}, coins: 2n }
            },
            {
              address: 'addr1vxnyv36t3a2rzfs4q6mvyu7nqlr4dxjwkmykkskafg54yzsv3uzfs',
              datum: '187b',
              datumHash: null,
              script: { 'plutus:v2': '46010000220011' },
              value: { assets: {}, coins: 3n }
            }
          ],
          references: [{ index: 1, txId: '03170a2e7597b7b7e3d84c05391d139a62b157e78786d8c082f29dcf4c111314' }],
          requiredExtraSignatures: [
            '0d94e174732ef9aae73f395ab44507bfa983d65023c11a951f0c32e4',
            'a646474b8f5431261506b6c273d307c7569a4eb6c96b42dd4a29520a'
          ],
          scriptIntegrityHash: null,
          totalCollateral: null,
          update: { epoch: 51_884, proposal: {} },
          validityInterval: { invalidBefore: 78_202, invalidHereafter: null },
          withdrawals: { stake1uxnyv36t3a2rzfs4q6mvyu7nqlr4dxjwkmykkskafg54yzssmuy4z: 724n }
        },
        id: 'c32a4a4f5a4b540d4f79730ca0c658d9a8400be2173e0ba1dc8471004c1cb0db',
        inputSource: Cardano.InputSource.collaterals,
        metadata: {
          body: { blob: { '2': { string: '\u0013' } }, scripts: [{ native: { startsAt: 63_725 } }] },
          hash: 'bb30a42c1e62f0afda5f0a4e8a562f7a13a24cea00ee81917b86b89e801314aa'
        },
        raw: 'hK0AgA2BglggAmi+nb0ERuqiF+HeyPOZJJMF5VHX/BQ33YRSH3SqYhwCEoGCWCADFwoudZe3t+PYTAU5HROaYrFX54eG2MCC8p3PTBETFAEBgaMAWB1hpkZHS49UMSYVBrbCc9MHx1aaTrbJa0LdSilSCgECA9gYSoICR0YBAAAiABECGDoEgoIGggAZAsiKA1gcta5mOq6o5QAVe99Lqv1vW6DOV1n3zUEB/BMvVFgg7hVazpxAKSB0y2r/jJzN0nPIFkj/EUnvNrzqbruKPiUY5RkBItgeggECWB3g4KcUMZgSw/dzugTsXWs//NWq2FAGgFsEewglQYCChAD2RMAAAgFQuA0BIAAAAAAAAAAAAQAAAIMB9m9mb28uZXhhbXBsZS5jb22CZHRleHRKYnl0ZXN0cmluZwWhWB3hpkZHS49UMSYVBrbCc9MHx1aaTrbJa0LdSilSChkC1AaCoBnKrAgaAAExeg6CWBwNlOF0cy75quc/OVq0RQe/qYPWUCPBGpUfDDLkWBymRkdLj1QxJhUGtsJz0wfHVppOtslrQt1KKVIKCaFYHOCnFDGYEsP3c7oE7F1rP/zVqthQBoBbBHsIJUGiQQAgQQECB1gguzCkLB5i8K/aXwpOilYvehOiTOoA7oGRe4a4noATFKoPAaQAgoJYIGebir0TeXKUddocUw3ajcG/kXfs6uRJoKFeTxb0U5m+WECj4qLER4r+fNc0+lk84z8GhBJVZW3DHTrP9IiEzpR41WMU3Wuoco3kF0E6eYq26H9oX7kX+DALOXco8IYxwW45glggI4KH8+qadGUTrL7irrHpgNn+6tKb+BV7d1ZDf/vo7ltYQB5jl3NCXAz6Y3bXMmUA78V02bh6+6Ipak4SFXrYMXbOcwBgCpIb7WCHYAs6EY6pBXRqYs/pBknqKqAPRhQqrXsCgoRYIN5G+59S2KIp487cYAAlZKPSMwnb8h36q9OEhcRThBmyWEA/bQiht6t4GKeL6NSOqCiw6ZdiWKTKOBV/Yo/k3h8yak70A8QNA0iGTedyWb6aXGBq8gsp6+f2rrWUrEAXdyiqQU1AhFgg/Bop7T8KTBpANimIMc4ReiO2txSruoPQoJPQg54ZPDlYQD8ZhN7Vs1GYvPzqpNX0SybLjmqlnN505Xiwb5NRvbF1YxYjdPGZmAQj5S3ebIt+Qr9MoSDdv1VyQbmlm3MICf5BIEGZA4FHRgEAACIAEQWBhAAAo0FgAp8go0GcIEOGpIJE4hvZNiAgBKD/o6RDWu2QBAJCsHohBSNAn0FNQps/BED/oJ8DQAH/oiIjQEG02GaCGNqfI0FEAwJBPv9CBOGh2GaCGQGTnyP/oIIbU6MuMeloUY0bQeo2j4HZDq302QEDogChAmETAYGCBBn47Q==',
        witness: {
          bootstrap: [
            {
              addressAttributes: null,
              chainCode: '4d',
              key: 'de46fb9f52d8a229e3cedc60002564a3d23309dbf21dfaabd38485c4538419b2',
              signature: 'P20IobereBini+jUjqgosOmXYlikyjgVf2KP5N4fMmpO9APEDQNIhk3nclm+mlxgavILKevn9q61lKxAF3coqg=='
            },
            {
              addressAttributes: 'mQ==',
              chainCode: '20',
              key: 'fc1a29ed3f0a4c1a4036298831ce117a23b6b714abba83d0a093d0839e193c39',
              signature: 'PxmE3tWzUZi8/Oqk1fRLJsuOaqWc3nTleLBvk1G9sXVjFiN08ZmYBCPlLd5si35Cv0yhIN2/VXJBuaWbcwgJ/g=='
            }
          ],
          datums: {},
          redeemers: {
            'spend:0': {
              // eslint-disable-next-line @typescript-eslint/no-loss-of-precision
              executionUnits: { memory: 6_026_711_518_256_058_765, steps: 4_749_668_747_002_318_509 },
              redeemer:
                'a34160029f20a3419c204386a48244e21bd936202004a0ffa3a4435aed90040242b07a210523409f414d429b3f0440ffa09f034001ffa222234041b4d8668218da9f2341440302413eff4204e1a1d866821901939f23ffa0'
            }
          },
          scripts: {
            c370d10724c6b5a2448af41238e024ad470c0139da7f4b8527a47d74: { 'plutus:v1': '46010000220011' }
          },
          signatures: {
            '679b8abd1379729475da1c530dda8dc1bf9177eceae449a0a15e4f16f45399be':
              'o+KixEeK/nzXNPpZPOM/BoQSVWVtwx06z/SIhM6UeNVjFN1rqHKN5BdBOnmKtuh/aF+5F/gwCzl3KPCGMcFuOQ==',
            '238287f3ea9a746513acbee2aeb1e980d9feead29bf8157b7756437ffbe8ee5b':
              'HmOXc0JcDPpjdtcyZQDvxXTZuHr7oilqThIVetgxds5zAGAKkhvtYIdgCzoRjqkFdGpiz+kGSeoqoA9GFCqtew=='
          }
        }
      }
    ],
    header: {
      blockHash: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25',
      blockHeight: 4,
      blockSize: 2,
      issuerVk: 'f6cc957f17046ce6de24c81d08e9381608ed1acc083284916252f76f65643eae',
      issuerVrf: '201dQhvqwG+GvMtkb82ZCuFP6tdT9q7raxceTE4ZGgI=',
      opCert: {
        count: 2,
        hotVk: 'vcLibo61JkBlWdVGpIrF+Yp1t5z8+tS+iivBMgSt5jc=',
        kesPeriod: 2,
        sigma: 'xoYNFRrDJscAfzn8fQee5chdcKOTNuWyxB2YpYcR5RVJa2WqlRDz45dl52pxhF5EhZVU8d+8bOX8tsE9GHYNzw=='
      },
      prevHash: 'genesis',
      protocolVersion: { major: 589, minor: 287 },
      signature:
        'o/4wLT96VPSLAtgCnKwTVtzj/Y60RVI+UyiB0YlDgR9FEubrCBs5Vr5V1fHQjqLQxa3wOSZut68V/hOPkjkGBkzbFMFzyaA6/603+koIYbf1rU9oYIYDMjk4QlGlqAI8GuYHTy4K7XSIJ5FyJAXBNNvLhbHBky/v3RBNPSupMfGJjEgW0VYpBvbDlV7V+UidY+bhLInuHFflQYlMWCD8xsYihqnZ1fCyMmQQ2hxQ6HusMCMnkGps3kG8hlrd8/4SqoD8B8y/TsHBy0/4rZGaVq+xLvo+kmEcLDAPhenkCZBAx8OJIth9ZFsvL0Az8HOBzwPLrhMOHuzoFZkgEZnY1jt3tu26XE9bNfyRWxqUUlB8/595HjBH9LLoEHrVqQsjjR2qJZEXLRkRslnQjdArMAM2NmyJWFQlkIbP2tjC9XYxRHQguDIcTZWETHki6WlqtqveKhCExbVBt43Yr8RlI6p2r4fwgI57tASpY8PU+KQI/p96i29tH0WhrK2tpqkpNm1YlnJPkYZhlVAEMaafmEp8BkTZ29/AVAnSrHgMGYp+2kLbFfUTuvFQVAAydem0bgLIjD4mm+fomvDIO8b8Rw==',
      slot: 6,
      vrfInput: {
        output: 'Pooas3OURUCUH+bHH0RGWFDdrkiJO4oXp5i47rOq6r1ONAE/ZQCj+YRkip+WYUqz9XCJpaT2zRPP+rBFq6Ohzw==',
        proof:
          '7YBbi3PmQzRxAJR0Rb0a6wozKDOHYPqANMpkOee5M8AAdtf00kPw/BhyvVIZCZt7/yRto5YqH8JJG2XakEkDS47GNQ7VfbDubXiSx7XTyAA='
      }
    },
    headerHash: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25'
  }
};

export const mockBabbageBlockWithNftMetadata = fromSerializableObject<Ogmios.Schema.Babbage>({
  babbage: {
    body: [
      {
        body: {
          certificates: [],
          collateralReturn: null,
          collaterals: [],
          fee: {
            __type: 'bigint',
            value: '192517'
          },
          inputs: [
            {
              index: 1,
              txId: '04e4c197613f7b752f17cc69429faa5d7ceffb3e9299a7a4891af2b85b7f87c4'
            }
          ],
          mint: {
            assets: {
              'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a.626f62': {
                __type: 'bigint',
                value: '1'
              }
            },
            coins: {
              __type: 'bigint',
              value: '0'
            }
          },
          network: null,
          outputs: [
            {
              address:
                'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g',
              datum: null,
              datumHash: null,
              script: null,
              value: {
                assets: {
                  'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a.626f62': {
                    __type: 'bigint',
                    value: '1'
                  }
                },
                coins: {
                  __type: 'bigint',
                  value: '1444443'
                }
              }
            },
            {
              address:
                'addr_test1qz690wvatwqgzt5u85hfzjxa8qqzthqwtp7xq8t3wh6ttc98hqtvlesvrpvln3srklcvhu2r9z22fdhaxvh2m2pg3nuq0n8gf2',
              datum: null,
              datumHash: null,
              script: null,
              value: {
                assets: {},
                coins: {
                  __type: 'bigint',
                  value: '9966064110'
                }
              }
            }
          ],
          references: [],
          requiredExtraSignatures: [],
          scriptIntegrityHash: null,
          totalCollateral: null,
          update: null,
          validityInterval: {
            invalidBefore: 0,
            invalidHereafter: 13_645_686
          },
          withdrawals: {}
        },
        id: '297f52b3e58e5c007f0d6914e1af64b4fc2c3266d444896520d998005d26642b',
        inputSource: 'inputs',
        metadata: {
          body: {
            blob: {
              '721': {
                map: [
                  {
                    k: {
                      string: 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a'
                    },
                    v: {
                      map: [
                        {
                          k: {
                            string: 'bob'
                          },
                          v: {
                            map: [
                              {
                                k: {
                                  string: 'name'
                                },
                                v: {
                                  string: '$bob'
                                }
                              },
                              {
                                k: {
                                  string: 'description'
                                },
                                v: {
                                  string: 'The Handle Standard'
                                }
                              },
                              {
                                k: {
                                  string: 'website'
                                },
                                v: {
                                  string: 'https://adahandle.com'
                                }
                              },
                              {
                                k: {
                                  string: 'image'
                                },
                                v: {
                                  string: 'ipfs://QmZqUk6nGqYJZzHiCGzbzqppA5qE99yNkuTSHuRQpymE1X'
                                }
                              },
                              {
                                k: {
                                  string: 'core'
                                },
                                v: {
                                  map: [
                                    {
                                      k: {
                                        string: 'og'
                                      },
                                      v: {
                                        int: {
                                          __type: 'bigint',
                                          value: '0'
                                        }
                                      }
                                    },
                                    {
                                      k: {
                                        string: 'termsofuse'
                                      },
                                      v: {
                                        string: 'https://adahandle.com/tou'
                                      }
                                    },
                                    {
                                      k: {
                                        string: 'handleEncoding'
                                      },
                                      v: {
                                        string: 'utf-8'
                                      }
                                    },
                                    {
                                      k: {
                                        string: 'prefix'
                                      },
                                      v: {
                                        string: '$'
                                      }
                                    },
                                    {
                                      k: {
                                        string: 'version'
                                      },
                                      v: {
                                        int: {
                                          __type: 'bigint',
                                          value: '0'
                                        }
                                      }
                                    }
                                  ]
                                }
                              },
                              {
                                k: {
                                  string: 'augmentations'
                                },
                                v: {
                                  list: []
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            },
            scripts: []
          },
          hash: '9002261a963cd2e49faf5574eb98a5e550bbf1d4d0c334cac7ff611e2588e845'
        },
        raw: 'hKcAgYJYIATkwZdhP3t1LxfMaUKfql187/s+kpmnpIka8rhbf4fEAQGCglg5AIf5b9OFu2kRpvjrR9lwk84uO12y2ITbeyOLDOx2HkQyAiRq92Q/PsqkwSK1jd6UiS5ryuDgxFJ4ghoAFgpboVgc8P9Iu7e76dWaQPHOkOnp0P9QAuxI8jK0nKD7mqFDYm9iAYJYOQC0V7mdW4CBLpw9LpFI3TgAJdwOWHxgHXF19LXgp7gWz+YMGFn5xgO38MvxQyiUpLb9My6tqCiM+BsAAAACUgYR7gIaAALwBQMaANA3dgdYIJACJhqWPNLkn69VdOuYpeVQu/HU0MM0ysf/YR4liOhFCAAJoVgc8P9Iu7e76dWaQPHOkOnp0P9QAuxI8jK0nKD7mqFDYm9iAaIAgoJYIIy0bDzYO62aXVw2gVLaaexjDFwM2uK8y8kzY18QqVl4WEATDhzbBQbz4dbh6F0iq9Ul3OUSgCjRwwbfss7slNsW71UNwfm+YZGNXUAYLOe5pfqnpoNCX5Ahjjgg6PXUdmEMglggtipxk5J/R+9wO6maBq3R7i1NlIU6FtzWitD12bqhhTBYQFmEL+nW3a60/URPmB2NTAG4ADoekkctLLzLynsk7BmrfDbjLsHQN27WpJlmfHsEuhOpKAWuzYT7wEgSsSznxwIBgYIAWBxNqWWgSd/RXtHuGfum4pdKC3n8QW3ReWofl/Xh9aEZAtGheDhmMGZmNDhiYmI3YmJlOWQ1OWE0MGYxY2U5MGU5ZTlkMGZmNTAwMmVjNDhmMjMyYjQ5Y2EwZmI5YaFjYm9ipmRuYW1lZCRib2JrZGVzY3JpcHRpb25zVGhlIEhhbmRsZSBTdGFuZGFyZGd3ZWJzaXRldWh0dHBzOi8vYWRhaGFuZGxlLmNvbWVpbWFnZXg1aXBmczovL1FtWnFVazZuR3FZSlp6SGlDR3pienFwcEE1cUU5OXlOa3VUU0h1UlFweW1FMVhkY29yZaVib2cAanRlcm1zb2Z1c2V4GWh0dHBzOi8vYWRhaGFuZGxlLmNvbS90b3VuaGFuZGxlRW5jb2RpbmdldXRmLThmcHJlZml4YSRndmVyc2lvbgBtYXVnbWVudGF0aW9uc4A=',
        witness: {
          bootstrap: [],
          datums: {},
          redeemers: {},
          scripts: {
            f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a: {
              native: '4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1'
            }
          },
          signatures: {
            '8cb46c3cd83bad9a5d5c368152da69ec630c5c0cdae2bccbc933635f10a95978':
              'Ew4c2wUG8+HW4ehdIqvVJdzlEoAo0cMG37LO7JTbFu9VDcH5vmGRjV1AGCznuaX6p6aDQl+QIY44IOj11HZhDA==',
            b62a7193927f47ef703ba99a06add1ee2d4d94853a16dcd68ad0f5d9baa18530:
              'WYQv6dbdrrT9RE+YHY1MAbgAOh6SRy0svMvKeyTsGat8NuMuwdA3btakmWZ8ewS6E6koBa7NhPvASBKxLOfHAg=='
          }
        }
      }
    ],
    header: {
      blockHash: '4961c3d67b35795b2edd6884482c80c3aa9cec6beb2ee7f6e9ddb7f364ee3eec',
      blockHeight: 317_874,
      blockSize: 848,
      issuerVk: '9691ed9d98a5b79d5bc46c4496a6dba7e103f668f525c8349b6b92676cb3eae4',
      issuerVrf: '6knkZSxGC57m2q/vyZnKZn++XrXXp66rvf9v4ZwaPJ8=',
      opCert: {
        count: 1,
        hotVk: 'yGgscY6GcPnt0pXYsNtQ4uMr8lOXcm7vViJ9uviaJUo=',
        kesPeriod: 60,
        sigma: '0IAM1hEMC65KaCqHSy3llsIz6o54iXkYFX6lxHwf5o6w3AXdIftRGV2TY+Azpq9jNG2UMDvrjLv0FdT1cfJ0AQ=='
      },
      prevHash: '6625b89401da3c51749f89268b65fda8e416ad5c8af2d81b61f1eac0cf7eb8e5',
      protocolVersion: {
        major: 7,
        minor: 0
      },
      signature:
        'p5RAIKCwUymYUyL+c1cntIkYYUeJFNzoZ270Ueuhv0KgjEuY3RSBlLVR1MchrtQohfvJD3WJBpN/pOkEmuf6DVGodIUrdR/NFU4SyWjRan6oPYvrH31B/xh+L8ekhh0HmUX6B+VFQqW3wfDeXV3gbbLWSSxTxGVfUiRBKpcFZoH0pPdB0WCjdvR6TwkrZ3rmZCqcWCg+xhkTcbFgKwSTWzv5ead9Rh3S2JFDsSPML3cbuv2537fDSSMVlN1gg/m4TRR3deKThxAnCKHOyP57vFGjlakXRmr2EIv2WKiZoHUp3EO2B2Fh+/RFN5EosDndAEx4q5iqVFyOCHx6zIe41efjE2x3WfXz6HruoSzwlidI7lCbEdoYd4Fz6UypM+IkQPNuYj3cOPtDET0ae8OR+cVt7+YI4LgbmVyxCYvj9jxZhxygsK33AY7zgtKJMp7NkVQw108Pc6nwVtKy9Lq7VCiEql1Pv1MITmKZrgmpGlnl6V5IjF0rDJz0pdRBoP06DWi1zaXI9uKNWx3ZdDQRrIPc/swqYXFPO4kTQ1bECg3ijLvxyobZSqI4WuFdLE2IK9JJBXW4jJhO6CAnkjRQ+Q==',
      slot: 13_633_715,
      vrfInput: {
        output: 'Yjlif/oWejOTiaoIK+xO9M5vL7Dr88m+XkrRASO9Kh75G+df45w9UKW7OwxxwnCurOU5YQRwam66XV5NU/zf7Q==',
        proof:
          'DjqlnCcUCKh8XHudn4mtl2NKGusLd3gydKXhfLEHaonCbI7j94bq9n4C6MqltyHk8v/tmfE5x5zEwoUIUv9okr0AMs6UEQjcaFxV7HPlDgE='
      }
    },
    headerHash: 'f0206b115735fd587bd64e11936ba695033ce235284cfc83afc7168e5f0b86d9'
  }
});
