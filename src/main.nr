mod types;
 

 /**
 @note Doesn't do much: create the contract and init an immutable singleton, then retrieve it in another function
 */
contract MyNoteTest {
    use crate::types::my_note:: {MyNote, MyNoteMethods, MY_NOTE_LEN};

    use dep::std::option::Option;

    use dep::aztec::context::Context;
    use dep::aztec::log::emit_encrypted_log;
    use dep::aztec::note::{
        note_getter_options::NoteGetterOptions,
        note_header::NoteHeader,
        note_interface::NoteInterface,
        note_viewer_options::NoteViewerOptions,
        utils as note_utils
    };
    use dep::aztec::state_vars::{
        immutable_singleton::ImmutableSingleton
    };

    use dep::aztec::types::address::AztecAddress;


    struct Storage {
        my_singleton: ImmutableSingleton<MyNote, MY_NOTE_LEN>,
    }

    impl Storage {
        fn init(context: Context) -> pub Self {
            Storage {
                my_singleton: ImmutableSingleton::new(
                    context,
                    1,
                    MyNoteMethods,
                ),
            }
        }
    }

    #[aztec(private)]
    fn constructor() {
    }
 
    #[aztec(private)]
    fn set_value(_new_value: AztecAddress) {
       let mut my_new_note = MyNote::new(_new_value);
        storage.my_singleton.initialize(&mut my_new_note, Option::none());
    }

    #[aztec(private)]
    fn test_uses_my_note() {
        let current_note = storage.my_singleton.get_note();
    }

    unconstrained fn compute_note_hash_and_nullifier(contract_address: Field, nonce: Field, storage_slot: Field, preimage: [Field; MY_NOTE_LEN]) -> [Field; 4] {
        let note_header = NoteHeader::new(contract_address, nonce, storage_slot);

        note_utils::compute_note_hash_and_nullifier(MyNoteMethods, note_header, preimage)
    }
}