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
        types::address::{AztecAddress},
    };
    use dep::authwit::{
        auth::{
            assert_current_call_valid_authwit, 
            assert_current_call_valid_authwit_public, 
        },
    };
    use crate::my_note::{MyNote, MyNoteMethods, MY_NOTE_LEN};

    struct Storage {
        my_set: Set<MyNote, MY_NOTE_LEN>,
    }

    impl Storage {
        fn init(context: Context) -> Self {
            Storage {
                my_set: Set::new(context, 1, MyNoteMethods),
            }
        }
    }

// This fails to compile:
/**
The application panicked (crashed).
Message:  internal error: entered unreachable code: Cannot flatten a dynamic array
Location: compiler/noirc_evaluator/src/ssa/acir_gen/acir_ir/acir_variable.rs:1137
*/

    #[aztec(private)]
    fn settle_escrow(from: AztecAddress, recipient: AztecAddress, amount: Field, randomness: Field, nonce: Field) -> Field {

        if (from.address != context.msg_sender()) { // commenting out this if fix compilation, same as...
            assert_current_call_valid_authwit(&mut context, from);
        } else {
            assert(nonce == 0);
        }
 
        let escrows = storage.my_set;

        let options = NoteGetterOptions::new().select(0, amount).select(1, from.address).set_limit(1);
        let note = escrows.get_notes(options)[0].unwrap_unchecked();

        escrows.remove(note); // ... commenting out this .remove()

        1
    }

    unconstrained fn compute_note_hash_and_nullifier(contract_address: Field, nonce: Field, storage_slot: Field, preimage: [Field; MY_NOTE_LEN]) -> [Field; 4] {
        let note_header = NoteHeader::new(contract_address, nonce, storage_slot);
        note_utils::compute_note_hash_and_nullifier(MyNoteMethods, note_header, preimage)
    }


    #[aztec(private)]
    fn something_escrow(
        from: AztecAddress,
        from: AztecAddress,
        amount: Field,
        participants: [Field; 4],
        nonce: Field,
    ) -> Field {
        // create the EscrowNote
        let mut escrow_note = MyNote::new(amount, from, participants);
        storage.my_set.insert(&mut escrow_note, true);

        1
    }

}
