
module blockblock::blockblock_member;
use std::string::{String};

public struct BlockblockMemberCap has key {
  id: UID,
  club_class: u64,
}

public struct TeamLeaderCap has key {
  id: UID,
  club_class: u64,
  team_name: String
}

public (package) fun new(club_class: u64, ctx: &mut TxContext): BlockblockMemberCap {
  BlockblockMemberCap{
    id: object::new(ctx),
    club_class
  }
}

public (package) fun transfer(cap: BlockblockMemberCap, recipient: address) {
  transfer::transfer(cap, recipient)
}