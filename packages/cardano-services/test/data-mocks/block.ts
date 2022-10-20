export const block = {
  confirmations: 1_957_883,
  date: new Date(),
  epoch: 74,
  epochSlot: 27_480,
  fees: 0n,
  header: {
    blockNo: 1_598_507,
    hash: '7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298',
    slot: 1_625_880
  },
  nextBlock: '1c8e307530d92f359a839184528accaa6ee34e99d7ea212a9fe94bdb80da2fdd',
  previousBlock: '1c8e307530d92f359a839184528accaa6ee34e99d7ea212a9fe94bdb80da2fdd',
  size: 989,
  slotLeader: 'de665a71064706f946030505eae950583f08c316f0f58997961092b1',
  totalOutput: 0n,
  txCount: 1,
  vrf: 'vrf_vk1wmmxg7swhx0raa2yddkt7ktlvh55dje8a5uwge2z90t5e7v4g5esp49zzk'
};

export const tipBlock = { ...block, nextBlock: undefined };
