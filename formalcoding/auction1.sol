//auction.sol
pragma solidity ^0.4.24;

import "./GroupSigPrecompiled.sol";

contract auction {
    struct auctionInfo{//拍卖公共信息
        bytes32 auctionID;
        uint startTime;
        uint endTime;
        string groupPubKey;
        string pbc_param;
        string goodInfo;
        uint timestamp;
        address auctioneerAddre;
    }
    struct bid{//投标
        bytes32 bidID;
        bytes32 auctionID;
        bytes32 C;//投标承诺
        uint bidTime;//投标的时间
        string groupSig;
    }

    struct open{//开标
        bytes32 bidID;
        string price;
        string random;
        //string groupSig;
    }

    struct successBidder {//中标
        bytes32 bidID;
        string price;
        string random;
        address bidder;
        string proofOfId;
    }
    
    mapping(bytes32 => auctionInfo)  auctionList;
    mapping(bytes32 => bid)  bidList;
    mapping(bytes32 => open) opened;
    mapping(bytes32 => bool)  isAuctionExit;
    mapping(bytes32 => bool)  isBidExit;
    mapping(bytes32 => successBidder) auctionResult;
    GroupSigPrecompiled groupSig;
    function auction()
    {
        // 实例化GroupSigPrecompiled合约
        groupSig = GroupSigPrecompiled(0x5004);
    }
    //拍卖消息发布函数
    function auctionPublish (uint sT,uint eT,string gpk,string pbc_param,string goodI)  public returns(string){
        uint t = now;//获取当前时间戳
        bytes32 ID =  keccak256(abi.encodePacked(sT,eT,gpk,goodI,t));//使用哈希函数生成拍卖场次标识
	//新建拍卖信息对象
        auctionInfo memory auctionIn = auctionInfo(ID, sT, eT, gpk,pbc_param,goodI,t, msg.sender);
        auctionList[ID] = auctionIn;//讲对象保存于拍卖列表中
        isAuctionExit[ID] = true;
        return toHex(ID);//返回拍卖标识
    }
    // function verify(string signature, string message, string gpkInfo, string paramInfo) public constant returns(bool)
    // {
    //     return groupSig.groupSigVerify(signature, message, gpkInfo, paramInfo);
    // }
    //投标函数   传入拍卖标识，承诺值，群签名，返回投标标识
    function bidding (bytes32 auctionID, bytes32 commit, string gs) public returns(string ){
    	//  通过拍卖标识查询拍卖是否存在
        if(isAuctionExit[auctionID] == false){
            return "auction not exit!";
        }
        auctionInfo memory auc  = auctionList[auctionID];
        uint time = now;//获取当前时间戳
	//判断投标时间是否在规定时间之内
        if(time <auc.startTime ||time >auc.endTime) {
            return "time illegal!";
        }
	//将拍卖标识转换为字符串
        string memory strauctionID = toHex(auctionID);
        string memory strcommit = toHex(commit);
	//得到待签名信息
        string memory message = strConcat(strauctionID,strcommit);
        string memory pk = auc.groupPubKey;
        string memory pubparam = auc.pbc_param;
	//调用签名验证函数验证群签名是否合法
        if(groupSig.groupSigVerify(gs,message,pk,pubparam)){
		bytes32 ID = keccak256(abi.encodePacked(auctionID,commit,time));
        	bid memory b = bid(ID,auctionID, commit, time,gs);
        	bidList[ID] = b;
        	isBidExit[ID] = true;
        	return toHex(ID);
        }
        return "GroupSignature verify error!";
    }
//开标
    function openBid(bytes32 bidID , string price, string random) public returns(bool){
        bytes32 c = keccak256(abi.encodePacked(price,random));//计算出价承诺
        bid memory b = bidList[bidID];
        if ( isBidExit[bidID] == false || b.C != c) {//验证是否诚实公开出价
            return false;
        }
        open memory o = open(bidID,price,random);
        opened[bidID] = o;//保存开标消息
        return true;
    }
    //拍卖结果发布
    function auctionResultPublic(string price,string random ,bytes32 bID, address add,string prof) public returns(bool){//公布中标结果
        if(isBidExit[bID] == false){//判断投标是否存在
            return false;
        }
        bid storage b = bidList[bID];
        if(b.C == keccak256(abi.encodePacked(price,random))) {//判断中标价格的真实性
            successBidder memory success = successBidder(bID,price,random,add,prof);
            auctionResult[b.auctionID] = success;//将中标结果保存至合约中
            return  true;
        }
    }
    
    function getAuctionResult ( bytes32 id) public  returns (string,string,string, address) {
        return (toHex(auctionResult[id].bidID),auctionResult[id].price,auctionResult[id].random,auctionResult[id].bidder);
    }

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
   function isExit(bytes32 b) public returns(bool) {
       return isAuctionExit[b];
   }
   function getTime() public returns(uint) {
       uint t = now;
       return t;
   }
}
