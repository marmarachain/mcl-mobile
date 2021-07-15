Map commands = {
  "getinfo": "-ac_name=MCL getinfo",
  "getaddressesbyaccount": '-ac_name=MCL getaddressesbyaccount ""',
  "validateaddress": "-ac_name=MCL validateaddress",
  "marmarainfo": "-ac_name=MCL marmarainfo 0 0 0 0",
  "marmaraholderloops": "-ac_name=MCL marmaraholderloops",
  "marmaracreditloop": "-ac_name=MCL marmaracreditloop  ",
  "marmaraunlock": "-ac_name=MCL marmaraunlock",
  "sendrawtransaction": "-ac_name=MCL sendrawtransaction",
  "marmaralock": "-ac_name=MCL marmaralock",
  "sendtoaddress": "-ac_name=MCL sendtoaddress",
  // Yeni cüzdan adresi alma komutları; 1-getnewaddress ile yeni adres alınır, 2-dumprivkey ile private alınır, 3-validateaddress ile de kontrol edilir
  "getnewaddress": "-ac_name=MCL getnewaddress",
  // -ac_name=MCL dumpprivkey WALLETADDRESS
  "dumpprivkey": "-ac_name=MCL dumpprivkey",
  // -ac_name=MCL validateaddress WALLETADDRESS
  // "validateaddress": "-ac_name=MCL validateaddress",
  // Zincir-Private Key Ekle: -ac_name=MCL importprivkey PRIVATEKEY
  "importprivkey": "-ac_name=MCL importprivkey",
  "convertpassphrase": "-ac_name=MCL convertpassphrase",
  // Kredi-Keşideci ilk döngü istekleri
  "marmarareceivelist": "-ac_name=MCL marmarareceivelist",
  // -ac_name=MCL marmarareceive PUBKEY 10 MARMARA 47228 '{"avalcount":"0"}'
  "marmarareceive": "-ac_name=MCL marmarareceive",
  "stop": "-ac_name=MCL stop",
  // komut sonunda = sonrası PUBKEY gelecek
  "start":
      "~/komodo/src/komodod -ac_name=MCL -ac_supply=2000000 -ac_cc=2 -addnode=37.148.210.158 -addnode=37.148.212.36 -addnode=46.4.238.65 -addressindex=1 -spentindex=1 -ac_marmara=1 -ac_staked=75 -ac_reward=3000000000 -gen -genproclimit=0 -pubkey=",
  "getgenerate": "-ac_name=MCL getgenerate",
  "setgenerate0t": "-ac_name=MCL setgenerate true 0",
  "setgenerate0f": "-ac_name=MCL setgenerate false 0",
  "setgenerate1": "-ac_name=MCL setgenerate true -1",
  "": "-ac_name=MCL listaddressgroupings",
  "addnode":
      "~/komodo/src/komodod -ac_name=MCL -ac_supply=2000000 -ac_cc=2 -addnode=37.148.210.158 -addnode=37.148.212.36 -addnode=149.202.158.145 -addressindex=1 -spentindex=1 -ac_marmara=1 -ac_staked=75 -ac_reward=3000000000 &",
  "marmaraissue": '''-ac_name=MCL marmaraissue'''
};

// Zinciri başlatmak isitiyor musunuz? Bu işlem biraz uzun sürebilir.

// '{"avalcount":"0", "autosettlement":"true", "autoinsurance":"true", "disputeexpires":"0", "EscrowOn":"false", "BlockageAmount":"0" }'
