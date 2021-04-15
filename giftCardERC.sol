pragma solidity >=0.6.0 <0.8.1;
import "../.deps/github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract newgift is ERC1155{
   
    string private _symbol;
    string private  _name;
   constructor() public ERC1155("") {
        // add varible need to set while cotract run
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
        // _balances[_cardId][_beneficiary]=_value;
        _mint(_beneficiary, _cardId, _value, "");
        reward memory newReward= reward(_value*1/100,block.timestamp, block.timestamp + 500 days);
        rewards[_beneficiary] = newReward;
        _cardId++;
    }
    
     function transferGiftCardTo(uint _cardId, address _newBeneficiary) public exist(_cardId) onlyOwner (_cardId) notNull(_newBeneficiary) expire(_cardId) {
       // Make change to safeTransferFrom funcation in ERC 1155  to remove (bytes memory data)
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
        //  _balances[_cardId][msg.sender]+=_amount;
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
 }
