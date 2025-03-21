
module blockblock::active_member;
use std::string::{String};

public struct TeamLeaderCap has key {
  id: UID,
  club_class: u64,
  team_name: String
}

// 매 기수마다 만들면 되겠구만..!
public struct ActiveClubMemberCap has key {
  id: UID,
  club_class: u64,
}
