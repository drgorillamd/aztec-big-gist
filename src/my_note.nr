use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
        utils::compute_note_hash_for_read_or_nullify,
        note_getter_options::NoteGetterOptions,
    },
    context::PrivateContext,
    types::{
        type_serialization::{
            aztec_address_serialization::{AztecAddressSerializationMethods, AZTEC_ADDRESS_SERIALIZED_LEN},
        },
        address::{AztecAddress}, 
    },
    state_vars::{set::Set},
};

global MY_NOTE_LEN: Field = 1;

struct MyNote {
    agent: AztecAddress,
    header: NoteHeader,
}

impl MyNote {
    pub fn new(value: Field, agent: AztecAddress, participants: [Field; 4]) -> Self {
        let header = NoteHeader::empty();
        MyNote {
            agent,
            header,
        }
    }

    pub fn serialize(self) -> [Field; MY_NOTE_LEN] {
        [self.agent.address]
    }

    pub fn deserialize(preimage: [Field; MY_NOTE_LEN]) -> Self {
        MyNote {
            agent: AztecAddress::new(preimage[0]),
            header: NoteHeader::empty(),
        }
    }

    pub fn compute_note_hash(self) -> Field {
        dep::std::hash::pedersen(serialize(self))[0]
    }

    fn compute_nullifier(self) -> Field {
        0
    }

    pub fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
    }

    pub fn broadcast(self, context: &mut PrivateContext, slot: Field) {
    }
}

fn deserialize(preimage: [Field; MY_NOTE_LEN]) -> MyNote {
    MyNote::deserialize(preimage)
}

fn serialize(note: MyNote) -> [Field; MY_NOTE_LEN] {
    note.serialize()
}

fn compute_note_hash(note: MyNote) -> Field {
    note.compute_note_hash()
}

fn compute_nullifier(note: MyNote) -> Field {
    note.compute_nullifier()
}

fn get_header(note: MyNote) -> NoteHeader {
    note.header
}

fn set_header(note: &mut MyNote, header: NoteHeader) {
    note.set_header(header)
}

// Broadcasts the note as an encrypted log on L1.
fn broadcast(context: &mut PrivateContext, slot: Field, note: MyNote) {
    note.broadcast(context, slot);
}

global MyNoteMethods = NoteInterface {
    deserialize,
    serialize,
    compute_note_hash,
    compute_nullifier,
    get_header,
    set_header,
    broadcast,
};
