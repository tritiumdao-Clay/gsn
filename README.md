
### responsibility

paymyster负责手续费, deposit, withdraw(简单每一笔都收取手续费)
relayserve: receiveRequest(request. signature)，调用relayhub
relayhub: relaycall() 与paymyster交互手续费计算，调用forward，
forward: address=>nonce管理, 允许的操作管理，调用相关操作
receipient: 合约接受地址erc1155

### defender.openzepplin

- relay
  - eth address : 0xec228bf45739b183a40a05024516de30ae925d28
  - api key: 9qFqkUUTuP9wXKyNR5L6drodew5WDQxM
  - secret key: 4fJr4HdDZruZ6M4WNLahqwxcrEhaRq1ttVaQhscE4QHDsHE5bmYvhZNjywVo4ncJ
- team key
  - key: 9jr582Zz46Xz8dd6LW2FfGW2ze5GcnTg
  - secret key: 3eZGjM5nh1N6BSUNydJxhyQ6WZuBytrudHnrgBNPV4xSvNb3KaXCf38hqYL17oDz



### resource

- biconomy network: https://dapp-world.com/blogs/01/demystifying-gasless-transactions-part-2-k08y
- meta: https://metacoin.opengsn.org/