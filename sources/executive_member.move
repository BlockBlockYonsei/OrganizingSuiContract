module blockblock::executive_member;

use std::string::{String};
use std::type_name::{Self, TypeName};

use blockblock::club_class::{CurrentClass};

// ============================= Executive Member Cap
public struct ExecutiveMemberCap<phantom MemberType: store> has key {
  id: UID,
  club_class: u64,
  member_type: String
}

public struct ExecutiveMemberTicket<phantom MemberType: store> has key {
  id: UID,
  club_class: u64,
  member_type: String,
  president: address,
  member_address: Option<address>
}

// ============================= Member Type
public struct President has store{}
public struct VicePresident has store{}
public struct Treasurer has store{}

public struct PlanningTeamLeader has store{}
public struct PlanningTeamMember has store{}

public struct MarketingTeamLeader has store{}
public struct MarketingTeamMember has store{}

// ============================= Action Key

public struct AddExecutiveMemberKey<phantom MemberType: key> has store, drop, copy {
  member: address
}
public struct ClosingClubKey has store, drop, copy {}

// ============================= Functions

fun init(ctx: &mut TxContext) {
  let first_president_cap = ExecutiveMemberCap<President> {
    id: object::new(ctx),
    club_class: 1,
    member_type: get_struct_name(type_name::get<President>())
  };

  transfer::transfer(first_president_cap, ctx.sender());
}

// ============================= Public Package Functions
public (package) fun new_executive_member_ticket<MemberType: store>(
  class: &CurrentClass, 
  ctx: &mut TxContext
  ): ExecutiveMemberTicket<MemberType>{
    ExecutiveMemberTicket<MemberType> {
      id: object::new(ctx),
      club_class: class.class(),
      president: ctx.sender(),
      member_type: get_struct_name(type_name::get<MemberType>()),
      member_address: option::none(),
    }
}

public (package) fun convert_ticket_to_cap<MemberType: store>(
  ticket: ExecutiveMemberTicket<MemberType>, 
  ctx: &mut TxContext
): ExecutiveMemberCap<MemberType> {
    let ExecutiveMemberTicket<MemberType> {id, club_class, president, member_type, member_address: _} = ticket;

    assert!(president == ctx.sender());
    id.delete();

    let executive_member_cap = ExecutiveMemberCap<MemberType> {
      id: object::new(ctx),
      club_class: club_class,
      member_type
    };

    executive_member_cap
}

public (package) fun is_executive_member_type<MemberType: store>(): bool {
  type_name::get<MemberType>() == type_name::get<President>() 
  || type_name::get<MemberType>() == type_name::get<VicePresident>() 
  || type_name::get<MemberType>() == type_name::get<Treasurer>() 
  || type_name::get<MemberType>() == type_name::get<PlanningTeamLeader>() 
  || type_name::get<MemberType>() == type_name::get<PlanningTeamMember>() 
  || type_name::get<MemberType>() == type_name::get<MarketingTeamLeader>() 
  || type_name::get<MemberType>() == type_name::get<MarketingTeamMember>() 
}
// ============================= Methods

public (package) fun club_class<MemberType: store>(cap: &ExecutiveMemberCap<MemberType>): u64 {
  cap.club_class
}

public (package) fun transfer<MemberType: store>(cap: ExecutiveMemberCap<MemberType>, recipient: address) {
  transfer::transfer(cap, recipient);
}

public (package) fun tranfer_ticket<MemberType: store>(ticket: ExecutiveMemberTicket<MemberType>, recipient: address) {
  transfer::transfer(ticket, recipient)
}

public (package) fun club_class_ticket<MemberType: store>(ticket: &ExecutiveMemberTicket<MemberType>): u64 {
  ticket.club_class
}

public (package) fun president<MemberType: store>(ticket: &ExecutiveMemberTicket<MemberType>): address {
  ticket.president
}

public (package) fun member_address<MemberType: store>(ticket: &ExecutiveMemberTicket<MemberType>): Option<address> {
  ticket.member_address
}

public (package) fun set_member_address<MemberType: store>(ticket: &mut ExecutiveMemberTicket<MemberType>, member_address: address) {
  ticket.member_address = option::some(member_address);
}


// ============================= Private Functions
fun get_struct_name(self: TypeName): String {
    let ascii_colon: u8 = 58;
    let ascii_less_than: u8 = 60;
    let ascii_greater_than: u8 = 62;

    let mut str_bytes = self.into_string().into_bytes();
    let mut struct_name = vector<u8>[];
    loop {
        let char = str_bytes.pop_back<u8>();
        if (char == ascii_less_than || char == ascii_greater_than) {
          continue
        }else if (char != ascii_colon ) {
          struct_name.push_back(char);
        } else {
            break
        }
    };

    struct_name.reverse();
    struct_name.to_string()
}