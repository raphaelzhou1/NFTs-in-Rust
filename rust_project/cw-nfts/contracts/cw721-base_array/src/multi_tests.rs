use cosmwasm_std::{to_binary, Addr, Empty, QuerierWrapper, WasmMsg};
use cw721::OwnerOfResponse;
use cw_multi_test::{App, Contract, ContractWrapper, Executor};
use crate::error::ContractError;
use crate::MinterResponse;
use cw721::AllNftInfoResponse;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone, JsonSchema, PartialEq)]
struct Extension {
    animation_url: Option<String>,
    attributes: Vec<Attribute>,
    description: String,
    external_url: String,
    image: String,
    name: String,
    youtube_url: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone, JsonSchema, PartialEq)]
struct Attribute {
    trait_type: String,
    value: String,
}

fn cw721_base_contract() -> Box<dyn Contract<Empty>> {
    let contract = ContractWrapper::new(
        crate::entry::execute,
        crate::entry::instantiate,
        crate::entry::query,
    )
    .with_migrate(crate::entry::migrate);
    Box::new(contract)
}

fn cw721_base_016_contract() -> Box<dyn Contract<Empty>> {
    use cw721_base_016 as v16;
    let contract = ContractWrapper::new(
        v16::entry::execute,
        v16::entry::instantiate,
        v16::entry::query,
    );
    Box::new(contract)
}

fn query_owner(querier: QuerierWrapper, cw721: &Addr, token_id: String) -> Addr {
    let resp: OwnerOfResponse = querier
        .query_wasm_smart(
            cw721,
            &crate::QueryMsg::<Empty>::OwnerOf {
                token_id,
                include_expired: None,
            },
        )
        .unwrap();
    Addr::unchecked(resp.owner)
}

fn mint_transfer_and_burn(app: &mut App, cw721: Addr, sender: Addr, token_id: String) {
    app.execute_contract(
        sender.clone(),
        cw721.clone(),
        &crate::ExecuteMsg::<Empty, Empty>::Mint {
            token_id: token_id.clone(),
            owner: sender.to_string(),
            token_uri: None,
            extension: Empty::default(),
        },
        &[],
    )
    .unwrap();

    let owner = query_owner(app.wrap(), &cw721, token_id.clone());
    assert_eq!(owner, sender.to_string());

    app.execute_contract(
        sender,
        cw721.clone(),
        &crate::ExecuteMsg::<Empty, Empty>::TransferNft {
            recipient: "burner".to_string(),
            token_id: token_id.clone(),
        },
        &[],
    )
    .unwrap();

    let owner = query_owner(app.wrap(), &cw721, token_id.clone());
    assert_eq!(owner, "burner".to_string());

    app.execute_contract(
        Addr::unchecked("burner"),
        cw721,
        &crate::ExecuteMsg::<Empty, Empty>::Burn { token_id },
        &[],
    )
    .unwrap();
}

fn mint_batch_transfer_and_burn(app: &mut App, cw721: Addr, sender: Addr, owners: Vec<Addr>, token_ids: Vec<String>, extension: Extension, ) -> Result<(), ContractError> {
    assert_eq!(owners.len(), token_ids.len()); // ensure we have same number of senders and token_ids

    app.execute_contract(
        sender.clone(),
        cw721.clone(),
        &crate::ExecuteMsg::<Extension, Empty>::MintBatch {
            token_ids: token_ids.iter().map(|a| a.to_string()).collect(),
            owners: owners.iter().map(|a| a.to_string()).collect(),
            token_uri: None,
            extension: extension.clone(),
        },
        &[],
    )
        .map_err(|_| ContractError::ClaimedInArray {
            token_ids: token_ids.clone(),
        })?;
    Ok(())
}

/// Instantiates a 0.16 version of this contract and tests that tokens
/// can be minted, transferred, and burnred after migration.
#[test]
fn test_016_017_migration() {
    use cw721_base_016 as v16;
    let mut app = App::default();
    let admin = || Addr::unchecked("admin");

    let code_id_016 = app.store_code(cw721_base_016_contract());
    let code_id_017 = app.store_code(cw721_base_contract());

    let cw721 = app
        .instantiate_contract(
            code_id_016,
            admin(),
            &v16::InstantiateMsg {
                name: "collection".to_string(),
                symbol: "symbol".to_string(),
                minter: admin().into_string(),
            },
            &[],
            "cw721-base",
            Some(admin().into_string()),
        )
        .unwrap();

    mint_transfer_and_burn(&mut app, cw721.clone(), admin(), "1".to_string());

    app.execute(
        admin(),
        WasmMsg::Migrate {
            contract_addr: cw721.to_string(),
            new_code_id: code_id_017,
            msg: to_binary(&Empty::default()).unwrap(),
        }
        .into(),
    )
    .unwrap();

    mint_transfer_and_burn(&mut app, cw721.clone(), admin(), "1".to_string());

    // check new mint query response works.
    let m: MinterResponse = app
        .wrap()
        .query_wasm_smart(&cw721, &crate::QueryMsg::<Empty>::Minter {})
        .unwrap();
    assert_eq!(m.minter, Some(admin().to_string()));

    // check that the new response is backwards compatable when minter
    // is not None.
    let m: v16::MinterResponse = app
        .wrap()
        .query_wasm_smart(&cw721, &crate::QueryMsg::<Empty>::Minter {})
        .unwrap();
    assert_eq!(m.minter, admin().to_string());
}

