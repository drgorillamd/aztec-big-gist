contract Test {
    use dep::aztec::{
        context::{Context},
        hash::{compute_secret_hash},
        state_vars::{public_state::PublicState},
        types::type_serialization::field_serialization::FieldSerializationMethods,
        types::address::{AztecAddress, EthereumAddress},
        selector::compute_selector,
    };

    #[aztec(private)]
    fn constructor(address0: AztecAddress, address1: AztecAddress) {
        assert(address0.address as u127 > address1.address as u127);
    }
}