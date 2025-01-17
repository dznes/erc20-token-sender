use starknet::ContractAddress;

#[starknet::interface]
trait IYieldTokenERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn mint(ref self: TContractState, receiver: starknet::ContractAddress, amount: u256);
    fn burn(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn set_expiry(ref self: TContractState, expiry: u32);
    fn get_expiry(ref self: TContractState) -> u32;
    fn is_expired(ref self: TContractState) -> bool;
    fn get_generation_timestamp(ref self: TContractState) -> u64;
    fn get_interest_fee_rate(ref self:TContractState) -> u128;
}
