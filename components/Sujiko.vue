<template>
  <div>
    <script src="snarkjs.min.js"></script>
    <div class="container">
      <div class="row mb-2">
        <div class="col">
          <div id="graph" class="flex item-center justify-center h-full"></div>
        </div>
      </div>
      <div class="row">
        <div class="col">
          <button
            class="btn btn-primary"
            :disabled="walletConnected"
            @click="connectWallet"
          >
            Connect Wallet
          </button>
        </div>
        <div class="col">
          <button class="btn btn-primary" @click="verify">Verify</button>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { ethers } from "ethers";
import Sujiko from "../utils/Sujiko.json";
import { sujikoCalldata } from "../zkutils/snarkjs_sujiko.js";
const vis = require("vis-network/dist/vis-network.js");

export default {
  data() {
    return {
      board: [0, 0, 0, 0, 0, 0, 0, 0, 0],
      fixed: [],
      circles: [0, 0, 0, 0],
      network: null,
      nodes: null,
      edges: null,
      circuit_wasm: null,
      circuit_key: null,
      walletConnected: false,
      account: "",
      CONTRACT_ADDRESS: "0x55ad7dB2860291C7271C8b8929d82322Ff0F71f0",
    };
  },
  methods: {
    async checkIfWalletIsConnected() {
      /*
       * First make sure we have access to window.ethereum
       */
      const { ethereum } = window;

      if (!ethereum) {
        console.log("Make sure you have metamask!");
        return;
      } else {
        console.log("We have the ethereum object", ethereum);
      }

      /*
       * Check if we're authorized to access the user's wallet
       */
      const accounts = await ethereum.request({ method: "eth_accounts" });

      /*
       * User can have multiple authorized accounts, we grab the first one if its there!
       */
      if (accounts.length !== 0) {
        this.account = accounts[0];
        this.walletConnected = true;
        this.setupEventListener();
        console.log("Found an authorized account:", this.account);
      } else {
        console.log("No authorized account found");
      }
    },
    async connectWallet() {
      try {
        const { ethereum } = window;

        if (!ethereum) {
          alert("Get MetaMask!");
          return;
        }

        /*
         * Fancy method to request access to account.
         */
        const accounts = await ethereum.request({
          method: "eth_requestAccounts",
        });

        /*
         * Boom! This should print out public address once we authorize Metamask.
         */
        console.log("Connected", accounts[0]);
        this.account = accounts[0];
        this.walletConnected = true;
        this.setupEventListener();
      } catch (error) {
        console.log(error);
      }
    },
    async setupEventListener() {
      // Most of this looks the same as our function askContractToMintNft
      try {
        const { ethereum } = window;

        if (ethereum) {
          // Same stuff again
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const connectedContract = new ethers.Contract(
            this.CONTRACT_ADDRESS,
            Sujiko.abi,
            signer
          );

          connectedContract.on("NewNFTMinted", (from, tokenId) => {
            this.mintingNFT = false;
            console.log(from, tokenId.toNumber());
            alert(
              `NFT minted: see transaction here https://mumbai.polygonscan.com/address/${
                this.CONTRACT_ADDRESS
              } or see NFT here https://testnets.opensea.io/assets/mumbai/${
                this.CONTRACT_ADDRESS
              }/${tokenId.toNumber()}`
            );
          });

          console.log("Setup event listener!");
        } else {
          console.log("Ethereum object doesn't exist!");
        }
      } catch (error) {
        console.log(error);
      }
    },
    async verify() {
      // let solution = this.getBoard();
      // console.log(this.board);
      // console.log(solution);
      // console.log(this.fixed);
      // console.log(this.circles);

      let calldata = await sujikoCalldata(
        this.board,
        this.circles,
        this.getBoard()
      );

      if (!calldata) {
        return "Invalid inputs to generate witness.";
      }

      console.log("calldata", calldata);

      try {
        const { ethereum } = window;

        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const connectedContract = new ethers.Contract(
            this.CONTRACT_ADDRESS,
            Sujiko.abi,
            signer
          );

          let response = await connectedContract.verifySujiko(
            calldata[0],
            calldata[1],
            calldata[2],
            calldata[3]
          );

          console.log(response);
        } else {
          console.log("Ethereum object doesn't exist!");
        }
      } catch (error) {
        console.log(error);
      }
    },
    getBoard() {
      return this.nodes
        .get()
        .filter((x) => {
          return x.id >= 1 && x.id <= 9;
        })
        .map((x) => {
          return /^[1-9]$/i.test(x.label) ? Number.parseInt(x.label) : 0;
        });
    },
    async loadNewBoard() {
      try {
        const { ethereum } = window;

        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const connectedContract = new ethers.Contract(
            this.CONTRACT_ADDRESS,
            Sujiko.abi,
            signer
          );

          let response = await connectedContract.getNewBoard();
          this.board = response[0];
          this.circles = response[1];
          this.fixed = [];
          this.board.map((x, index) => {
            if (x != 0) this.fixed.push(index + 1);
          });

          this.createNetwork();
        } else {
          console.log("Ethereum object doesn't exist!");
        }
      } catch (error) {
        console.log(error);
      }
    },
    createNetwork() {
      // create an array with nodes
      this.nodes = new vis.DataSet([
        {
          id: 1,
          label: this.board[0] != 0 ? this.board[0].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: -100,
          y: -100,
        },
        {
          id: 2,
          label: this.board[1] != 0 ? this.board[1].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 0,
          y: -100,
        },
        {
          id: 3,
          label: this.board[2] != 0 ? this.board[2].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 100,
          y: -100,
        },
        {
          id: 4,
          label: this.board[3] != 0 ? this.board[3].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: -100,
          y: 0,
        },
        {
          id: 5,
          label: this.board[4] != 0 ? this.board[4].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 0,
          y: 0,
        },
        {
          id: 6,
          label: this.board[5] != 0 ? this.board[5].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 100,
          y: 0,
        },
        {
          id: 7,
          label: this.board[6] != 0 ? this.board[6].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: -100,
          y: 100,
        },
        {
          id: 8,
          label: this.board[7] != 0 ? this.board[7].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 0,
          y: 100,
        },
        {
          id: 9,
          label: this.board[8] != 0 ? this.board[8].toString() : " ",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 100,
          y: 100,
        },
        {
          id: 10,
          label: this.circles[0] != 0 ? this.circles[0].toString() : " ",
          shape: "circle",
          widthConstraint: 30,
          x: -50,
          y: -50,
        },
        {
          id: 11,
          label: this.circles[1] != 0 ? this.circles[1].toString() : " ",
          shape: "circle",
          widthConstraint: 30,
          x: 50,
          y: -50,
        },
        {
          id: 12,
          label: this.circles[2] != 0 ? this.circles[2].toString() : " ",
          shape: "circle",
          widthConstraint: 30,
          x: -50,
          y: 50,
        },
        {
          id: 13,
          label: this.circles[3] != 0 ? this.circles[3].toString() : " ",
          shape: "circle",
          widthConstraint: 30,
          x: 50,
          y: 50,
        },
      ]);

      // create an array with edges
      this.edges = new vis.DataSet([
        { from: 1, to: 10 },
        { from: 2, to: 10 },
        { from: 4, to: 10 },
        { from: 5, to: 10 },
        { from: 2, to: 11 },
        { from: 3, to: 11 },
        { from: 5, to: 11 },
        { from: 6, to: 11 },
        { from: 4, to: 12 },
        { from: 5, to: 12 },
        { from: 7, to: 12 },
        { from: 8, to: 12 },
        { from: 5, to: 13 },
        { from: 6, to: 13 },
        { from: 8, to: 13 },
        { from: 9, to: 13 },
      ]);

      // create a network
      var container = document.getElementById("graph");
      var data = {
        nodes: this.nodes,
        edges: this.edges,
      };
      var options = {
        height: "600px",
        // width: '600px',
        nodes: {
          font: "20px arial black",
          fixed: {
            x: true,
            y: true,
          },
        },
        edges: {
          color: "#4b5563",
        },
        interaction: {
          navigationButtons: true,
        },
      };
      this.network = new vis.Network(container, data, options);

      setTimeout(() => {
        this.network.moveTo({ scale: 2 });
      }, 0);

      // this.network.on("click", function (params) {
      //   var nodeID = this.getNodeAt(params.pointer.DOM)
      //   if(nodeID !== undefined && nodeID >= 1 && nodeID <= 9) {
      //     var clickedNode = nodes.get(nodeID);
      //     clickedNode.label = '4';
      //     nodes.update(clickedNode);
      //   }
      // });

      document.getElementById("graph").onkeydown = (event) => {
        var selectedNode = this.nodes.get(this.network.getSelectedNodes()[0]);
        if (
          selectedNode !== undefined &&
          selectedNode.id <= 9 &&
          !this.fixed.includes(selectedNode.id) &&
          /^[1-9]$/i.test(event.key)
        ) {
          selectedNode.label = event.key.toString();
          this.nodes.update(selectedNode);
        }
      };
    },
  },
  mounted() {
    this.checkIfWalletIsConnected();
    this.loadNewBoard();
    
  },
};
</script>
<style>
#graph > .vis-network {
  border: 1px dashed black;
  outline: none;
}
</style>