#[test]
fn test_batch_migration() {
    use cw721_base_016 as v16;
    let mut app = App::default();
    let admin = || Addr::unchecked("admin");

    let code_id_016 = app.store_code(cw721_base_016_contract());
    let code_id_017 = app.store_code(cw721_base_contract());

    let cw721 = app
        .instantiate_contract(
            code_id_016,
            admin(),
            &v16::InstantiateMsg {
                name: "collection".to_string(),
                symbol: "symbol".to_string(),
                minter: admin().into_string(),
            },
            &[],
            "cw721-base",
            Some(admin().into_string()),
        )
        .unwrap();

    let owners = vec![admin(), Addr::unchecked("user1"), Addr::unchecked("user2")];
    let token_ids = vec!["1".to_string(), "2".to_string(), "3".to_string()];

    let extension_json = r#"
    {
        "animation_url": null,
        "attributes": [
            {
                "trait_type": "color",
                "value": "gray"
            },
            {
                "trait_type": "ship name",
                "value": "HMS_ENCORE"
            },
            {
                "trait_type": "background color",
                "value": "yellow"
            }
        ],
        "description": "SparrowSwap April OG RUM collection",
        "external_url": "https://gateway.pinata.cloud/ipfs/QmRy4vEkXY4tVPzSt8fVPio4cuDhMVG8V651GLtBSK7ie3",
        "image": "https://gateway.pinata.cloud/ipfs/QmRy4vEkXY4tVPzSt8fVPio4cuDhMVG8V651GLtBSK7ie3",
        "name": "SparrowSwap April OG RUM",
        "youtube_url": null
    }
    "#;

    let extension: Extension = serde_json::from_str(extension_json).unwrap();

    mint_batch_transfer_and_burn(
        &mut app,
        cw721.clone(),
        admin(),
        owners.clone(),
        token_ids.clone(),
        extension.clone(),
    );

    let result = mint_batch_transfer_and_burn(&mut app, cw721.clone(), admin(), owners.clone(), token_ids.clone(), extension.clone());

    if let Err(ContractError::ClaimedInArray { token_ids }) = &result {
        assert_eq!(token_ids, &vec!["1", "2", "3"]);
    } else {
        let error_message = format!("{:?}", result);
        panic!("Unexpected error type or successful execution: {}", error_message);
    }

    // check new mint query response works.
    let m: MinterResponse = app
        .wrap()
        .query_wasm_smart(&cw721, &crate::QueryMsg::<Empty>::Minter {})
        .unwrap();
    assert_eq!(m.minter, Some(admin().to_string()));

    // check that the new response is backwards compatible when minter
    // is not None.
    let m: v16::MinterResponse = app
        .wrap()
        .query_wasm_smart(&cw721, &crate::QueryMsg::<Empty>::Minter {})
        .unwrap();
    assert_eq!(m.minter, admin().to_string());
}

#[test]
fn test_all_nft_info() {
    use cw721_base_016 as v16;
    let mut app = App::default();
    let admin = || Addr::unchecked("admin");

    let code_id_016 = app.store_code(cw721_base_016_contract());
    let code_id_017 = app.store_code(cw721_base_contract());

    let cw721 = app
        .instantiate_contract(
            code_id_016,
            admin(),
            &v16::InstantiateMsg {
                name: "collection".to_string(),
                symbol: "symbol".to_string(),
                minter: admin().into_string(),
            },
            &[],
            "cw721-base",
            Some(admin().into_string()),
        )
        .unwrap();

    let owner = admin();
    let token_id = "1".to_string();
    let owners = vec![admin(), Addr::unchecked("user1"), Addr::unchecked("user2")];
    let token_ids = vec!["1".to_string(), "2".to_string(), "3".to_string()];

    // Mint a token with JSON extension
    let extension_json = r#"
    {
        "animation_url": null,
        "attributes": [
            {
                "trait_type": "color",
                "value": "gray"
            },
            {
                "trait_type": "ship name",
                "value": "HMS_ENCORE"
            },
            {
                "trait_type": "background color",
                "value": "yellow"
            }
        ],
        "description": "SparrowSwap April OG RUM collection",
        "external_url": "https://gateway.pinata.cloud/ipfs/QmRy4vEkXY4tVPzSt8fVPio4cuDhMVG8V651GLtBSK7ie3",
        "image": "https://gateway.pinata.cloud/ipfs/QmRy4vEkXY4tVPzSt8fVPio4cuDhMVG8V651GLtBSK7ie3",
        "name": "SparrowSwap April OG RUM",
        "youtube_url": null
    }
    "#;

    let extension: Extension = serde_json::from_str(extension_json).unwrap();

    mint_batch_transfer_and_burn(
        &mut app,
        cw721.clone(),
        admin(),
        owners.clone(),
        token_ids.clone(),
        extension.clone(),
    );

    // Query all_nft_info for token_id "1"
    let result= app
        .wrap()
        .query_wasm_smart(
            &cw721,
            &crate::QueryMsg::<Extension>::AllNftInfo {
                token_id: token_id.clone(),
                include_expired: Some(true),
            },
        );
    let all_nft_info: AllNftInfoResponse<Extension> = result.unwrap();

    // Assert owner is correct
    assert_eq!(all_nft_info.access.owner, owner.to_string());

    // Assert token_uri is None
    assert!(all_nft_info.info.token_uri.is_none());


    // Assert extension matches the provided JSON
    assert_eq!(all_nft_info.info.extension, extension.clone());
}
