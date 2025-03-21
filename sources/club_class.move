
module blockblock::club_class;

use sui::dynamic_field;

public struct CurrentClass has key, store {
  id: UID,
  blockblock_ys: ID,
  class: u64,
  is_open_for_new_members: bool,
}

public struct PastClass has key {
  id: UID,
  blockblock_ys: ID,
  class: u64,
}

// ============================= Action Key

public struct AddMemberKey has store, drop, copy {}

// ============================= Functions

fun init(ctx: &mut TxContext) {

}

// ============================= Public Package Functions
public (package) fun new_and_share(
  blockblock_ys_id: ID,
  class: u64,
  ctx: &mut TxContext
) {
  let class = new(blockblock_ys_id, class, ctx);
  transfer::share_object(class);
}

// ============================= Private Functions

fun new(
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

// ============================= Methods
public (package) fun request_to_join(class: &mut CurrentClass, ctx: &TxContext){
  if (!dynamic_field::exists_(&class.id, AddMemberKey{})) {
    dynamic_field::add(&mut class.id, AddMemberKey{}, vector::empty<address>());
  };
  dynamic_field::borrow_mut<AddMemberKey, vector<address>>(
    &mut class.id, 
    AddMemberKey{}
  ).push_back(ctx.sender())
}

public (package) fun set_open_to_join(class: &mut CurrentClass){
  class.is_open_for_new_members = true;
}

public (package) fun set_close_to_join(class: &mut CurrentClass){
  class.is_open_for_new_members = false;
}

public (package) fun is_open_for_new_members(class: &mut CurrentClass): bool{
  class.is_open_for_new_members
}

public (package) fun class(class: &CurrentClass): u64 {
  class.class
}

public (package) fun blockblock_ys(class: &CurrentClass): ID {
  class.blockblock_ys
}