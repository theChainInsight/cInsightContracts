# contracts
the smart contracts codes

# localnet deploy
Please Install foundry
https://book.getfoundry.sh/getting-started/installation

Next, 
```bash
$ forge build
$ anvil
```
.envファイルにコンソールに出力された(0)番目のprivate keyを記述．
`DEPROYER_KEY=hoge`
```bash
$ forge script script/cInsightScript.s.sol:cInsightScript --fork-url http://localhost:8545 --broadcast
```