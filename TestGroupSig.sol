// TestGroupSig.sol
pragma solidity ^0.4.24;
import "./GroupSigPrecompiled.sol";

contract TestGroupSig {
    GroupSigPrecompiled groupSig;
    function TestGroupSig()
    {
        // 实例化GroupSigPrecompiled合约
       groupSig = GroupSigPrecompiled(0x5004);
    }
    function verify(string signature, string message, string gpkInfo, string paramInfo) public constant returns(bool)
    {
        return groupSig.groupSigVerify(signature, message, gpkInfo, paramInfo);
    }
}
