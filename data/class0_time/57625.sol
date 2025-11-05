



pragma solidity ^0.4.8;

contract Dataset is OwnableOZ, IexecHubAccessor
{

	


	string            public m_datasetName;
	uint256           public m_datasetPrice;
	string            public m_datasetParams;

	


	function Dataset(
		address _iexecHubAddress,
		string  _datasetName,
		uint256 _datasetPrice,
		string  _datasetParams)
	IexecHubAccessor(_iexecHubAddress)
	public
	{
		
		
		require(tx.origin != msg.sender);
		setImmutableOwnership(tx.origin); 

		m_datasetName   = _datasetName;
		m_datasetPrice  = _datasetPrice;
		m_datasetParams = _datasetParams;

	}


}


pragma solidity ^0.4.21;


