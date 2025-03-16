module blockblock::blockblock;

use std::string::{String};
use sui::package;

public struct BLOCKBLOCK has drop {}

// Club Shared Objects
public struct BlockblockYonsei has key {
  id: UID,
  current_cohort: u64
}

public struct ClubCohort has key {
  id: UID,
  blockblock_id: ID,
  club_cohort: u64,
  is_recruiting: bool,
  members: vector<address>,
  is_closed_by_president: bool,
  is_closed_by_vice_president: bool,
  is_closed_by_treasurer: bool,
}

// Member Cap

public struct PresidentCap has key {
  id: UID,
  club_cohort: u64,
  vicepresident_created: bool,
  treasurer_created: bool,
  next_cohort_created: bool,
}

public struct VicePresidentCap has key {
  id: UID,
  club_cohort: u64
}

public struct TreasurerCap has key {
  id: UID,
  club_cohort: u64
}

public struct ExecutiveCommiteeMemberCap has key {
  id: UID,
  club_cohort: u64,
  team_name: String
}

public struct ProjectTeamLeaderCap has key {
  id: UID,
  club_cohort: u64,
  team_name: String
}

public struct ActiveClubMemberCap has key {
  id: UID,
  club_cohort: u64,
}

public struct ClubGraduateCap has key {
  id: UID,
  club_cohort: u64,
}

fun init(otw: BLOCKBLOCK, ctx: &mut TxContext) {
  package::claim_and_keep(otw, ctx);

  let blockblock_yonsei = BlockblockYonsei{
    id: object::new(ctx),
    current_cohort: 1
  };

  transfer::share_object(ClubCohort{
    id: object::new(ctx),
    blockblock_id: object::id(&blockblock_yonsei),
    club_cohort: 1,
    is_recruiting: false,
    members: vector<address>[ctx.sender()],
    is_closed_by_president: false,
    is_closed_by_vice_president: false,
    is_closed_by_treasurer: false,
  });
  
  transfer::share_object(blockblock_yonsei);

  transfer::transfer(PresidentCap{
    id: object::new(ctx),
    club_cohort: 1,
    vicepresident_created: false,
    treasurer_created: false,
    next_cohort_created: false,
  }, ctx.sender());
}

entry fun create_next_cohort(blockblock: &mut BlockblockYonsei, current_cohort: &ClubCohort, current_president_cap: &mut PresidentCap, next_president_address: address, ctx: &mut TxContext) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_president_cap.club_cohort, 100);

  assert!(current_cohort.is_recruiting == false, 100);
  assert!(current_cohort.is_closed_by_president && current_cohort.is_closed_by_vice_president && current_cohort.is_closed_by_treasurer, 100);

  assert!(current_cohort.members.contains(&next_president_address), 100);
  assert!(current_president_cap.next_cohort_created == false, 100);

  current_president_cap.next_cohort_created = true;

  blockblock.current_cohort = blockblock.current_cohort + 1;

  transfer::share_object(ClubCohort{
    id: object::new(ctx),
    blockblock_id: object::id(blockblock),
    club_cohort: blockblock.current_cohort,
    is_recruiting: true,
    members: vector<address>[next_president_address],
    is_closed_by_president: false,
    is_closed_by_vice_president: false,
    is_closed_by_treasurer: false,
  });

  transfer::transfer(PresidentCap{
    id: object::new(ctx),
    club_cohort: blockblock.current_cohort,
    vicepresident_created: false,
    treasurer_created: false,
    next_cohort_created: false,
  }, next_president_address)
}

public fun create_current_vice_president_cap(blockblock: &BlockblockYonsei, current_cohort: &ClubCohort, current_president_cap: &mut PresidentCap, current_vice_president_address: address, ctx: &mut TxContext) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_president_cap.club_cohort, 100);

  assert!(!current_cohort.is_closed_by_president && !current_cohort.is_closed_by_vice_president && !current_cohort.is_closed_by_treasurer, 100);

  assert!(current_cohort.members.contains(&current_vice_president_address), 100);
  assert!(current_president_cap.vicepresident_created == false, 100);
  assert!(current_president_cap.next_cohort_created == false, 100);

  current_president_cap.vicepresident_created = true;

  transfer::transfer(VicePresidentCap{
    id: object::new(ctx),
    club_cohort: blockblock.current_cohort
  }, current_vice_president_address)

}

public fun create_current_treasurer_cap(blockblock: &BlockblockYonsei, current_cohort: &ClubCohort, current_president_cap: &mut PresidentCap, current_treasurer_address: address, ctx: &mut TxContext) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_president_cap.club_cohort, 100);

  assert!(!current_cohort.is_closed_by_president && !current_cohort.is_closed_by_vice_president && !current_cohort.is_closed_by_treasurer, 100);

  assert!(current_cohort.members.contains(&current_treasurer_address), 100);
  assert!(current_president_cap.treasurer_created == false, 100);
  assert!(current_president_cap.next_cohort_created == false, 100);

  current_president_cap.treasurer_created = true;

  transfer::transfer(TreasurerCap{
    id: object::new(ctx),
    club_cohort: blockblock.current_cohort
  }, current_treasurer_address)
}


public fun add_club_member(blockblock: &BlockblockYonsei, current_cohort: &mut ClubCohort, current_president_cap: &PresidentCap, member_address: address) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_president_cap.club_cohort, 100);

  assert!(!current_cohort.is_closed_by_president && !current_cohort.is_closed_by_vice_president && !current_cohort.is_closed_by_treasurer, 100);
  assert!(current_president_cap.next_cohort_created == false, 100);
  
  assert!(current_cohort.is_recruiting, 100);
  assert!(current_cohort.members.contains(&member_address) == false, 100);

  current_cohort.members.push_back(member_address);
}

entry fun close_recruiting(blockblock: &BlockblockYonsei, current_cohort: &mut ClubCohort, current_president_cap: &PresidentCap) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_president_cap.club_cohort, 100);

  assert!(current_cohort.is_recruiting, 100);
  assert!(!current_cohort.is_closed_by_president && !current_cohort.is_closed_by_vice_president && !current_cohort.is_closed_by_treasurer, 100);

  current_cohort.is_recruiting = false;
}

entry fun close_cohort_by_current_president(blockblock: &BlockblockYonsei, current_cohort: &mut ClubCohort, current_president_cap: &PresidentCap) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_president_cap.club_cohort, 100);

  assert!(current_cohort.is_recruiting == false, 100);
  assert!(!current_cohort.is_closed_by_president, 100);

  current_cohort.is_closed_by_president = true;
}

entry fun close_cohort_by_current_vice_president(blockblock: &BlockblockYonsei, current_cohort: &mut ClubCohort, current_vice_president_cap: &VicePresidentCap) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_vice_president_cap.club_cohort, 100);

  assert!(current_cohort.is_recruiting == false, 100);
  assert!(!current_cohort.is_closed_by_president, 100);

  current_cohort.is_closed_by_vice_president = true;
}

entry fun close_cohort_by_current_treasurer(blockblock: &BlockblockYonsei, current_cohort: &mut ClubCohort, current_treasurer_cap: &TreasurerCap) {
  assert!(object::id(blockblock) == current_cohort.blockblock_id, 100);

  assert!(blockblock.current_cohort == current_cohort.club_cohort, 100);
  assert!(blockblock.current_cohort == current_treasurer_cap.club_cohort, 100);

  assert!(current_cohort.is_recruiting == false, 100);
  assert!(!current_cohort.is_closed_by_president, 100);

  current_cohort.is_closed_by_treasurer = true;
}