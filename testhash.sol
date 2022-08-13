pragma solidity ^0.4.24;

contract testhash {
    function test(string x,string r) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(x,r));
    }
}
