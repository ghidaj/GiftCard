pragma solidity >=0.6.0 <0.8.4;
pragma abicoder v2;

contract GiftCard{
    
   string private _symbol;
   string private  _name;
   constructor() public{
        _name = "Bravo";
        _symbol = "BRV";
    }
    
    struct Card {
        uint value;
        uint issueDate;
        uint ExpireDate;
        address beneficiary;
        address generatedBy;
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
    modifier onlyOwner (uint _cardId) {
        require(msg.sender == cards[_cardId].beneficiary, "you are not the Owner" );
      _;
     }
    modifier notNull(address _address) {
        require(_address != address(0),"The address is Empty");
        _;
    }
    modifier exist(uint _cardId) {
        require(cards[_cardId].beneficiary !=  address(0) ,"The card ID does Not Exist");
        _;
    }
    modifier expire(uint _cardId) {
        require(cards[_cardId].ExpireDate > block.timestamp ,"The card is Expire");
        _;
    }
    
    function GiftCardbBuyFee(address _beneficiary, uint total) public payable notNull(_beneficiary){
        //Need to calc fees and total in the website
        require(total> 0 , "The amount should be greater than 0" );
        require(total< 10000, "The amount should less than 10000" );
        require(total == msg.value, "Check your balance");
        uint _value = total - (total*2/100);
        issueGiftCard(_beneficiary, _value);
    }
    
    function issueGiftCard(address _beneficiary,uint _value) private {
        Card memory newCard = Card (_value, block.timestamp, block.timestamp + 365 days, _beneficiary,msg.sender);
        cards[_cardId] = newCard;
        _mint(_beneficiary, _cardId, _value, "");
        reward memory newReward= reward(_value*1/100,block.timestamp, block.timestamp + 500 days);
        rewards[_beneficiary] = newReward;
        _cardId++;
    }
    
    function transferGiftCardTo(uint _cardId, address _newBeneficiary) public exist(_cardId) onlyOwner (_cardId) notNull(_newBeneficiary) expire(_cardId) {
         safeTransferFrom (msg.sender,_newBeneficiary,_cardId, cards[_cardId].value,"");
         cards[_cardId].beneficiary = _newBeneficiary;
    }
     
    function GiftCardAddFee(uint _cardId, uint _amount) public payable exist(_cardId) onlyOwner (_cardId) expire(_cardId){
        //Need to calc fees and total in the website
        require(_amount == msg.value, "Check your balance");
        uint _value = _amount - (_amount*2/100);
        addFundsToGiftCard( _cardId,  _value);
    }
    
    function addFundsToGiftCard(uint _cardId, uint _amount) private {
         cards[_cardId].value+=_amount;
         _mint(msg.sender, _cardId, _amount, "");
         rewards[msg.sender].points=_amount*1/100;
    }
    
    function withdrawMerchantBalance( uint _cardId, uint _amount ) public exist(_cardId) onlyOwner (_cardId) expire(_cardId) {
        require(_amount <=  cards[_cardId].value, "Check your balance");
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
         //****Need to show the customer the reward card****
        Card memory newCard = Card (_value, block.timestamp, block.timestamp + 365 days, _beneficiary,msg.sender);
        cards[_cardId] = newCard;
        _mint(_beneficiary, _cardId, _value, "");
        _cardId++;
    }
    
    Card [] public  mycards ;

function myCards() public returns (Card [] memory) {
         for (uint i=0; i< 10 ; i++ ){
         if(cards[i].beneficiary==msg.sender){
         mycards.push(cards[i]);
             }
         }
         return mycards;
    }
  
 //////// **************ERC1155 function ************************
 
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal  {
        require(account != address(0), "ERC1155: mint to the zero address");
        address operator = msg.sender;
        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);
        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);
    }
    
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(from == msg.sender || isApprovedForAll(from, msg.sender),"ERC1155: caller is not owner nor approved");
        address operator = msg.sender;
        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);
        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;
        emit TransferSingle(operator, from, to, id, amount);
    }
    
    function _burn(address account, uint256 id, uint256 amount) internal {
        require(account != address(0), "ERC1155: burn from the zero address");
        address operator = msg.sender;
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
    
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }
    


     
}