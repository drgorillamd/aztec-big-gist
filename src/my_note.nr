use dep::aztec::{
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
        utils::compute_note_hash_for_read_or_nullify,
        note_getter_options::NoteGetterOptions,
    },
    oracle::{
        rand::rand,
        get_secret_key::get_secret_key,
        get_public_key::get_public_key,
    },
    log::emit_encrypted_log,
    hash::pedersen_hash,
    context::PrivateContext,
    types::{
        type_serialization::{
            aztec_address_serialization::{AztecAddressSerializationMethods, AZTEC_ADDRESS_SERIALIZED_LEN},
        },
        address::{AztecAddress}, 
    },
    state_vars::{set::Set},
};

global MY_NOTE_LEN: Field = 7; // 3 plus 4 participants plus a header.

// docs:start:value-note-def
struct MyNote {
    value: Field,
    agent: AztecAddress,
    randomness: Field,
    // Having the participants in the note leaks some privacy as all the participants will know each other.
    // But, it allows us to use the broadcast function correctly and to be able to do partial withdrawals of the escrow.
    participants: [Field; 4], 
    header: NoteHeader,
}
// docs:end:value-note-def

impl MyNote {
    pub fn new(value: Field, agent: AztecAddress, participants: [Field; 4]) -> Self {
        let randomness = rand();
        let header = NoteHeader::empty();
        MyNote {
            value,
            agent,
            randomness,
            participants,
            header,
        }
    }

    pub fn serialize(self) -> [Field; MY_NOTE_LEN] {
        [
            self.value, 
            self.agent.address, 
            self.randomness, 
            self.participants[0], 
            self.participants[1], 
            self.participants[2], 
            self.participants[3]
        ]
    }

    pub fn deserialize(preimage: [Field; MY_NOTE_LEN]) -> Self {
        MyNote {
            value: preimage[0],
            agent: AztecAddress::new(preimage[1]),
            randomness: preimage[2],
            participants: 
                [
                    preimage[3], 
                    preimage[4], 
                    preimage[5], 
                    preimage[6]
                ],
            header: NoteHeader::empty(),
        }
    }

    pub fn compute_note_hash(self) -> Field {
        // TODO(#1205) Should use a non-zero generator index.
        dep::std::hash::pedersen(serialize(self))[0]
    }

    // docs:start:nullifier

    fn compute_nullifier(self) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_read_or_nullify(MyNoteMethods, self);
        let nullifier_key = self.randomness;

        dep::std::hash::pedersen([
            note_hash_for_nullify,
            nullifier_key,
        ])[0]
    }

    // docs:end:nullifier

    pub fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
    }

    // Broadcasts the note as an encrypted log on L1 to all the participants.
    pub fn broadcast(self, context: &mut PrivateContext, slot: Field) {
        let agent_pub_key = get_public_key(self.agent.address);
        if (agent_pub_key.x + agent_pub_key.y != 0) {
            emit_encrypted_log(
                context,
                (*context).this_address(),
                slot,
                agent_pub_key,
                self.serialize(),
            );
        }

        for i in 0..self.participants.len() {
            if(self.participants[i] != 0) {
                let encryption_pub_key = get_public_key(self.participants[i]);
                emit_encrypted_log(
                    context,
                    (*context).this_address(),
                    slot,
                    encryption_pub_key,
                    self.serialize(),
                );
            }
        }
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
