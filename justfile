default:
	just --list
install:
	npm install
compile:
	npx hardhat compile
deploy:
	echo "npx hardhat run scripts/deploy.ts --network <network>"
test:
	echo "npx hardhat test test/africarare.ts --network <network>"
