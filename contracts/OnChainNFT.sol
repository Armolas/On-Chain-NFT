// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

contract OnChainNFT is ERC721{
    string public token_name;
    string public token_symbol;

    uint256 private token_counter;
    mapping(address => uint256) private balance;
    mapping(uint256 => address) private token_owner;
    mapping(address => mapping(address => bool)) private operator_approval;
    mapping(uint256 => address) private approval;

    
    event Mint(address indexed _to, uint256 indexed _tokenId);

    constructor (string memory _token_name, string memory _token_symbol) ERC721(_token_name, _token_symbol) {
        token_name = _token_name;
        token_symbol = _token_symbol;
        mint();
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override{
        require(token_owner[_tokenId] == _from, "Not token owner!");
        require(_from == msg.sender || approval[_tokenId] == msg.sender || operator_approval[_from][msg.sender], "Not Authorized");
        token_owner[_tokenId] = _to;
        balance[_from] -= 1;
        balance[_to] += 1;
        emit Transfer(_from, _to, _tokenId);
    }



    function approve(address _approved, uint256 _tokenId) public override{
        require(token_owner[_tokenId] == msg.sender, "Not token owner");
        approval[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public override{
        operator_approval[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public override view returns (address){
        return approval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view override returns (bool){
        return operator_approval[_owner][_operator];
    }

    function mint() public{
        _safeMint(msg.sender, token_counter);
        token_counter += 1;
    }

    function getRandomColor(uint256 tokenId) internal pure returns (string memory) {
        string[5] memory colors = ["red", "blue", "green", "purple", "orange"];
        return colors[tokenId % colors.length]; // Selects a color based on token ID
    }

    function generateSVG(uint256 tokenId) internal pure returns (string memory) {
        string memory color1 = getRandomColor(tokenId);
        string memory color2 = getRandomColor(tokenId + 1);
        string memory cx = Strings.toString((tokenId * 30) % 400);
        string memory cy = Strings.toString((tokenId * 50) % 400);
        string memory r = Strings.toString((tokenId * 10) % 50 + 20);

        return string(
            abi.encodePacked(
                '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
                '<rect width="100%" height="100%" fill="black"/>',
                '<circle cx="', cx, '" cy="', cy, '" r="', r, '" fill="', color1, '"/>',
                '<circle cx="', cy, '" cy="', cx, '" r="', r, '" fill="', color2, '"/>',
                '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="white" font-size="24">',
                'Armolas NFT #', Strings.toString(tokenId), '</text></svg>'
            )
        );
    }

    function tokenURI(uint256 tokenId) public override pure returns (string memory) {
        string memory svg = generateSVG(tokenId);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Dynamic SVG NFT #', Strings.toString(tokenId),
                        '", "description": "Olasunkanmi on-chain NFT", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)), '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}