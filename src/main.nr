mod my_note;

contract Test {
    use dep::aztec::{
        note::{
            note_getter_options::NoteGetterOptions,
            note_header::NoteHeader,
            utils as note_utils,
        },
        context::{PrivateContext, PublicContext, Context},
        state_vars::set::Set,
        protocol_types::address::{AztecAddress},
    };
    use dep::authwit::auth::assert_current_call_valid_authwit;
    use crate::my_note::{MyNote, MY_NOTE_LEN};

    struct Storage {
        my_set: Set<MyNote>,
    }

    impl Storage {
        fn init(context: Context) -> Self {
            Storage {
                my_set: Set::new(context, 1),
            }
        }
    }

    #[aztec(private)]
    fn constructor() {}

// This fails to compile:
/**
The application panicked (crashed).
Message:  internal error: entered unreachable code: Cannot flatten a dynamic array
Location: compiler/noirc_evaluator/src/ssa/acir_gen/acir_ir/acir_variable.rs:1137
*/

    #[aztec(private)]
    fn remove_note(from: AztecAddress) -> Field {

        if (from != context.msg_sender()) { // commenting out this fixes compilation, same as...
            assert_current_call_valid_authwit(&mut context, from);
        } 
 
        let stored_set = storage.my_set;

        let options = NoteGetterOptions::new().select(1, from.to_field(), Option::none()).set_limit(1);
        let note = stored_set.get_notes(options)[0];

        // this fails:
        stored_set.remove(note.unwrap_unchecked());

        // this works (or commenting out the previous remove):
        // if(note.is_some()) {
        //     stored_set.remove(note.unwrap_unchecked());
        // }

        1
    }

    unconstrained fn compute_note_hash_and_nullifier(contract_address: AztecAddress, nonce: Field, storage_slot: Field, note_type_id: Field, preimage: [Field; MY_NOTE_LEN]) -> pub [Field; 4] {
        let note_header = NoteHeader::new(contract_address, nonce, storage_slot);
        note_utils::compute_note_hash_and_nullifier(MyNote::deserialize_content, note_header, preimage)
    }
}
