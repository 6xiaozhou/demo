// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.25;

contract testbytestostring {
    
//     function bytes32ToString(bytes32 x) public pure returns (string) {
//     bytes memory bytesString = new bytes(32);
//     uint charCount = 0;
//     for (uint j = 0; j < 32; j++) {
//         byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
//         if (char != 0) {
//             bytesString[charCount] = char;
//             charCount++;
//         }
//     }
//     bytes memory bytesStringTrimmed = new bytes(charCount);
//     for (j = 0; j < charCount; j++) {
//         bytesStringTrimmed[j] = bytesString[j];
//     }
//     return string(bytesStringTrimmed);
// }
    // function bytes32ToString(bytes32 x) public pure returns (string){
    //     string memory bar = string(abi.encodePacked(x));
    //     return bar;
    // }
    // function bytes32ToStr(bytes32 _bytes32) public pure returns (string) {

    // // string memory str = string(_bytes32);
    // // TypeError: Explicit type conversion not allowed from "bytes32" to "string storage pointer"
    // // thus we should fist convert bytes32 to bytes (to dynamically-sized byte array)

    // // bytes memory bytesArray = new bytes(32);
    // // for (uint256 i; i < 32; i++) {
    // //     bytesArray[i] = _bytes32[i];
    // //     }
    // // return string(bytesArray);

    // }
    // function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
    //     uint8 i = 0;
    //     while(i < 32 && _bytes32[i] != 0) {
    //         i++;
    //     }
    //     bytes memory bytesArray = new bytes(i);
    //     for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
    //         bytesArray[i] = _bytes32[i];
    //     }
    //     return string(bytesArray);
    // }
    // function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
    // uint8 i = 0;
    // bytes memory bytesArray = new bytes(64);
    // for (i = 0; i < bytesArray.length; i++) {

    //     uint8 _f = uint8(_bytes32[i/2] & 0x0f);
    //     uint8 _l = uint8(_bytes32[i/2] >> 4);

    //     bytesArray[i] = toByte(_f);
    //     i = i + 1;
    //     bytesArray[i] = toByte(_l);
    // }
    // return string(bytesArray);
    // }
    // function toByte(uint8 _uint8) public pure returns (byte) {
    //     if(_uint8 < 10) {
    //         return byte(_uint8 + 48);
    //     } else {
    //         return byte(_uint8 + 87);
    //     }
    // }
    function toHex16 (bytes16 data) internal pure returns (bytes32 result) {
        result = bytes32 (data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000 |
          (bytes32 (data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64;
        result = result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000 |
          (result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32;
        result = result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000 |
          (result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16;
        result = result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000 |
          (result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8;
        result = (result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4 |
          (result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8;
        result = bytes32 (0x3030303030303030303030303030303030303030303030303030303030303030 +
           uint256 (result) +
           (uint256 (result) + 0x0606060606060606060606060606060606060606060606060606060606060606 >> 4 &
           0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) * 7);
    }
    function toHex (bytes32 data) public pure returns (string memory) {
        return string (abi.encodePacked ("0x", toHex16 (bytes16 (data)), toHex16 (bytes16 (data << 128))));
    }
    function twobytes(bytes32 data,bytes32 data1) public  returns (string memory){
        string memory s1 = string (abi.encodePacked ("0x", toHex16 (bytes16 (data)), toHex16 (bytes16 (data << 128))));
        string memory s2 = string (abi.encodePacked ("0x", toHex16 (bytes16 (data1)), toHex16 (bytes16 (data1 << 128))));
        string memory s3 = strConcat(s1,s2);
        return s3;
    }
    function strConcat(string _a, string _b) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
   }  

}
