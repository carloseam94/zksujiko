<template>
  <div id="sujiko-section">
    <script src="snarkjs.min.js"></script>
    <b-overlay :show="show_overlay" rounded="sm">
      <div class="container pb-1" :aria-hidden="show_overlay ? 'true' : null">
        <div class="row mb-2">
          <div class="col">
            <div
              id="graph"
              class="flex item-center justify-center h-full mt-4"
            ></div>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <b-button variant="primary" size="sm" @click="clearBoard">Clear Board</b-button>
            <b-button variant="primary" size="sm" @click="loadNewBoard">Load Board</b-button>
          </div>
          <div class="col text-center">
            <b-button-group>
              <b-button @click="insertNumber(' ')">del</b-button>
              <b-button @click="insertNumber(1)">1</b-button>
              <b-button @click="insertNumber(2)">2</b-button>
              <b-button @click="insertNumber(3)">3</b-button>
              <b-button @click="insertNumber(4)">4</b-button>
              <b-button @click="insertNumber(5)">5</b-button>
              <b-button @click="insertNumber(6)">6</b-button>
              <b-button @click="insertNumber(7)">7</b-button>
              <b-button @click="insertNumber(8)">8</b-button>
              <b-button @click="insertNumber(9)">9</b-button>
            </b-button-group>
          </div>
          <div class="col text-right">
            <b-button variant="primary" size="sm" @click="setAsInitialBoard" v-show="contributing">Set as initial board</b-button>
            <b-button variant="primary" size="sm" @click="contribute" :disabled="contributing">Contribute</b-button>
            <b-button variant="primary" size="sm" @click="contributing ? submitContribution() : verify()">{{ contributing ? "Submit" : "Verify" }}</b-button>
          </div>
        </div>
        <div class="row">
          <div class="col">
            <b-button
              variant="primary"
              v-if="!walletConnected"
              @click="connectWallet"
            >
              Connect Wallet
            </b-button>
          </div>
        </div>
      </div>
    </b-overlay>
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
      board: null,
      fixed: null,
      circles: null,
      network: null,
      nodes: null,
      edges: null,
      circuit_wasm: null,
      circuit_key: null,
      walletConnected: false,
      account: "",
      CONTRACT_ADDRESS: "0x966797a56832DC75491fb63326F7a3CB272cCdA6",
      show_overlay: true,
      contributing: false
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
      this.show_overlay = true;
      let calldata = await sujikoCalldata(
        this.board,
        this.circles,
        this.getBoard()
      );

      if (!calldata) {
        this.wrongAnswer();
        return;
      }

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
          
          if(response) {
            this.correctAnswer();
          }
          else {
            this.wrongAnswer();
          }
          
        } else {
          this.wrongAnswer();
        }
      } catch (error) {
       this.wrongAnswer();
      }
    },
    contribute() {
      this.contributing = true;
      this.clearBoard();
      this.board = [0,0,0,0,0,0,0,0,0];
      this.circles = [0,0,0,0];
      this.fixed = [];
      this.createNetwork();
    },
    async submitContribution() {
      this.show_overlay = true;
      let calldata = await sujikoCalldata(
        this.board,
        this.circles,
        this.getBoard()
      );

      if (!calldata) {
        this.invalidContribution();
        return;
      }

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

          let response = await connectedContract.contributeSujiko(
            calldata[0],
            calldata[1],
            calldata[2],
            calldata[3]
          );
          
          if(response) {
            this.successfullContribution();
          }
          else {
            this.invalidContribution();
          }
          
        } else {
          this.invalidContribution();
        }
      } catch (error) {
       this.invalidContribution();
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
    setAsInitialBoard() {
      this.board = this.getBoard();
      this.makeToast('Done', 'Set as initial board.', 'info');
    },
    getNetWorkOptions() {
      return {
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
        manipulation: {
          enabled: true,
          addNode: function (nodeData, callback) {
            nodeData.label = " ";
            var r = confirm("Do you want a Square?");
            if (r === true) {
              nodeData.shape = "box";
              nodeData.widthConstraint = 20;
              nodeData.color = "#d8d2d2";
            } else {
              nodeData.shape = "circle";
              nodeData.widthConstraint = 30;
              nodeData.color = "#7eb4ef";
            }
            callback(nodeData);
          },
          editNode: function (nodeData, callback) {
            console.log(nodeData);
            if (nodeData.shape == "box") {
              nodeData.shape = "circle";
              nodeData.widthConstraint = 30;
              nodeData.color = "#7eb4ef";
            } else {
              nodeData.shape = "box";
              nodeData.widthConstraint = 20;
              nodeData.color = "#d8d2d2";
            }
            callback(nodeData);
          },
        },
      };
    },
    clearBoard() {
      this.board = null;
      this.circles = null;
      this.fixed = null;
      this.network.destroy();

      this.nodes =  this.nodes = new vis.DataSet([]);
      this.edges =  this.edges = new vis.DataSet([]);
     
      var container = document.getElementById("graph");
      var data = {
        nodes: this.nodes,
        edges: this.edges,
      };
      var options = this.getNetWorkOptions();
      this.network = new vis.Network(container, data, options);

      setTimeout(() => {
        this.network.moveTo({ scale: 2 });
      }, 0);
    },
    async loadNewBoard() {
      this.contributing = false;
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
      var options = this.getNetWorkOptions();
      this.network = new vis.Network(container, data, options);

      setTimeout(() => {
        this.network.moveTo({ scale: 2 });
      }, 0);

      document.getElementById("graph").onkeydown = (event) => {
        if (/^[1-9]$/i.test(event.key)) {
          this.insertNumber(event.key.toString());
        }
      };
    },
    insertNumber(number) {
      var selectedNode = this.nodes.get(this.network.getSelectedNodes()[0]);
      if(this.contributing || ( selectedNode !== undefined && !this.fixed.includes(selectedNode.id))) {
        if(selectedNode.id <= 9) {
          selectedNode.label = number.toString();
        }
        else {
          if(selectedNode.label == ' ') {
             selectedNode.label = number.toString();
          } else if(selectedNode.label.length == 1) {
            selectedNode.label += number.toString();
          } else if(selectedNode.label.length == 2 && number == 0) {
            selectedNode.label = number.toString();
          }
         
        }
        this.nodes.update(selectedNode);
      }  
    },
    successfullContribution() {
      this.makeToast('Successfull Contribution', 'Thanks for contributing!', 'success');
      this.show_overlay = false;
    },
    invalidContribution() {
      this.makeToast('Invalid Contribution', 'Sorry we already have this sujiko or it has some error :(', 'danger');
      this.show_overlay = false;
    },
    wrongAnswer() {
      this.makeToast('Wrong Answer', 'Nice try, you are almost there!', 'danger');
      this.show_overlay = false;
    },
    correctAnswer() {
      this.makeToast('Correct Answer', 'Hey you are good at this!', 'success');
      this.show_overlay = false;
    },
    makeToast(title, text, variant = null) {
      this.$bvToast.toast(text, {
        toaster: 'b-toaster-top-center',
        title: title,
        variant: variant,
        solid: true,
        appendToast: true
      });
    },
  },
  mounted() {
    this.checkIfWalletIsConnected();
    this.loadNewBoard();
    this.show_overlay = false;
  },
};
</script>
<style>
#graph {
  min-height: 600px;
  border: 1px dashed black;
}
#graph > .vis-network {
  outline: none;
}
#sujiko-section {
  min-height: 100vh;
}
</style>
