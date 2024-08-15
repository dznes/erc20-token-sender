use snforge_std::{declare, start_prank, stop_prank, ContractClassTrait, CheatTarget};

use snforge_std::{
    spy_events, SpyOn, EventSpy, EventFetcher, Event, event_name_hash, EventAssertions
};

use starknet::{
    contract_address_const, get_block_info, ContractAddress, Felt252TryIntoContractAddress, TryInto,
    Into, OptionTrait, class_hash::Felt252TryIntoClassHash, get_caller_address,
    get_contract_address,
};


use starknet::storage_read_syscall;

// use token_sender::tests::test_utils::{assert_eq};

use array::{ArrayTrait, SpanTrait, ArrayTCloneImpl};
use result::ResultTrait;
use serde::Serde;

use box::BoxTrait;
use integer::u256;

use token_sender::erc20::mock_erc20::MockERC20;
use token_sender::erc20::mock_erc20::MockERC20::{Event::ERC20Event};
use token_sender::erc20::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};

use token_sender::pt_erc20::pt_erc20::PrincipalTokenERC20;
// use token_sender::pt_erc20::pt_erc20::PrincipalTokenERC20::{Event::ERC20Event as PTEvent};
use token_sender::pt_erc20::pt_interface::{IPrincipalTokenERC20, IPrincipalTokenERC20Dispatcher, IPrincipalTokenERC20DispatcherTrait};

use token_sender::yt_erc20::yt_erc20::YieldTokenERC20;
// use token_sender::yt_erc20::yt_erc20::YieldTokenERC20::{Event::ERC20Event as YTEvent};
use token_sender::yt_erc20::yt_interface::{IYieldTokenERC20, IYieldTokenERC20Dispatcher, IYieldTokenERC20DispatcherTrait};

use token_sender::token_sender::sender::{ITokenSenderDispatcher, ITokenSenderDispatcherTrait};
use token_sender::token_sender::sender::TransferRequest;


const INITIAL_SUPPLY: u256 = 1000000000;

fn setup() -> (ContractAddress, ContractAddress) {
    let erc20_class_hash = declare("MockERC20").unwrap();
    // let account: ContractAddress = get_contract_address();

    let account: ContractAddress = contract_address_const::<1>();
    // let account: ContractAddress = get_contract_address();

    let mut calldata = ArrayTrait::new();
    INITIAL_SUPPLY.serialize(ref calldata);
    account.serialize(ref calldata);

    let (erc20_address, _) = erc20_class_hash.deploy(@calldata).unwrap();

    let token_sender_class_hash = declare("TokenSender").unwrap();
    // let account: ContractAddress = get_contract_address();

    let mut calldata = ArrayTrait::new();

    let (token_sender_address, _) = token_sender_class_hash.deploy(@calldata).unwrap();

    (erc20_address, token_sender_address)
}

fn setupWithPtYt() -> (ContractAddress, ContractAddress, ContractAddress, ContractAddress) {
    let erc20_class_hash = declare("MockERC20").unwrap();
    let pt_class_hash = declare("PrincipalTokenERC20").unwrap();
    let yt_class_hash = declare("YieldTokenERC20").unwrap();
    // let account: ContractAddress = get_contract_address();

    let account: ContractAddress = contract_address_const::<1>();
    // let account: ContractAddress = get_contract_address();

    let mut calldata = ArrayTrait::new();
    INITIAL_SUPPLY.serialize(ref calldata);
    account.serialize(ref calldata);

    let (erc20_address, _) = erc20_class_hash.deploy(@calldata).unwrap();

    let underlying_asset_supply: u256 = 0;

    let mut underlying_calldata = ArrayTrait::new();
    underlying_asset_supply.serialize(ref underlying_calldata);
    account.serialize(ref underlying_calldata);

    let (pt_address, _) = pt_class_hash.deploy(@underlying_calldata).unwrap();
    let (yt_address, _) = yt_class_hash.deploy(@underlying_calldata).unwrap();

    let token_sender_class_hash = declare("TokenSender").unwrap();
    // let account: ContractAddress = get_contract_address();

    let mut calldata = ArrayTrait::new();

    let (token_sender_address, _) = token_sender_class_hash.deploy(@calldata).unwrap();

    (erc20_address, pt_address, yt_address,token_sender_address)
}

#[test]
fn test_single_send() {
    let (erc20_address, token_sender_address) = setup();
    let erc20 = IERC20Dispatcher { contract_address: erc20_address };

    let account: ContractAddress = contract_address_const::<1>();

    assert(erc20.balance_of(account) == INITIAL_SUPPLY, 'Balance should be > 0');

    start_prank(CheatTarget::One(erc20_address), account);

    let transfer_value: u256 = 100;
    erc20.approve(token_sender_address, transfer_value * 2);

    assert(
        erc20.allowance(account, token_sender_address) == transfer_value * 2, 'Allowance not set'
    );
    stop_prank(CheatTarget::One(erc20_address));

    let balance_before = erc20.balance_of(account);
    println!("Balance {}", balance_before);

    // Send tokens via multisend
    let token_sender = ITokenSenderDispatcher { contract_address: token_sender_address };
    let dest1: ContractAddress = contract_address_const::<2>();
    let request1 = TransferRequest { recipient: dest1, amount: transfer_value };

    let mut transfer_list = ArrayTrait::<TransferRequest>::new();
    transfer_list.append(request1);

    // need to also prang the token sender
    start_prank(CheatTarget::One(token_sender_address), account);
    token_sender.multisend(erc20_address, transfer_list);

    let balance_after = erc20.balance_of(dest1);
    assert(balance_after == transfer_value, 'Balance should be > 0');
}

