async function main() {
    const SigningGame = await ethers.getContractFactory("SigningGame");

 
    // Start deployment, returning a promise that resolves to a contract object
    const signing_game = await SigningGame.deploy();

    console.log("Contract deployed to address:", signing_game.address);

 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });