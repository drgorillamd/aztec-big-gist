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
    use dep::authwit::auth::assert_current_call_valid_authwit;
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
    fn remove_note(from: AztecAddress) -> Field {

        if (from.address != context.msg_sender()) { // commenting out this if fix compilation, same as...
            assert_current_call_valid_authwit(&mut context, from);
        } 
 
        let stored_set = storage.my_set;

        let options = NoteGetterOptions::new().select(1, from.address).set_limit(1);
        let note = stored_set.get_notes(options)[0].unwrap_unchecked();

        stored_set.remove(note); // ... commenting out this .remove()

        1
    }
}
