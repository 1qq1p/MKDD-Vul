pragma solidity ^0.4.24;






contract Enlist {
  struct Record {
    address investor;
    bytes32 _type;
  }

  Record[] records;

  function setRecord (
    address _investor,
    bytes32 _type
  ) internal {
    records.push(Record(_investor, _type));
  }

  function getRecordCount () constant
  public
  returns (uint) {
    return records.length;
  }

  function getRecord (uint index) view
  public
  returns (address, bytes32) {
    return (
      records[index].investor,
      records[index]._type
    );
  }
}




