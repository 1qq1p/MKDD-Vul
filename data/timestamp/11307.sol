

pragma solidity ^0.4.25;



contract AddressIteratorInteractive {

  









  function list_addresses(uint256 _count,
                                 function () external constant returns (address) _function_first,
                                 function () external constant returns (address) _function_last,
                                 function (address) external constant returns (address) _function_next,
                                 function (address) external constant returns (address) _function_previous,
                                 bool _from_start)
           internal
           constant
           returns (address[] _address_items)
  {
    if (_from_start) {
      _address_items = private_list_addresses_from_address(_function_first(), _count, true, _function_last, _function_next);
    } else {
      _address_items = private_list_addresses_from_address(_function_last(), _count, true, _function_first, _function_previous);
    }
  }



  










  function list_addresses_from(address _current_item, uint256 _count,
                                function () external constant returns (address) _function_first,
                                function () external constant returns (address) _function_last,
                                function (address) external constant returns (address) _function_next,
                                function (address) external constant returns (address) _function_previous,
                                bool _from_start)
           internal
           constant
           returns (address[] _address_items)
  {
    if (_from_start) {
      _address_items = private_list_addresses_from_address(_current_item, _count, false, _function_last, _function_next);
    } else {
      _address_items = private_list_addresses_from_address(_current_item, _count, false, _function_first, _function_previous);
    }
  }


  








  function private_list_addresses_from_address(address _current_item, uint256 _count, bool _including_current,
                                 function () external constant returns (address) _function_last,
                                 function (address) external constant returns (address) _function_next)
           private
           constant
           returns (address[] _address_items)
  {
    uint256 _i;
    uint256 _real_count = 0;
    address _last_item;

    _last_item = _function_last();
    if (_count == 0 || _last_item == address(0x0)) {
      _address_items = new address[](0);
    } else {
      address[] memory _items_temp = new address[](_count);
      address _this_item;
      if (_including_current == true) {
        _items_temp[0] = _current_item;
        _real_count = 1;
      }
      _this_item = _current_item;
      for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {
        _this_item = _function_next(_this_item);
        if (_this_item != address(0x0)) {
          _real_count++;
          _items_temp[_i] = _this_item;
        }
      }

      _address_items = new address[](_real_count);
      for(_i = 0;_i < _real_count;_i++) {
        _address_items[_i] = _items_temp[_i];
      }
    }
  }


  







  


































  







  












































}


pragma solidity ^0.4.19;



