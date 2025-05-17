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

  let member_cap = blockblock_member::new(first_club_class.class(), ctx); 
  member_cap.transfer(ctx.sender());

  transfer::freeze_object(blockblock_ys);
  transfer::public_share_object(first_club_class);
  first_president_cap.transfer_cap(ctx.sender());
}

// ========================== Entry Functions

// ===========================================
// ========================== Executive Member
// ===========================================
entry fun invite_executive_member<MemberType: store>(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  recipient: address, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);
    assert!(type_name::get<MemberType>() != type_name::get<President>()
      && type_name::get<MemberType>() != type_name::get<PlanningTeamMember>()
      && type_name::get<MemberType>() != type_name::get<MarketingTeamMember>(), 40404);

    let ticket = executive_member::new_ticket<MemberType>(current_class.class(), ctx);
    ticket.tranfer_ticket(recipient);
}

entry fun send_back_executive_member_ticket<MemberType: store>(
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

entry fun confirm_executive_member_ticket<MemberType: store>(
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

    current_class.add_executive_member<MemberType>(member_address);

    let member_cap = blockblock_member::new(current_class.class(), ctx); 
    member_cap.transfer(member_address);

    let executive_member_cap = executive_member::convert_ticket_to_cap(ticket, ctx);
    executive_member_cap.transfer_cap(member_address);
}

// ===========================================
// ========================== Club Recruitment
// ===========================================
entry fun start_club_recruitment(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    current_class.create_member_recruitment();
}

entry fun apply_to_join_club(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  ctx: &TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.recruitment().is_some() , E_CLUB_NOT_OPENED);
    
    current_class.request_to_join(ctx);
}

entry fun end_club_recruitment_and_grant_member_caps(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    current_class.get_recruitment_addresses().do_ref!<address,_>(
      |a| {
      let cap = blockblock_member::new(current_class.class(), ctx); 
      let member_address = *a;
      cap.transfer(member_address);
      }
    );

    current_class.delete_recruitment_and_add_members();
}

// ===========================================
// ========================== Finalizing Current Class
// ===========================================
entry fun finalize_current_class<MemberType: store>(
  blockblock_ys: &BlockblockYonsei, 
  current_class: &mut CurrentClass, 
  executive_member_cap: &ExecutiveMemberCap<MemberType>, 
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == executive_member_cap.club_class(), E_NOT_CURRENT_CLASS);

    current_class.request_to_close_current_club<MemberType>();
}

entry fun initiate_class_transition(
  blockblock_ys: &BlockblockYonsei, 
  current_class: CurrentClass, 
  president_cap: &ExecutiveMemberCap<President>, 
  ctx: &mut TxContext
  ){
    assert!(object::id(blockblock_ys) == current_class.blockblock_ys(), E_NOT_BLCKBLCK_ID);
    assert!(current_class.class() == president_cap.club_class(), E_NOT_CURRENT_CLASS);

    let next_club_class = club_class::new(object::id(blockblock_ys), current_class.class() + 1, ctx);

    current_class.convert_current_class_to_past_class(&next_club_class, ctx);
    transfer::public_share_object(next_club_class);
}

// ===========================================
// ========================== Appointment Next Presient
// ===========================================
entry fun appoint_president(
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
    // 근데 전전 단계는? 전전전 단계는?? 역대 PastClass 중에 있는 member라면 가능하게 해야 함

    let president_ticket = executive_member::new_ticket<President>(current_class.class(), ctx);
    president_ticket.tranfer_ticket(next_president);
}

entry fun send_back_president_ticket(
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

entry fun confirm_president_ticket(
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