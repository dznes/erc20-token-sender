#[starknet::contract]
mod YieldTokenERC20 {
    use openzeppelin::token::erc20::ERC20Component;
    use starknet::ContractAddress;
    use starknet::{get_block_timestamp};

    const max_interest_fee_rate: u128 = 20;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        expiry: u32, // hex decimal
        interest_fee_rate: u128,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_supply: u256, recipient: ContractAddress) {
        let name = "YieldToken";
        let symbol = "YT";
        let expiry: u32 = 1751545695;
        let interest_fee_rate: u128 = 0;

        self.erc20.initializer(name, symbol);
        self.erc20._mint(recipient, initial_supply);
        self.expiry.write(expiry);
        self.interest_fee_rate.write(interest_fee_rate);
    }

    #[external(v0)]
    fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
        // Set permissions with Ownable
        // self.ownable.assert_only_owner();
        // ANYONE can mint tokens
        self.erc20._mint(recipient, amount);
    }

    #[external(v0)]
    fn burn(ref self: ContractState, recipient: ContractAddress, amount: u256) {
        // Set permissions with Ownable
        // self.ownable.assert_only_owner();
        // ANYONE can burn tokens

        self.erc20._burn(recipient, amount);
    }

    #[external(v0)]
    fn set_expiry(ref self: ContractState, expiry: u32) {
        // Set permissions with Ownable
        // self.ownable.assert_only_owner();
        // ANYONE can burn tokens
        self.expiry.write(expiry);
    }

    #[external(v0)]
    fn get_expiry(ref self: ContractState) -> u32 {
        // Set permissions with Ownable
        // self.ownable.assert_only_owner();
        // ANYONE can burn tokens
        self.expiry.read()
    }

    #[external(v0)]
    fn is_expired(ref self: ContractState) -> bool {
        // let execution_info = get_execution_info().unbox();
        // let block_info = execution_info.block_info.unbox();
        // let block_timestamp = block_info.block_timestamp;

        let block_timestamp = get_block_timestamp();
        let time_u32: u32 = block_timestamp.try_into().unwrap();

        let expiration_date = self.expiry.read();

        if expiration_date > time_u32 {
            false
        } else {
            true
        }
    }

    #[external(v0)]
    fn get_generation_timestamp(ref self: ContractState) -> u64 {
        // let execution_info = get_execution_info().unbox();
        // let block_info = execution_info.block_info.unbox();
        // let block_timestamp = block_info.block_timestamp;

        let block_timestamp = get_block_timestamp();

        return block_timestamp;
    }

    #[external(v0)]
    fn set_interest_fee_rate(ref self: ContractState, interest_fee_rate: u128) {
        // Set permissions with Ownable
        // self.ownable.assert_only_owner();
        // ANYONE can burn tokens
        if interest_fee_rate > max_interest_fee_rate {
            panic!("Interest fee rate cannot exceed {}%", max_interest_fee_rate);
        }
        self.interest_fee_rate.write(interest_fee_rate);
    }
    
    #[external(v0)]
    fn get_interest_fee_rate(ref self: ContractState) -> u128 {
        self.interest_fee_rate.read()
    }

    #[external(v0)]
    fn redeem(ref self: ContractState, recipient: ContractAddress, amount: u256) {
        // Set permissions with Ownable
        // self.ownable.assert_only_owner();
        // ANYONE can burn tokens
        self.erc20._burn(recipient, amount);
    }
}
