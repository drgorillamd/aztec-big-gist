use dep::aztec::note::{
    note_header::NoteHeader,
    note_interface::NoteInterface,
    utils::compute_note_hash_for_read_or_nullify,
};
use dep::aztec::oracle::{
    get_secret_key::get_secret_key,
    get_public_key::get_public_key,
};
use dep::aztec::types::address::AztecAddress;

struct MyNote {
    stored_value: AztecAddress,
    header: NoteHeader
}

global MY_NOTE_LEN: Field = 1;

impl MyNote {
    fn new(_new_value: AztecAddress) -> Self {
        MyNote {
            stored_value: _new_value,
            header: NoteHeader::empty(),
        }
    }

    fn serialize(self) -> [Field; MY_NOTE_LEN] {
        [self.stored_value.address]
    }

    fn deserialize(preimage: [Field; MY_NOTE_LEN]) -> Self {
        MyNote {
            stored_value: AztecAddress::new(preimage[0]),
            header: NoteHeader::empty(),
        }
    }

    fn compute_note_hash(self) -> Field {
        dep::std::hash::pedersen([
            self.stored_value.address
        ])[0]
    }

    fn compute_nullifier(self) -> Field {
         0
    }

    fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
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

global MyNoteMethods = NoteInterface {
    deserialize,
    serialize,
    compute_note_hash,
    compute_nullifier,
    get_header,
    set_header,
};