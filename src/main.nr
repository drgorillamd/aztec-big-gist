mod my_note;

contract Test {
    use dep::std::option::Option;

    use dep::aztec::{
        note::{
            note_getter_options::NoteGetterOptions,
            note_header::NoteHeader,
            utils as note_utils,
        },
        context::{PrivateContext, PublicContext, Context},
        hash::{compute_secret_hash},
        state_vars::{map::Map, public_state::PublicState, set::Set},
        types::type_serialization::{
            field_serialization::{FieldSerializationMethods, FIELD_SERIALIZED_LEN},
            bool_serialization::{BoolSerializationMethods, BOOL_SERIALIZED_LEN},
            aztec_address_serialization::{AztecAddressSerializationMethods, AZTEC_ADDRESS_SERIALIZED_LEN},
        },
        types::address::{AztecAddress},
        selector::compute_selector,
    };

    use crate::my_note::{MyNote, MyNoteMethods, MY_NOTE_LEN};

    use dep::authwit::{
        auth::{
            assert_current_call_valid_authwit, 
            assert_current_call_valid_authwit_public, 
        },
    };



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


    #[aztec(private)]
    fn settle_escrow(from: AztecAddress, recipient: AztecAddress, amount: Field, randomness: Field, nonce: Field) -> Field {

        if (from.address != context.msg_sender()) {
            assert_current_call_valid_authwit(&mut context, from);
        } else {
            assert(nonce == 0);
        }
 
        let escrows = storage.my_set;

        // Filter the note
        let options = NoteGetterOptions::new().select(0, amount).select(1, from.address).set_limit(1);
        let note = escrows.get_notes(options)[0].unwrap_unchecked();

        // Nullify the note
        escrows.remove(note);

        1
    }

    unconstrained fn compute_note_hash_and_nullifier(contract_address: Field, nonce: Field, storage_slot: Field, preimage: [Field; MY_NOTE_LEN]) -> [Field; 4] {
        let note_header = NoteHeader::new(contract_address, nonce, storage_slot);
        note_utils::compute_note_hash_and_nullifier(MyNoteMethods, note_header, preimage)
    }
}
