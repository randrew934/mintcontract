// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/common/ERC2981.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract NFTMint is ERC721Enumerable, ERC2981, Ownable{
    using Strings for uint256;

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    uint256 public mintPrice = 0.08 ether;
    uint256 public whitelistPrice = 0.04 ether;
    uint256 public maxSupply;
    string private currentBaseURI;
    uint256 public maxMintAmount = 1;
    bool public isMintEnabled;
    bool public revealNFT;
    string private contractURI;
    string public baseExtension = ".json";
    mapping(address => uint256) public mintedWallets;
    mapping(address => bool) public whitelisted;

    constructor(string memory _initBaseURI) payable ERC721("UHURUTEST MINT", "UHURUTEST"){
        maxSupply = 2;
        setBaseURI(_initBaseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return currentBaseURI;
    }
 

  function setMintCost(uint256 _newCost) public onlyOwner {
    mintPrice = _newCost;
  }

  function setWhiteListCost(uint256 _newCost) public onlyOwner {
    whitelistPrice = _newCost;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    currentBaseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function toggleIsMintEnabled() external onlyOwner{
    isMintEnabled = !isMintEnabled;
  }

  function setMaxSupply(uint256 _maxSupply) external onlyOwner{
    maxSupply =  _maxSupply;    
  }

    
  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function supportsInterface(bytes4 interfaceId) 
  public 
  view 
  override(ERC2981, ERC721Enumerable) returns (bool) {
    return
    super.supportsInterface(interfaceId);
  }

  function setRevealNFT(bool reveal) public onlyOwner{
    revealNFT = reveal;
  }

    
  function tokenURI(uint256 tokenId)
  public
  view
  virtual
  override
  returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory BaseURI = _baseURI();

    if(revealNFT){
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(BaseURI, tokenId.toString(), baseExtension))
        : "";
    }else{
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(BaseURI, "hidden.json"))
        : "";
    }

  }

  function walletOfOwner(address _owner)
  public
  view
  returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function setContractURI(string calldata _contractURI) public onlyOwner{
    contractURI = _contractURI;
  }


  function mintSupply(uint256 _mintAmount) external payable{
    require(isMintEnabled, "Minting Not Enabled");
    require(maxSupply > totalSupply(), "Sold Out");

    uint256 tokenId = totalSupply();

    if (msg.sender != owner()) {
        require((mintedWallets[msg.sender] + _mintAmount) < maxMintAmount, "Exceeds Max Per Wallet");
        if(whitelisted[msg.sender] != true) {
        require(msg.value == mintPrice * _mintAmount, "Wrong Value Entered");
        } else{
        require(msg.value == whitelistPrice * _mintAmount, "Wrong Value Entered");
        }
    }
    
    for (uint256 i = 1; i <= _mintAmount; i++) {
        mintedWallets[msg.sender]++;
        _safeMint(msg.sender, tokenId + i);
    }
  }

  function whitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = true;
  }
    
  function removeWhitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = false;
  }

  function withdraw() public payable onlyOwner {
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
  }

  function resetDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner{
        _setDefaultRoyalty(receiver, feeNumerator);
  }


         
  function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner{
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
  }


  function resetTokenRoyalty(uint256 tokenId) public onlyOwner {
        _resetTokenRoyalty(tokenId);
  }



}