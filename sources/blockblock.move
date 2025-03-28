module blockblock::blockblock;

use std::string::{String};
use std::type_name::{Self, TypeName};
use sui::package::{Self};
use sui::dynamic_field;

use blockblock::club_class::{Self, CurrentClass, PastClass};
use blockblock::executive_member::{Self, ExecutiveMemberCap, ExecutiveMemberTicket, President};
use blockblock::blockblock_member::{Self, BlockblockMemberCap, TeamLeaderCap};
use blockblock::alumni::{AlumniCap};

const E_NOT_BLCKBLCK_ID: u64 = 1;
const E_NOT_CURRENT_CLASS: u64 = 2;
const E_NOT_EXE_COMMIT_TYPE: u64 = 3;
const E_CLUB_NOT_OPENED: u64 = 4;

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

  club_class::new_and_share(object::id(&blockblock_ys), 1, ctx);
  transfer::freeze_object(blockblock_ys);
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
    assert!(executive_member::is_executive_member_type<MemberType>(), E_NOT_EXE_COMMIT_TYPE);

    let ticket = executive_member::new_executive_member_ticket<MemberType>(current_class, ctx);
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

entry fun confirm_ticket_and_send_member_cap<MemberType: store>(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ticket: ExecutiveMemberTicket<MemberType>, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);
    assert!(executive_member::is_executive_member_type<MemberType>(), E_NOT_EXE_COMMIT_TYPE);

    let member_address = ticket.member_address().extract();
    let executive_member_cap = executive_member::convert_ticket_to_cap(ticket, ctx);
    executive_member_cap.transfer(member_address);
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

entry fun create_and_send_member_caps(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
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