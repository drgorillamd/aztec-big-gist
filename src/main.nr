contract Test {
    use dep::aztec::types::address::AztecAddress;

    #[aztec(private)]
    fn something_escrow(
        from: AztecAddress,
        agent: AztecAddress,
        amount: Field,
        participants: [AztecAddress; 4],
        nonce: Field,
    ) -> Field {
        1
    }
}