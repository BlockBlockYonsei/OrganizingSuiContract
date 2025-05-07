module blockblock::blockblock;

use std::string::{String};
use std::type_name::{Self};
use sui::package::{Self};

use blockblock::club_class::{Self, CurrentClass, PastClass};
use blockblock::executive_member::{Self, ExecutiveMemberCap, ExecutiveMemberTicket, President, PlanningTeamMember, MarketingTeamMember};
use blockblock::blockblock_member::{Self};

const E_NOT_BLCKBLCK_ID: u64 = 1;
const E_NOT_CURRENT_CLASS: u64 = 2;
const E_NOT_EXE_COMMIT_TYPE: u64 = 3;
const E_CLUB_NOT_OPENED: u64 = 5;
const E_WRONG_CURRENT_NEXT_CLASS: u64 = 6;

public struct BLOCKBLOCK has drop {}

public struct BlockblockYonsei has key {
  id: UID,
  founded_on: String
}

fun init(otw: BLOCKBLOCK, ctx: &mut TxContext) {
  package::claim_and_keep(otw, ctx);

  let blockblock_ys = BlockblockYonsei{
    id: object::new(ctx),
    founded_on: b"2022.10.11".to_string(),
  };

  let mut first_club_class = club_class::new(object::id(&blockblock_ys), 1, ctx);

  let first_president_cap = executive_member::new_cap<President>(1, ctx);
  first_club_class.add_executive_member<President>(ctx.sender());

  transfer::freeze_object(blockblock_ys);
  first_club_class.share();
  first_president_cap.transfer_cap(ctx.sender());
}

// ========================== Entry Functions

entry fun send_executive_member_ticket<MemberType: store>(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  recipient: address, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    let ticket = executive_member::new_ticket<MemberType>(current_class.class(), ctx);
    ticket.tranfer_ticket(recipient);
}

entry fun send_back_ticket_with_address<MemberType: store>(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &CurrentClass, 
  ticket: ExecutiveMemberTicket<MemberType>, 
  ctx: &TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == ticket.club_class_ticket(), E_NOT_CURRENT_CLASS);
    assert!(executive_member::is_executive_member_type<MemberType>(), E_NOT_EXE_COMMIT_TYPE);

    let mut ticket = ticket;
    ticket.set_member_address(ctx.sender());
    let president_address = ticket.president();

    ticket.tranfer_ticket(president_address);
}

entry fun confirm_ticket_and_transfer_member_cap<MemberType: store>(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ticket: ExecutiveMemberTicket<MemberType>, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);
    assert!(executive_member::is_executive_member_type<MemberType>(), E_NOT_EXE_COMMIT_TYPE);

    let member_address = ticket.member_address().extract();
    if(type_name::get<MemberType>() != type_name::get<PlanningTeamMember>()
      && type_name::get<MemberType>() != type_name::get<MarketingTeamMember>()
    ){
      current_class.add_executive_member<MemberType>(member_address);
    };
    let executive_member_cap = executive_member::convert_ticket_to_cap(ticket, ctx);
    executive_member_cap.transfer_cap(member_address);
}

entry fun open_club_to_join(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    current_class.set_open_to_join();
}

entry fun close_club_to_join(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    current_class.set_close_to_join();
}

entry fun request_to_join_club(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  ctx: &TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.is_open_for_new_members(), E_CLUB_NOT_OPENED);
    
    current_class.request_to_join(ctx);
}

entry fun create_and_transfer_member_caps(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    current_class.borrow_member_address_vec().do_ref!<address,_>(
      |a| {
      let cap = blockblock_member::new(current_class.class(), ctx); 
      let member_address = *a;
      cap.transfer(member_address);
      }
    );
}

entry fun request_to_close_current_club_class<MemberType: store>(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  executive_member_cap: &ExecutiveMemberCap<MemberType>, 
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == executive_member_cap.club_class(), E_NOT_CURRENT_CLASS);

    current_class.request_to_close_current_club<MemberType>();
}

entry fun close_current_class_and_create_next_class(
  blockblock_ys: &BlockblockYonsei, 
  current_class: CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    let next_club_class = club_class::new(object::id(blockblock_ys), current_class.class() + 1, ctx);

    current_class.convert_current_class_to_past_class(&next_club_class, ctx);
    next_club_class.share();
}

entry fun send_president_ticket(
  blockblock_ys: &BlockblockYonsei, 
  previous_class: &PastClass, 
  current_class: &CurrentClass, 
  previous_president_cap: &ExecutiveMemberCap<President>, 
  next_president: address, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == previous_class.blockblock_ys_past(), E_NOT_BLCKBLCK_ID);
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(previous_class.class_past() == previous_president_cap.club_class(), E_NOT_CURRENT_CLASS);
    assert!(previous_class.class_past() + 1 == current_class.class(), E_WRONG_CURRENT_NEXT_CLASS);
    // next_president는 previous_class의 member 중 한 명이어야 한다.

    let president_ticket = executive_member::new_ticket<President>(current_class.class(), ctx);
    president_ticket.tranfer_ticket(next_president);
}

entry fun send_back_president_ticket_with_address(
  blockblock_ys: &BlockblockYonsei, 
  previous_class: &PastClass, 
  current_class: &CurrentClass, 
  next_president_ticket: ExecutiveMemberTicket<President>, 
  ctx: &TxContext
  ){
    assert!(object::id(blockblock_ys) == previous_class.blockblock_ys_past(), E_NOT_BLCKBLCK_ID);
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(previous_class.class_past() + 1 == current_class.class(), E_WRONG_CURRENT_NEXT_CLASS);
    assert!(current_class.class() == next_president_ticket.club_class_ticket(), E_NOT_CURRENT_CLASS);
    

    let mut next_president_ticket = next_president_ticket;
    next_president_ticket.set_member_address(ctx.sender());
    let previous_president_address = next_president_ticket.president();

    next_president_ticket.tranfer_ticket(previous_president_address)
}

entry fun confirm_ticket_and_transfer_president_cap(
  blockblock_ys: &BlockblockYonsei, 
  previous_class: &PastClass, 
  current_class: &mut CurrentClass, 
  previous_president_cap: &ExecutiveMemberCap<President>, 
  president_ticket: ExecutiveMemberTicket<President>, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == previous_class.blockblock_ys_past(), E_NOT_BLCKBLCK_ID);
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(previous_class.class_past() + 1 == current_class.class(), E_WRONG_CURRENT_NEXT_CLASS);
    assert!(previous_class.class_past() == previous_president_cap.club_class(), E_NOT_CURRENT_CLASS);

    let member_address = president_ticket.member_address().extract();
    current_class.add_executive_member<President>(member_address);
    let current_president_cap = executive_member::convert_ticket_to_cap(president_ticket, ctx);
    current_president_cap.transfer_cap(member_address);
}