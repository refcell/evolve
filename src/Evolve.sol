// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/////////////////////////////////////////////////////////
///                                                   ///
///                 ,,ggddY888Ybbgg,,                 ///
///            ,agd8""'   .d8888888888bga,            ///
///         ,gdP""'     .d88888888888888888g,         ///
///       ,dP"        ,d888888888888888888888b,       ///
///     ,dP"         ,8888888888888888888888888b,     ///
///    ,8"          ,88888888P""88888888888888888,    ///
///   ,8'           I8888888(    )8888888888888888,   ///
///  ,8'            `88888888booo888888888888888888,  ///
///  d'              `88888888888888888888888888888b  ///
///  8                `"8888888888888888888888888888  ///
///  8                  `"88888888888888888888888888  ///
///  8                      `"8888888888888888888888  ///
///  Y,                        `8888888888888888888P  ///
///  `8,                         `88888888888888888'  ///
///   `8,              .oo.       `888888888888888'   ///
///    `8a            (8888)       88888888888888'    ///
///     `Yba           `""'       ,888888888888P'     ///
///       "Yba                   ,88888888888'        ///
///         `"Yba,             ,8888888888P"'         ///
///            `"Y8baa,      ,d88888888P"'            ///
///                 ``""YYba8888P888"'                ///
///                                                   ///
/////////////////////////////////////////////////////////

/// @title Evolve
/// @author andreas@nascent.xyz
contract Evolve is ERC20 {

  /// :::::::::::::::::::::::  ERRORS  ::::::::::::::::::::::: ///

  /// @notice Not enough tokens left to mint
  error InsufficientTokens();

  /// @notice Caller is not the contract owner
  error Unauthorized();

  /// @notice Thrown if the address has minted their available capacity
  error MintCapacityReached();

  /// :::::::::::::::::::::  IMMUTABLES  :::::::::::::::::::: ///

  /// @notice The maximum number of nfts to mint
  uint256 public immutable MAXIMUM_SUPPLY;

  /// @notice The Contract Warden
  address public immutable warden;

  /// ::::::::::::::::::::::  STORAGE  :::::::::::::::::::::: ///

  /// @notice Maps addresses to amount of tokens it can mint
  mapping(address => uint256) public mintable;

  /// @notice Maps addresses to amount of tokens it has minted
  mapping(address => uint256) public minted;

  /// :::::::::::::::::::::  CONSTRUCTOR  ::::::::::::::::::::: ///

  constructor() ERC20("Evolve", "VOLV", 0) {
    warden = msg.sender;
    MAXIMUM_SUPPLY = 1_000_000_000;
  }

  /// ::::::::::::::::::::::  MODIFIERS  :::::::::::::::::::::: ///

  modifier canMint() {
    if (mintable[msg.sender] - minted[msg.sender] == 0) {
      revert MintCapacityReached();
    }
    _;
  }

  modifier onlyWarden() {
    if (msg.sender != warden) {
      revert Unauthorized();
    }
    _;
  }

  /// :::::::::::::::::::::::  MINTING  ::::::::::::::::::::::: ///

  function mint(address to, uint256 value) public virtual canMint {
    minted[msg.sender] += value;
    _mint(to, value);
  }

  /// ::::::::::::::::::::::  PRIVILEGED  :::::::::::::::::::::: ///

  function setMintable(address minter, uint256 amount) public onlyWarden {
    mintable[minter] = amount;
  }
}
