pragma solidity >=0.6.0 <0.8.1;

// import "../.deps/github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract gift {
    
    string private _symbol;
    string private  _name;
   constructor() public {
        // add varible need to set while cotract run
        _name = "Bravo";
        _symbol = "BRV";
    }
    
    
 struct Card {
        uint value;
        // uint balance;
        uint issueDate;
        uint ExpireDate;
        address beneficiary;
        address generatedBy;
        // bool rechargeable;
        // bool transfereable;
    }
    
    struct reward {
        uint points;
        uint issueDate;
        uint ExpireDate;
    }
    
    address owner;
    uint _cardId;
    mapping (uint => Card) public cards;
    mapping (address => reward) public rewards;
    mapping (uint256 => mapping(address => uint256)) private _balances;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }
    
    function buyGiftCard(address _beneficiary, uint total) public payable{
        //Need to calc fees and total in the website
        require(total == msg.value, "Check your balance");
        uint _value = total - (total*2/100);
        issueGiftCard(_beneficiary, _value);
    }
    
    function issueGiftCard(address _beneficiary,uint _value) private{
        // REQUIRE
        //REQUIRE for min&max value 
        // Generate randome number for the card ID
        Card memory newCard = Card (_value, block.timestamp, block.timestamp + 365 days, _beneficiary,msg.sender);
        cards[_cardId] = newCard;
        // _balances[_cardId][_beneficiary]=_value;
        _mint(_beneficiary, _cardId, _value, "");
        reward memory newReward= reward(_value*1/100,block.timestamp, block.timestamp + 500 days);
        rewards[_beneficiary] = newReward;
        _cardId++;

    }
    
     function transferGiftCardTo(uint _cardId, address _newBeneficiary) public {
       //  REQUIRE
       // Make change to safeTransferFrom funcation in ERC 1155  to remove (bytes memory data)
         safeTransferFrom (msg.sender,_newBeneficiary,_cardId, cards[_cardId].value,"");
         cards[_cardId].beneficiary = _newBeneficiary;
     }

     function addFundsToGiftCard(uint _cardId, uint _amount) public payable{
        //  calc fees *********
         //  REQUIRE Owner
         cards[_cardId].value+=_amount;
        //  _balances[_cardId][msg.sender]+=_amount;
         _mint(msg.sender, _cardId, _amount, "");
         rewards[msg.sender].points=_amount*1/100;
     }
     
    //   function usedGiftCard(uint _cardId, uint _amount) public returns (bool){
      
    //   }
    
     function withdrawMerchantBalance( uint _cardId, uint _amount ) public {
        // REQUIRE Gift card can only be used by the account it was issued to
        //  REQUIRE card must exist
        // REQUIRE Card must not have expire
        // REQUIRE Card should have enough funds to cover the purchase
        // remove value from card balance
         cards[_cardId].value-=_amount;
         _burn(msg.sender, _cardId, _amount);
     }
     // When need to be call????
      function Redeem(address rewardBeneficiary) public {
          uint limit=1;
          if (rewards[rewardBeneficiary].points >= limit){
           issueRewards(rewardBeneficiary,1);
          }
          
      }
      function issueRewards(address _beneficiary,uint _value) private  {
        // REQUIRE
        // Generate randome number for the card ID
        Card memory newCard = Card (_value, block.timestamp, block.timestamp + 365 days, _beneficiary,msg.sender);
        cards[_cardId] = newCard;
        // _balances[_cardId][_beneficiary]=_value;
        _mint(_beneficiary, _cardId, _value, "");
        _cardId++;
      //****Need to show the customer the reward card****
    }
       Card [] public  mycards ;
     function myCards() public returns (Card[] memory) {
        //  uint counter;
         for (uint i=0; i< 10 ; i++ ){
             if(cards[i].beneficiary==msg.sender){
                 mycards.push(cards[i]);
             }
         }
         return mycards;
     }
  
 ////////ERC function
     function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal  {
        require(account != address(0), "ERC1155: mint to the zero address");
        address operator = msg.sender;
        // address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }
        function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved");

        // address operator = _msgSender();
        address operator = msg.sender;


        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }
        function _burn(address account, uint256 id, uint256 amount) internal {
        require(account != address(0), "ERC1155: burn from the zero address");
        address operator = msg.sender;
        // address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        _balances[id][account] = accountBalance - amount;

        emit TransferSingle(operator, account, address(0), id, amount);
    }
        function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal{ 
            
        }
        
    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
     function _doSafeTransferAcceptanceCheck(address operator, address from, address to, uint256 id, uint256 amount, bytes memory data) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

     
}
