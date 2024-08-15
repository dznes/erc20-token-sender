use starknet::{
    get_caller_address, contract_address_const, ContractAddress, get_contract_address, Into
};
use array::{ArrayTrait, SpanTrait};

use zeroable::Zeroable;
use debug::PrintTrait;

use token_sender::erc20::erc20::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};
use token_sender::pt_erc20::pt_interface::{IPrincipalTokenERC20, IPrincipalTokenERC20Dispatcher, IPrincipalTokenERC20DispatcherTrait};
use token_sender::yt_erc20::yt_interface::{IYieldTokenERC20, IYieldTokenERC20Dispatcher, IYieldTokenERC20DispatcherTrait};

#[derive(Drop, Serde, Copy)]
struct TransferRequest {
    recipient: ContractAddress,
    amount: u256,
}

#[starknet::interface]
trait ITokenSender<TContractState> {
    fn multisend(
        self: @TContractState, token_address: ContractAddress, transfer_list: Array<TransferRequest>
    ) -> ();
    fn stake(
        self: @TContractState, 
        token_address: ContractAddress, 
        pt_address: ContractAddress,
        yt_address: ContractAddress, 
        amount: u256
    ) -> ();
}

#[starknet::contract]
mod TokenSender {
    use starknet::{
        get_caller_address, contract_address_const, ContractAddress, get_contract_address, Into
    };

    use zeroable::Zeroable;
    use array::{ArrayTrait, SpanTrait};

    use token_sender::erc20::erc20::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};
    use token_sender::pt_erc20::pt_interface::{IPrincipalTokenERC20, IPrincipalTokenERC20Dispatcher, IPrincipalTokenERC20DispatcherTrait};
    use token_sender::yt_erc20::yt_interface::{IYieldTokenERC20, IYieldTokenERC20Dispatcher, IYieldTokenERC20DispatcherTrait};

    use debug::PrintTrait;

    use super::TransferRequest;


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TokensSent: TokensSent,
    }
    #[derive(Drop, starknet::Event)]
    struct TokensSent {
        token_address: ContractAddress,
        recipients: felt252,
    }


    #[constructor]
    fn constructor(ref self: ContractState,) {}

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl TokenSender of super::ITokenSender<ContractState> {
        fn multisend(
            self: @ContractState,
            token_address: ContractAddress,
            transfer_list: Array<TransferRequest>
        ) {
            let erc20 = IERC20Dispatcher { contract_address: token_address };

            let mut total_amount: u256 = 0;

            let transfer_list = @transfer_list;
            let mut index = 0;
            loop {
                if index == transfer_list.len() {
                    break ();
                }
                total_amount += *transfer_list.at(index).amount;
                index += 1;
            };

            erc20.transfer_from(get_caller_address(), get_contract_address(), total_amount);

            let mut index = 0;
            loop {
                if index == transfer_list.len() {
                    break ();
                }
                erc20.transfer(*transfer_list.at(index).recipient, *transfer_list.at(index).amount);
                index += 1;
            };
        }

        fn stake(
            self: @ContractState,
            token_address: ContractAddress,
            pt_address: ContractAddress,
            yt_address: ContractAddress,
            amount: u256
        ) {
            // create dispatchers for the contracts
            let erc20 = IERC20Dispatcher { contract_address: token_address };
            let ptTk = IPrincipalTokenERC20Dispatcher { contract_address: pt_address };
            let ytTk = IYieldTokenERC20Dispatcher { contract_address: yt_address };

            // transfer the tokens from the caller to the contract
            erc20.transfer_from(get_caller_address(), get_contract_address(), amount);
            ptTk.mint(get_caller_address(), amount);
            ytTk.mint(get_caller_address(), amount);
    
            // // add the user to the list
            // let mut usrList = self.users.read();
            // usrList.append(addr).expect('failed to append');
        }
    }
}