#[test]
fn test_single_send_fuzz(transfer_value: u256) {
    let (erc20_address, token_sender_address) = setup();
    let erc20 = IERC20Dispatcher { contract_address: erc20_address };

    let account: ContractAddress = contract_address_const::<1>();

    assert(erc20.balance_of(account) == INITIAL_SUPPLY, 'Balance should be > 0');

    start_prank(CheatTarget::One(erc20_address), account);

    let transfer_value: u256 = 100;
    erc20.approve(token_sender_address, transfer_value * 2);

    assert(
        erc20.allowance(account, token_sender_address) == transfer_value * 2, 'Allowance not set'
    );
    stop_prank(CheatTarget::One(erc20_address));

    // Send tokens via multisend
    let token_sender = ITokenSenderDispatcher { contract_address: token_sender_address };
    let dest1: ContractAddress = contract_address_const::<2>();
    let request1 = TransferRequest { recipient: dest1, amount: transfer_value };

    let mut transfer_list = ArrayTrait::<TransferRequest>::new();
    transfer_list.append(request1);

    // need to also prang the token sender
    start_prank(CheatTarget::One(token_sender_address), account);
    token_sender.multisend(erc20_address, transfer_list);

    let balance_after = erc20.balance_of(dest1);
    assert(balance_after == transfer_value, 'Balance should be > 0');
}

#[test]
fn test_multisend() {
    let (erc20_address, token_sender_address) = setup();
    let erc20 = IERC20Dispatcher { contract_address: erc20_address };

    let account: ContractAddress = contract_address_const::<1>();

    assert(erc20.balance_of(account) == INITIAL_SUPPLY, 'Balance should be > 0');

    start_prank(CheatTarget::One(erc20_address), account);

    let transfer_value: u256 = 100;
    erc20.approve(token_sender_address, transfer_value * 2);

    assert(
        erc20.allowance(account, token_sender_address) == transfer_value * 2, 'Allowance not set'
    );
    stop_prank(CheatTarget::One(erc20_address));

    let balance = erc20.balance_of(account);
    println!("Balance {}", balance);

    // Send tokens via multisend
    let token_sender = ITokenSenderDispatcher { contract_address: token_sender_address };
    let dest1: ContractAddress = contract_address_const::<2>();
    let dest2: ContractAddress = contract_address_const::<3>();
    let request1 = TransferRequest { recipient: dest1, amount: transfer_value };
    let request2 = TransferRequest { recipient: dest2, amount: transfer_value };

    let mut transfer_list = ArrayTrait::<TransferRequest>::new();
    transfer_list.append(request1);
    transfer_list.append(request2);

    // need to also prang the token sender
    start_prank(CheatTarget::One(token_sender_address), account);
    token_sender.multisend(erc20_address, transfer_list);

    let balance_after = erc20.balance_of(dest1);
    assert(balance_after == transfer_value, 'Balance should be > 0');
    let balance_after = erc20.balance_of(dest2);
    assert(balance_after == transfer_value, 'Balance should be > 0');
}

#[test]
fn test_stake() {
    let (erc20_address, pt_address, yt_address,token_sender_address) = setupWithPtYt();
    let erc20 = IERC20Dispatcher { contract_address: erc20_address };
    let pt_erc20 = IPrincipalTokenERC20Dispatcher { contract_address: pt_address };
    let yt_erc20 = IYieldTokenERC20Dispatcher { contract_address: yt_address };

    let account: ContractAddress = contract_address_const::<1>();

    assert(erc20.balance_of(account) == INITIAL_SUPPLY, 'Balance should be > 0');

    start_prank(CheatTarget::One(erc20_address), account);

    let transfer_value: u256 = 100;
    erc20.approve(token_sender_address, transfer_value * 2);

    assert(
        erc20.allowance(account, token_sender_address) == transfer_value * 2, 'Allowance not set'
    );
    stop_prank(CheatTarget::One(erc20_address));

    // Stake Tokens
    let stake_value: u256 = 50;
    let token_sender = ITokenSenderDispatcher { contract_address: token_sender_address };

    // need to also prang the token sender
    start_prank(CheatTarget::One(token_sender_address), account);

    token_sender.stake(erc20_address, pt_address, yt_address, stake_value);

    let mock_balance_after = erc20.balance_of(token_sender_address);
    assert(mock_balance_after == stake_value, 'Mock Balance should be = 50');
    println!("Contract Mock balance {}", mock_balance_after);

    let pt_balance_after = pt_erc20.balance_of(account);
    assert(pt_balance_after == stake_value, 'PT Balance should be = 50');
    println!("User PT balance {}", pt_balance_after);

    let yt_balance_after = yt_erc20.balance_of(account);
    assert(yt_balance_after == stake_value, 'YT Balance should be = 50');
    println!("User YT balance {}", yt_balance_after);
}
