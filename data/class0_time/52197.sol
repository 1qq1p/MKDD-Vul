



 
 pragma solidity 0.4.15;















contract InvestmentAnalytics {
    using SafeMath for uint256;

    function InvestmentAnalytics(){
    }

    
    function createMorePaymentChannelsInternal(uint limit) internal returns (uint) {
        uint paymentChannelsCreated;
        for (uint i = 0; i < limit; i++) {
            uint startingGas = msg.gas;
            




            address paymentChannel = new AnalyticProxy();
            m_validPaymentChannels[paymentChannel] = true;
            m_paymentChannels.push(paymentChannel);
            paymentChannelsCreated++;

            
            uint gasPerChannel = startingGas.sub(msg.gas);
            if (gasPerChannel.add(50000) > msg.gas)
                break;  
        }
        return paymentChannelsCreated;
    }


    
    function iaInvestedBy(address investor) external payable {
        address paymentChannel = msg.sender;
        if (m_validPaymentChannels[paymentChannel]) {
            
            uint value = msg.value;
            m_investmentsByPaymentChannel[paymentChannel] = m_investmentsByPaymentChannel[paymentChannel].add(value);
            
            iaOnInvested(investor, value, true);
        } else {
            
            
            iaOnInvested(msg.sender, msg.value, false);
        }
    }

    
    function iaOnInvested(address , uint , bool ) internal {
    }


    function paymentChannelsCount() external constant returns (uint) {
        return m_paymentChannels.length;
    }

    function readAnalyticsMap() external constant returns (address[], uint[]) {
        address[] memory keys = new address[](m_paymentChannels.length);
        uint[] memory values = new uint[](m_paymentChannels.length);

        for (uint i = 0; i < m_paymentChannels.length; i++) {
            address key = m_paymentChannels[i];
            keys[i] = key;
            values[i] = m_investmentsByPaymentChannel[key];
        }

        return (keys, values);
    }

    function readPaymentChannels() external constant returns (address[]) {
        return m_paymentChannels;
    }


    mapping(address => uint256) public m_investmentsByPaymentChannel;
    mapping(address => bool) m_validPaymentChannels;

    address[] public m_paymentChannels;
}












