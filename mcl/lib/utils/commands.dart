Map commands = {
  "getinfo": "komodo-cli -ac_name=MCL getinfo",
  "getaddressesbyaccount": 'komodo-cli -ac_name=MCL getaddressesbyaccount ""',
  "validateaddress": "komodo-cli -ac_name=MCL validateaddress",
  "marmarainfo": "komodo-cli -ac_name=MCL marmarainfo 0 0 0 0",
  "marmaraholderloops": "komodo-cli -ac_name=MCL marmaraholderloops",
  "marmaracreditloop": "komodo-cli -ac_name=MCL marmaracreditloop  ",
  "marmaraunlock": "komodo-cli -ac_name=MCL marmaraunlock",
  "sendrawtransaction": "komodo-cli -ac_name=MCL sendrawtransaction",
  "marmaralock": "komodo-cli -ac_name=MCL marmaralock",
  "sendtoaddress": "komodo-cli -ac_name=MCL sendtoaddress",
  // Yeni cüzdan adresi alma komutları; 1-getnewaddress ile yeni adres alınır, 2-dumprivkey ile private alınır, 3-validateaddress ile de kontrol edilir
  "getnewaddress": "komodo-cli -ac_name=MCL getnewaddress",
  // komodo-cli -ac_name=MCL dumpprivkey WALLETADDRESS
  "dumpprivkey": "komodo-cli -ac_name=MCL dumpprivkey",
  // komodo-cli -ac_name=MCL validateaddress WALLETADDRESS
  // "validateaddress": "komodo-cli -ac_name=MCL validateaddress",
  // Zincir-Private Key Ekle: komodo-cli -ac_name=MCL importprivkey PRIVATEKEY
  "importprivkey": "komodo-cli -ac_name=MCL importprivkey",
  "convertpassphrase": "komodo-cli -ac_name=MCL convertpassphrase",
  // Kredi-Keşideci ilk döngü istekleri
  "marmarareceivelist": "komodo-cli -ac_name=MCL marmarareceivelist",
  // komodo-cli -ac_name=MCL marmarareceive PUBKEY 10 MARMARA 47228 '{"avalcount":"0"}'
  "marmarareceive": "komodo-cli -ac_name=MCL marmarareceive",
  "stop": "komodo-cli -ac_name=MCL stop",
  // komut sonunda = sonrası PUBKEY gelecek
  "start":
      "komodod -ac_name=MCL -ac_supply=2000000 -ac_cc=2 -addnode=37.148.210.158 -addnode=37.148.212.36 -addnode=46.4.238.65 -addressindex=1 -spentindex=1 -ac_marmara=1 -ac_staked=75 -ac_reward=3000000000 -gen -genproclimit=0 -pubkey=",
  "getgenerate": "komodo-cli -ac_name=MCL getgenerate",
  "setgenerate0t": "komodo-cli -ac_name=MCL setgenerate true 0",
  "setgenerate0f": "komodo-cli -ac_name=MCL setgenerate false 0",
  "setgenerate1": "komodo-cli -ac_name=MCL setgenerate true -1",
  "": "komodo-cli -ac_name=MCL listaddressgroupings",
  "addnode":
      "komodod -ac_name=MCL -ac_supply=2000000 -ac_cc=2 -addnode=37.148.210.158 -addnode=37.148.212.36 -addnode=149.202.158.145 -addressindex=1 -spentindex=1 -ac_marmara=1 -ac_staked=75 -ac_reward=3000000000 &",
  "marmaraissue": '''komodo-cli -ac_name=MCL marmaraissue''',
  "listtransactions": 'komodo-cli -ac_name=MCL listtransactions "*"'
};

// Zinciri başlatmak isitiyor musunuz? Bu işlem biraz uzun sürebilir.

// '{"avalcount":"0", "autosettlement":"true", "autoinsurance":"true", "disputeexpires":"0", "EscrowOn":"false", "BlockageAmount":"0" }'
