
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
