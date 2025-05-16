
module blockblock::club_class;

use std::type_name;
use sui::dynamic_field;

use blockblock::executive_member::{President, VicePresident, Treasurer, PlanningTeamLeader, MarketingTeamLeader};
use sui::event;

const E_NOT_PRESIDENT_EXECUTIVE_MEMBER_TYPE: u64 = 1;
const E_ALREADY_CLOSED: u64 = 2;
const E_MEMBER_TYPE_ALREADY_EXIST: u64 = 3;
const E_PRESIDENT_EXECUTIVE_MEMBERS_DID_NOT_CLOSE: u64 = 4;
const E_WRONG_CURRENT_NEXT_CLASS: u64 = 5;

public struct CurrentClass has key, store {
  id: UID,
  blockblock_ys: ID,
  class: u64,
  members: vector<address>,
  recruitment: Option<MemberRecruitment>
}

public struct PastClass has key{
  id: UID,
  blockblock_ys: ID,
  class: u64,
  class_obj: CurrentClass,
}

public struct MemberRecruitment has store {
  blockblock_ys: ID,
  class: u64,
  class_id: ID,
  addresses: vector<address>,
}

// =============================== Event

public struct CreateNewClass has copy, drop {
  blockblock_ys: ID,
  class_id: ID,
  class: u64,

}

// ============================= Action Key

public struct AddExecutiveMemberKey<phantom MemberType: store> has store, drop, copy {}

public struct CloseCurrentClubKey<phantom PresidentExecutiveMemberType: store> has store, drop, copy {}


// ============================= Mutable Public Package Functions
public (package) fun new(
  blockblock_ys_id: ID,
  class: u64,
  ctx: &mut TxContext
): CurrentClass {

  let current_class =CurrentClass{
    id: object::new(ctx),
    blockblock_ys: blockblock_ys_id,
    class: class,
    members: vector<address>[],
    recruitment: option::none()
  };

  event::emit(CreateNewClass{
    blockblock_ys : blockblock_ys_id,
    class_id: object::id(&current_class),
    class: current_class.class,
  });

  current_class
}

public (package) fun create_member_recruitment(
  current_class: &mut CurrentClass, 
){
  assert!(current_class.recruitment.is_none(), 303030);

  let member_recruitment = MemberRecruitment{
    blockblock_ys: current_class.blockblock_ys,
    class: current_class.class,
    class_id: object::id(current_class),
    addresses: vector<address>[]
  };
  current_class.recruitment.fill(member_recruitment);
}

public (package) fun delete_member_recruitment_and_add_members(
  current_class: &mut CurrentClass, 
){
  assert!(current_class.recruitment.is_some(), 303333);

  let member_recruitment = current_class.recruitment.extract();
  let MemberRecruitment { blockblock_ys: _, class: _, class_id: _, addresses} = member_recruitment;

  current_class.members.append(addresses);
}

public (package) fun add_executive_member<MemberType: store>(class: &mut CurrentClass, member: address) {
  assert!(!dynamic_field::exists_(&class.id, AddExecutiveMemberKey<MemberType>{}), E_MEMBER_TYPE_ALREADY_EXIST);
  dynamic_field::add(&mut class.id, AddExecutiveMemberKey<MemberType>{}, member);
  class.members.push_back(member);
}

public (package) fun request_to_join(class: &mut CurrentClass, ctx: &TxContext){
  class.members.push_back(ctx.sender())
}

public (package) fun request_to_close_current_club<MemberType: store>(class: &mut CurrentClass) {
  assert!( type_name::get<MemberType>() == type_name::get<President>()
    || type_name::get<MemberType>() == type_name::get<VicePresident>()
    || type_name::get<MemberType>() == type_name::get<Treasurer>()
  , E_NOT_PRESIDENT_EXECUTIVE_MEMBER_TYPE);

  assert!(!dynamic_field::exists_(&class.id, CloseCurrentClubKey<MemberType>{}), E_ALREADY_CLOSED);
  dynamic_field::add(&mut class.id, CloseCurrentClubKey<MemberType>{}, 0);
}

#[allow(lint(freeze_wrapped))]
public (package) fun convert_current_class_to_past_class(current_class: CurrentClass, next_class: &CurrentClass, ctx: &mut TxContext){
  assert!(current_class.class + 1 == next_class.class, E_WRONG_CURRENT_NEXT_CLASS);
  assert!(current_class.blockblock_ys == next_class.blockblock_ys, 10);
  assert!(current_class.recruitment.is_none(), 10);

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

  let mut past_class = PastClass {
    id: object::new(ctx),
    blockblock_ys: current_class.blockblock_ys,
    class: current_class.class,
    class_obj: current_class
  };

  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<President>{}, president);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<VicePresident>{}, vice_president);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<Treasurer>{}, treasurer);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<PlanningTeamLeader>{}, planning_team_leader);
  dynamic_field::add(&mut past_class.id, AddExecutiveMemberKey<MarketingTeamLeader>{}, marketing_team_leader);

  transfer::freeze_object(past_class);
}

// ============================= Methods
public (package) fun members(class: &CurrentClass): vector<address> {
  class.members
}
public (package) fun blockblock_ys(class: &CurrentClass): ID {
  class.blockblock_ys
}

public (package) fun recruitment(class: &CurrentClass): &Option<MemberRecruitment> {
  &class.recruitment
}

public (package) fun class(class: &CurrentClass): u64 {
  class.class
}

public (package) fun class_past(class: &PastClass): u64 {
  class.class
}

public (package) fun blockblock_ys_past(class: &PastClass): ID {
  class.blockblock_ys
}
// ============================= Private Functions
