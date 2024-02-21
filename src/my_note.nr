use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
        note_getter_options::NoteGetterOptions,
    },
    context::PrivateContext,
    protocol_types::
    {
        address::AztecAddress, 
        traits::{Serialize, Deserialize, Empty},

    },
    state_vars::{set::Set},
};

global MY_NOTE_LEN: Field = 1;

struct MyNote {
    my_address: AztecAddress,
    header: NoteHeader,
}

impl MyNote {
    pub fn new(my_address: AztecAddress) -> Self {
        let header = NoteHeader::empty();
        MyNote {
            my_address,
            header,
        }
    }
}

impl Serialize<MY_NOTE_LEN> for MyNote {
    fn serialize(self) -> [Field; MY_NOTE_LEN] {
        [self.my_address.to_field()]
    }
}

impl Deserialize<MY_NOTE_LEN> for MyNote {
    fn deserialize(preimage: [Field; MY_NOTE_LEN]) -> Self {
        MyNote {
            my_address: AztecAddress::from_field(preimage[0]),
            header: NoteHeader::empty()
        }
    }
}

impl NoteInterface<MY_NOTE_LEN> for MyNote {
    fn serialize_content(self) -> [Field; MY_NOTE_LEN] {
        self.serialize()
    }

    fn deserialize_content(preimage: [Field; MY_NOTE_LEN]) -> Self {
        MyNote::deserialize(preimage)
    }

    pub fn compute_note_content_hash(self) -> Field {
        dep::aztec::hash::pedersen_hash(self.serialize(), 0)
    }

    fn compute_nullifier(self, context: &mut PrivateContext) -> Field {
        0
    }

    fn compute_nullifier_without_context(self) -> Field {
        0
    }

    pub fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
    }

    fn get_header(note: MyNote) -> NoteHeader {
        note.header
    }

    pub fn broadcast(self, context: &mut PrivateContext, slot: Field) {
    }
}