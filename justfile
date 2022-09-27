# Declaratively set shell recipes a.k.a commands should run in
set shell := ["bash", "-uc"]

# Load environment variables
set dotenv-load := true
# apikey:
#    echo " from .env"

# set positional-arguments := true
# foo:
#   echo justinit
#   echo

# Colours

RED:= "\\033[31m"
GREEN:= "\\033[32m"
YELLOW:= "\\033[33m"
BLUE:= "\\033[34m"
MAGNETA:= "\\033[35m"
CYAN:= "\\033[36m"
WHITE:= "\\033[37m"
BOLD:= "\\033[1m"
UNDERLINE:= "\\033[4m"
INVERTED_COLOURS:= "\\033[7m"
RESET := "\\033[0m"
NEWLINE := "\n"

# Recipes

default:
    @#This recipe will be the default if you run just without an argument, e.g list out available commands
    @just --list --unsorted --list-heading $'{{BOLD}}{{GREEN}}Available recipes:{{NEWLINE}}{{RESET}}'
hello:
    @#Hide the recipe being run in the output using an @ symbol
    @#Here we use our hidden helper to prettify the text
    @just _bold_squares "{{YELLOW}}Hello World!"
display:
    #By default it prints the recipe that was run in output before outputting result
    echo -e "Hello World! {{UNDERLINE}}Here we see the recipe that was run printed also by omitting @ in front of recipe"
install *PACKAGES:
   @npm install {{PACKAGES}}
compile:
	@npm run compile
deploy-localhost:
	@npm run deploy-localhost
deploy-testnet:
	@npm run deploy-testnet
verify-testnet:
	@npm run verify-testnet
test:
	@npm run test
lint:
	@npm run lint
start:
	@#Start a local hardhat blockchain instance localhost:8545
	@npm run node
format:
	@npm run format
audit:
	@npm run audit
print-audit:
	@npm run print-audit
print-gas-usage:
	@npm run print-gas-usage
print-deployments:
	@cat deployments/deploy.ts
