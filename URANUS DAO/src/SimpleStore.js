
import React, {useState} from ' react'
import {ethers} from 'ethers';
import SimpleStore_abi from './SimpleStore_abi.json';

const SimpleStore = () => {

    const contractAddress = '0xf467157e04F4C1DD9017be206b205601d003b904';
    
     const [errorMessage, setErrorMessage] = useState(null);
    const [defaultAccount, setDefaultAccount] = useState(null);
    const [connectButtonText, setConnButtonText] = useState('Connect Wallet');

    const [currentContractVal, setCurrentContractVal] = useState(null);

    const [provider, setProvider] = useState(null);
    const [signer, setSigner] = useState(null);
    const [contract, setContract] = useState(null);

    const connectWalletHandler = () => {
        if(window.ethereum) {
           window.ethereum.request({method: 'eth_requestAccounts'})
           .then(result => {
               accountChangeHandler(result[0]);
               setConnButtonText('Wallet Connected');
           })
        } else {
            setErrorMessage('Need to install MetaMask!');
        }
    }

    const accountChangeHandler = (newAccount) => {
        setDefaultAccount(newAccount)
        updateEthers();
    }

    const updateEthers = () => {
        let tempProvider = new ethers.providers.Web3Provider(window.ethereum);
        setProvider(tempProvider);

        let tempSigner = tempProvider.getSigner();
        setSigner(tempSigner);

        let tempContract = new ethers.Contract(contractAddress, SimpleStore_abi, tempSigner);
        setContract(tempContract);
    }

const getCurrentVal = async () => {
    let val = await contract.get();
    setCurrentContractVal(val);
}

const setHandler = (event) => {
    event.PreventDefault();
    contract.set(event.target.setText.value);

}

    return (
        <div>
            <h3> {"Get/Set Interaction with contract!"} </h3>import
            <button onClick={connectWalletHandler}> {connectButtonText}</button>
            <h3> Address:{defaultAccount} </h3>

            <form onSubmit={setHandler}>
                <input id='setText' type='text'/>
                <button type={"submit"}> Update Contract </button>
            </form>

       <button onClick={getCurrentVal}> Get Current Value </button>
       {currentContractVal}
        {errorMessage}
        </div>
        )

}

export default SimpleStore;