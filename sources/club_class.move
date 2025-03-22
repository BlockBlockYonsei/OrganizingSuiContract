
module blockblock::club_class;

use std::type_name;
use sui::dynamic_field;

use blockblock::executive_member::{President, VicePresident, Treasurer, PlanningTeamLeader, MarketingTeamLeader};

const E_NOT_PRESIDENT_EXECUTIVE_MEMBER_TYPE: u64 = 1;
const E_ALREADY_CLOSED: u64 = 2;
const E_MEMBER_TYPE_ALREADY_EXIST: u64 = 3;
const E_PRESIDENT_EXECUTIVE_MEMBERS_DID_NOT_CLOSE: u64 = 4;
const E_WRONG_CURRENT_NEXT_CLASS: u64 = 5;

public struct CurrentClass has key, store {
  id: UID,
  blockblock_ys: ID,
  class: u64,
  is_open_for_new_members: bool,
}

public struct PastClass has key, store {
  id: UID,
  blockblock_ys: ID,
  class: u64,
}

// ============================= Action Key

public struct AddExecutiveMemberKey<phantom MemberType: store> has store, drop, copy {}

public struct AddMemberKey has store, drop, copy {}

public struct CloseCurrentClubKey<phantom PresidentExecutiveMemberType: store> has store, drop, copy {}


// ============================= Mutable Public Package Functions
public (package) fun new(
  blockblock_ys_id: ID,
  class: u64,
  ctx: &mut TxContext
): CurrentClass {
  CurrentClass{
    id: object::new(ctx),
    blockblock_ys: blockblock_ys_id,
    class: class,
    is_open_for_new_members: false,
  }
}

#[allow(lint(share_owned))]
public (package) fun share(class: CurrentClass) {
  transfer::share_object(class);
}

public (package) fun add_executive_member<MemberType: store>(class: &mut CurrentClass, member: address) {
  assert!(!dynamic_field::exists_(&class.id, AddExecutiveMemberKey<MemberType>{}), E_MEMBER_TYPE_ALREADY_EXIST);
  dynamic_field::add(&mut class.id, AddExecutiveMemberKey<MemberType>{}, member);
}

public (package) fun set_open_to_join(class: &mut CurrentClass){
  class.is_open_for_new_members = true;
}

public (package) fun set_close_to_join(class: &mut CurrentClass){
  class.is_open_for_new_members = false;
}

public (package) fun request_to_join(class: &mut CurrentClass, ctx: &TxContext){
  if (!dynamic_field::exists_(&class.id, AddMemberKey{})) {
    dynamic_field::add(&mut class.id, AddMemberKey{}, vector::empty<address>());
  };
  dynamic_field::borrow_mut<AddMemberKey, vector<address>>(
    &mut class.id, 
    AddMemberKey{}
  ).push_back(ctx.sender())
}

public (package) fun request_to_close_current_club<MemberType: store>(class: &mut CurrentClass) {
  assert!( type_name::get<MemberType>() == type_name::get<President>()
    || type_name::get<MemberType>() == type_name::get<VicePresident>()
    || type_name::get<MemberType>() == type_name::get<Treasurer>()
  , E_NOT_PRESIDENT_EXECUTIVE_MEMBER_TYPE);

  assert!(!dynamic_field::exists_(&class.id, CloseCurrentClubKey<MemberType>{}), E_ALREADY_CLOSED);
  dynamic_field::add(&mut class.id, CloseCurrentClubKey<MemberType>{}, 0);
}

public (package) fun convert_current_class_to_past_class(current_class: CurrentClass, next_class: &CurrentClass, ctx: &mut TxContext){
  assert!(current_class.class + 1 == next_class.class, E_WRONG_CURRENT_NEXT_CLASS);
  assert!(current_class.blockblock_ys == next_class.blockblock_ys, 10);
  assert!(current_class.is_open_for_new_members == false, 10);

  assert!(
    dynamic_field::exists_(&current_class.id, CloseCurrentClubKey<President>{})
    && dynamic_field::exists_(&current_class.id, CloseCurrentClubKey<VicePresident>{})
    && dynamic_field::exists_(&current_class.id, CloseCurrentClubKey<Treasurer>{})
    , E_PRESIDENT_EXECUTIVE_MEMBERS_DID_NOT_CLOSE
  );
  let mut current_class = current_class;
  let president = dynamic_field::remove<AddExecutiveMemberKey<President>, address>(&mut current_class.id, AddExecutiveMemberKey<President>{});
  let vice_president = dynamic_field::remove<AddExecutiveMemberKey<VicePresident>, address>(&mut current_class.id, AddExecutiveMemberKey<VicePresident>{});
  let treasurer = dynamic_field::remove<AddExecutiveMemberKey<Treasurer>, address>(&mut current_class.id, AddExecutiveMemberKey<Treasurer>{});
  let planning_team_leader = dynamic_field::remove<AddExecutiveMemberKey<PlanningTeamLeader>, address>(&mut current_class.id, AddExecutiveMemberKey<PlanningTeamLeader>{});
  let marketing_team_leader = dynamic_field::remove<AddExecutiveMemberKey<MarketingTeamLeader>, address>(&mut current_class.id, AddExecutiveMemberKey<MarketingTeamLeader>{});

  let members = dynamic_field::remove<AddMemberKey, vector<address>>(&mut current_class.id, AddMemberKey{});

  let CurrentClass {id, blockblock_ys, class, is_open_for_new_members: _} = current_class;

  id.delete();

  let mut past_class = PastClass {
    id: object::new(ctx),
    blockblock_ys,
    class
  };

  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<President>{}, president);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<VicePresident>{}, vice_president);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<Treasurer>{}, treasurer);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<PlanningTeamLeader>{}, planning_team_leader);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<MarketingTeamLeader>{}, marketing_team_leader);
  dynamic_field::add(&mut past_class.id, AddMemberKey{}, members);

  transfer::freeze_object(past_class);
}

// ============================= Methods
public (package) fun borrow_member_address_vec(class: &CurrentClass): &vector<address> {
  dynamic_field::borrow<AddMemberKey, vector<address>>(&class.id, AddMemberKey{})
}

public (package) fun blockblock_ys(class: &CurrentClass): ID {
  class.blockblock_ys
}

public (package) fun class(class: &CurrentClass): u64 {
  class.class
}

public (package) fun is_open_for_new_members(class: &CurrentClass): bool{
  class.is_open_for_new_members
}

public (package) fun class_past(class: &PastClass): u64 {
  class.class
}

public (package) fun blockblock_ys_past(class: &PastClass): ID {
  class.blockblock_ys
}
// ============================= Private Functions
