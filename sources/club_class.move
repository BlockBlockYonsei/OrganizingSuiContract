
module blockblock::club_class;

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
public (package) fun class(class: &CurrentClass): u64 {
  class.class
}

public (package) fun blockblock_ys(class: &CurrentClass): ID {
  class.blockblock_ys
}