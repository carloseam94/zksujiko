<template>
  <div id="sujiko-section">
    <script src="snarkjs.min.js"></script>
    <b-overlay :show="show_overlay" rounded="sm">
      <div class="container pb-1" :aria-hidden="show_overlay ? 'true' : null">
        <div class="row mt-3 mt-md-5">
          <div class="col text-center">
            <h2>{{ MODE }}</h2>
            <h4>{{ sujiko_index + 1 + "/" + sujiko_limit }}</h4>
          </div>
        </div>
        <div class="row mb-2">
          <div class="col">
            <div
              id="graph"
              class="flex item-center justify-center h-full"
            ></div>
          </div>
        </div>
        <div class="row">
          <div class="col text-md-left text-center mb-2">
            <b-button
              variant="primary"
              size="sm"
              @click="loadPreviousSujiko"
              title="Previous Sujiko"
              ><b-icon icon="arrow-left" aria-label="arrow-left"></b-icon
            ></b-button>
            <b-button variant="primary" size="sm" title="Reload Sujiko" @click="loadNewSujiko"><b-icon icon="arrow-clockwise"></b-icon></b-button>
            <b-button
              variant="primary"
              size="sm"
              @click="changeMode"
              title="Change Mode"
              >Change Mode</b-button
            >
            <b-button
              variant="primary"
              size="sm"
              @click="loadNextSujiko"
              title="Next Sujiko"
              ><b-icon icon="arrow-right" aria-label="arrow-right"></b-icon
            ></b-button>
          </div>
          <div class="col text-center mb-2">
            <b-button-group>
              <b-button @click="insertNumber(0)">0</b-button>
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
          <div class="col text-md-right text-center mb-2">
            <b-button
              variant="primary"
              size="sm"
              @click="setAsInitialBoard"
              v-show="contributing"
              >Set as initial board</b-button
            >
            <b-button
              variant="primary"
              size="sm"
              @click="contribute"
              :disabled="contributing || !walletConnected"
              >Create New Sujiko</b-button
            >
            <b-button
              variant="primary"
              size="sm"
              :disabled="contributing && !initialBoardSet"
              @click="contributing ? submitContribution() : verify()"
              >{{ contributing ? "Submit" : "Verify" }}</b-button
            >
          </div>
        </div>
        <div class="row">
          <div class="col">
            <b-button
              variant="primary"
              size="sm"
              v-if="!walletConnected"
              @click="connectWallet"
            >
              Connect Wallet to Create and upload your own Sujiko
            </b-button>
          </div>
        </div>
      </div>
    </b-overlay>
    <div class="container">
      <div class="row mt-5 pt-5">
        <div class="col">
          <h3>Know more about Sujikos!</h3>
        </div>
      </div>
      <div class="row mb-5 pb-5">
        <div class="col">
          <div class="accordion" role="tablist">
            <b-card no-body class="mb-1">
              <b-card-header header-tag="header" class="p-1" role="tab">
                <b-button block v-b-toggle.accordion-1 variant="primary"
                  >Sujiko</b-button
                >
              </b-card-header>
              <b-collapse
                id="accordion-1"
                visible
                accordion="my-accordion"
                role="tabpanel"
              >
                <b-card-body>
                  <b-card-text>
                    Sujiko is a logic-based, combinatorial number-placement
                    puzzle created by Jai Gomer of Kobayaashi Studios.
                  </b-card-text>
                  <b-card-text>
                    The puzzle takes place on a 3x3 grid with four circled
                    number clues at the centre of each quadrant which indicate
                    the sum of the four numbers in that quadrant. The numbers
                    1-9 must be placed in the grid, in accordance with the
                    circled clues, to complete the puzzle.
                  </b-card-text>
                </b-card-body>
              </b-collapse>
            </b-card>
            <b-card no-body class="mb-1">
              <b-card-header header-tag="header" class="p-1" role="tab">
                <b-button block v-b-toggle.accordion-2 variant="primary"
                  >Sujiko62</b-button
                >
              </b-card-header>
              <b-collapse
                id="accordion-2"
                accordion="my-accordion"
                role="tabpanel"
              >
                <b-card-body>
                  <b-card-text>
                    Sujiko62 is a new type of sujikos that I created. They have
                    6 squares and 2 circles (hence the 62 in the name).
                  </b-card-text>
                  <b-card-text>
                    The magic about this particular kind of sujikos is that they
                    are no longer constrained in a grid shape. They can come in
                    new and exciting forms because now they behave like graphs.
                  </b-card-text>
                  <b-card-text>
                    The same rules for regular sujikos apply to Sujiko62s but
                    this time the range of valid numbers is 1-6.
                  </b-card-text>
                </b-card-body>
              </b-collapse>
            </b-card>
            <b-card no-body class="mb-1">
              <b-card-header header-tag="header" class="p-1" role="tab">
                <b-button block v-b-toggle.accordion-3 variant="primary"
                  >XSujiko</b-button
                >
              </b-card-header>
              <b-collapse
                id="accordion-3"
                accordion="my-accordion"
                role="tabpanel"
              >
                <b-card-body>
                  <b-card-text>
                    XSujikos are also a new type of sujikos that I created. They
                    are still under development but will be ready soon!
                  </b-card-text>
                  <b-card-text>
                    This type will be the final evolution of Sujiko62s. They
                    will be graphs as well, but this time without the
                    restriction of 6 squares and 2 circles.
                  </b-card-text>
                  <b-card-text>
                    See you soon and thanks for playing!
                  </b-card-text>
                </b-card-body>
              </b-collapse>
            </b-card>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { ethers } from "ethers";
import Sujiko from "../utils/Sujiko.json";
import Sujiko62 from "../utils/Sujiko62.json";
import deployed_contracts from "../utils/DeployedContracts.json";
import { sujikoCalldata } from "../zkutils/sujiko_prover.js";
import { sujiko62Calldata } from "../zkutils/sujiko62_prover.js";
const vis = require("vis-network/dist/vis-network.js");

export default {
  data() {
    return {
      MODE: "SUJIKO",
      squares: null,
      fixed: null,
      circles: null,
      sujiko62_edges: null,
      network: null,
      nodes: null,
      edges: null,
      walletConnected: false,
      account: "",
      show_overlay: true,
      contributing: false,
      sujiko_index: 0,
      sujiko_limit: 1,
      initialBoardSet: false,
    };
  },
  methods: {
    async switchToHarmonyTestnet() {
       await ethereum.request({
        method: "wallet_addEthereumChain",
        params: [{
            chainId: "0x6357D2E0",
            rpcUrls: ["https://api.s0.b.hmny.io"],
            chainName: "Harmony Testnet",
            nativeCurrency: {
                name: "one",
                symbol: "one"
            },
            blockExplorerUrls: ["https://explorer.pops.one/"]
          }]
        });
    },
    async switchToHarmonyMainnet() {
       await ethereum.request({
        method: "wallet_addEthereumChain",
        params: [{
            chainId: "0x63564C40",
            rpcUrls: ["https://api.harmony.one"],
            chainName: "Harmony Mainnet",
            nativeCurrency: {
                name: "one",
                symbol: "one"
            },
            blockExplorerUrls: ["https://explorer.harmony.one"]
          }]
        });
    },
    async changeMode() {
      if (this.MODE === "SUJIKO") {
        this.MODE = "SUJIKO62";
      } else if (this.MODE === "SUJIKO62") {
        this.MODE = "XSUJIKO (Working on this)";
        this.clearSujiko();
        this.sujiko_index = 0;
        this.sujiko_limit = 1;
        return;
      } else {
        this.MODE = "SUJIKO";
      }
      this.sujiko_index = 0;
      this.loadNewSujiko();
    },
    async checkIfWalletIsConnected() {
      const { ethereum } = window;

      if (!ethereum) {
        console.log("Make sure you have metamask!");
        await this.loadNewSujiko(0);
        this.show_overlay = false;
        return;
      } else {
        console.log("We have the ethereum object", ethereum);
      }

      const accounts = await ethereum.request({ method: "eth_accounts" });

      await this.switchToHarmonyMainnet();
      await this.loadNewSujiko(0);
      this.show_overlay = false;

      if (accounts.length !== 0) {
        
        this.account = accounts[0];
        this.walletConnected = true;

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

        await this.switchToHarmonyMainnet();

        const accounts = await ethereum.request({
          method: "eth_requestAccounts",
        });

        console.log("Connected", accounts[0]);
        this.account = accounts[0];
        this.walletConnected = true;
        await this.loadNewSujiko(0);
        this.show_overlay = false;
      } catch (error) {
        console.log(error);
      }
    },
    async verify() {
      this.show_overlay = true;

      var calldata;
      if (this.MODE === "SUJIKO") {
        console.log(this.squares);
        console.log(this.circles);
        console.log(this.getSujiko());
        calldata = await sujikoCalldata(
          this.squares,
          this.circles,
          this.getSujiko()
        );
      } else if (this.MODE === "SUJIKO62") {
        calldata = await sujiko62Calldata(
          this.squares,
          this.circles,
          this.sujiko62_edges,
          this.getSujiko()
        );
      }

      console.log(calldata);

      if (!calldata) {
        this.wrongAnswer();
        return;
      }

      try {
        const { ethereum } = window;
        var provider;
        var signer;
        if (ethereum) {
          provider = new ethers.providers.Web3Provider(ethereum);
        }
        if (provider) {
          if (provider._address) {
            signer = provider.getSigner();
          } else {
            signer = provider;
          }
        } else {
          signer = ethers.providers.getDefaultProvider(
            "https://api.harmony.one"
          );
        }

        var response;
        if (this.MODE === "SUJIKO") {
          const connectedContract = new ethers.Contract(
            deployed_contracts.sujiko.address,
            Sujiko.abi,
            signer
          );

          response = await connectedContract.verifySujiko(
            calldata[0],
            calldata[1],
            calldata[2],
            calldata[3]
          );
        } else if (this.MODE === "SUJIKO62") {
          const connectedContract = new ethers.Contract(
            deployed_contracts.sujiko62.address,
            Sujiko62.abi,
            signer
          );

          response = await connectedContract.verifySujiko62(
            calldata[0],
            calldata[1],
            calldata[2],
            calldata[3]
          );
        }

        if (response) {
          this.correctAnswer();
        } else {
          this.wrongAnswer();
        }
      } catch (error) {
        this.wrongAnswer();
      }
    },
    contribute() {
      this.contributing = true;
      this.initialBoardSet = false;
      this.clearSujiko();

      if (this.MODE === "SUJIKO") {
        this.squares = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        this.circles = [0, 0, 0, 0];
        this.fixed = [10, 11, 12, 13];
      } else if (this.MODE === "SUJIKO62") {
        this.squares = [0, 0, 0, 0, 0, 0];
        this.circles = [0, 0];
        this.sujiko62_edges = [
          [0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0],
        ];
        this.fixed = [6, 7];
      }
      this.createNetwork();
    },
    async submitContribution() {
      this.show_overlay = true;

      var calldata;
      if (this.MODE === "SUJIKO") {
        calldata = await sujikoCalldata(
          this.squares,
          this.circles,
          this.getSujiko()
        );
      } else if (this.MODE === "SUJIKO62") {
        calldata = await sujiko62Calldata(
          this.squares,
          this.circles,
          this.sujiko62_edges,
          this.getSujiko()
        );
      }

      console.log(calldata);

      if (!calldata) {
        this.invalidContribution();
        return;
      }

      try {
        const { ethereum } = window;

        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();

          var response;
          if (this.MODE === "SUJIKO") {
            const connectedContract = new ethers.Contract(
              deployed_contracts.sujiko.address,
              Sujiko.abi,
              signer
            );

            response = await connectedContract.contributeSujiko(
              calldata[0],
              calldata[1],
              calldata[2],
              calldata[3]
            );
          } else if (this.MODE === "SUJIKO62") {
            const connectedContract = new ethers.Contract(
              deployed_contracts.sujiko62.address,
              Sujiko62.abi,
              signer
            );

            response = await connectedContract.contributeSujiko62(
              calldata[0],
              calldata[1],
              calldata[2],
              calldata[3]
            );
          }

          if (response) {
            this.successfullContribution();
            // setTimeout(() => {
            //   this.loadNextSujiko();
            // }, 10000);
          } else {
            this.invalidContribution();
          }
        } else {
          this.invalidContribution();
        }
      } catch (error) {
        this.invalidContribution();
      }
    },
    getSujiko() {
      var sujiko;
      if (this.MODE === "SUJIKO") {
        sujiko = this.nodes
          .get()
          .filter((x) => {
            return x.id >= 1 && x.id <= 9;
          })
          .map((x) => {
            return /^[1-9]$/i.test(x.label) ? Number.parseInt(x.label) : 0;
          });
      } else if (this.MODE === "SUJIKO62") {
        sujiko = this.nodes
          .get()
          .filter((x) => {
            return x.id >= 1 && x.id <= 6;
          })
          .map((x) => {
            return /^[1-9]$/i.test(x.label) ? Number.parseInt(x.label) : 0;
          });
      }
      return sujiko;
    },
    getCircles() {
      var circles;
      if (this.MODE === "SUJIKO") {
        circles = this.nodes
          .get()
          .filter((x) => {
            return x.id >= 10 && x.id <= 13;
          })
          .map((x) => {
            return Number.parseInt(x.label);
          });
      } else if (this.MODE === "SUJIKO62") {
        circles = this.nodes
          .get()
          .filter((x) => {
            return x.id >= 7 && x.id <= 8;
          })
          .map((x) => {
            return Number.parseInt(x.label);
          });
      }
      return circles;
    },
    setAsInitialBoard() {
      const circles = this.getCircles();
      for (let i = 0; i < circles.length; i++) {
        if (Number.isNaN(circles[i])) {
          this.makeToast("Error", "All circles needs a value", "danger");
          return false;
        }
      }
      this.initialBoardSet = true;
      this.squares = this.getSujiko();
      this.circles = circles;
      this.makeToast("Done", "Initial board was correctly set", "info");
      return true;
    },
    clearSujiko() {
      // this.MODE = "CLEAR";
      this.squares = null;
      this.circles = null;
      this.sujiko62_edges = null;
      this.fixed = null;
      this.network.destroy();

      this.nodes = this.nodes = new vis.DataSet([]);
      this.edges = this.edges = new vis.DataSet([]);

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
    loadNextSujiko() {
      this.sujiko_index++;
      if (this.sujiko_index == this.sujiko_limit) {
        this.sujiko_index = 0;
      }
      this.loadNewSujiko();
    },
    loadPreviousSujiko() {
      this.sujiko_index--;
      if (this.sujiko_index < 0) {
        this.sujiko_index = this.sujiko_limit - 1;
      }
      this.loadNewSujiko();
    },
    async loadNewSujiko() {
      this.contributing = false;
      try {
        const { ethereum } = window;
        var provider;
        var signer;
        if (ethereum) {
          provider = new ethers.providers.Web3Provider(ethereum);
        }
        if (provider) {
          if (provider._address) {
            signer = provider.getSigner();
          } else {
            signer = provider;
          }
        } else {
          signer = ethers.providers.getDefaultProvider(
            "https://api.harmony.one"
          );
        }

        if (this.MODE === "SUJIKO") {
          const connectedContract = new ethers.Contract(
            deployed_contracts.sujiko.address,
            Sujiko.abi,
            signer
          );

          const response = await connectedContract.getNewSujiko(
            this.sujiko_index
          );

          this.squares = response[0];
          this.circles = response[1];
          this.sujiko_limit = response[2];
          this.fixed = [];
          this.squares.map((x, index) => {
            if (x != 0) this.fixed.push(index + 1);
          });
          this.fixed.push(10);
          this.fixed.push(11);
          this.fixed.push(12);
          this.fixed.push(13);
        } else if (this.MODE === "SUJIKO62") {
          const connectedContract = new ethers.Contract(
            deployed_contracts.sujiko62.address,
            Sujiko62.abi,
            signer
          );
          const response = await connectedContract.getNewSujiko62(
            this.sujiko_index
          );

          this.squares = response[0];
          this.circles = response[1];
          this.sujiko62_edges = response[2];
          this.sujiko_limit = response[3];
          this.fixed = [];
          this.squares.map((x, index) => {
            if (x != 0) this.fixed.push(index + 1);
          });
          this.fixed.push(7);
          this.fixed.push(8);
        }

        this.createNetwork();
      } catch (error) {
        console.log(error);
      }
    },
    createNetwork() {
      if (this.MODE === "SUJIKO") {
        // create an array with nodes
        this.nodes = new vis.DataSet([
          {
            id: 1,
            label: this.squares[0] != 0 ? this.squares[0].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: -100,
            y: -100,
          },
          {
            id: 2,
            label: this.squares[1] != 0 ? this.squares[1].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: 0,
            y: -100,
          },
          {
            id: 3,
            label: this.squares[2] != 0 ? this.squares[2].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: 100,
            y: -100,
          },
          {
            id: 4,
            label: this.squares[3] != 0 ? this.squares[3].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: -100,
            y: 0,
          },
          {
            id: 5,
            label: this.squares[4] != 0 ? this.squares[4].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: 0,
            y: 0,
          },
          {
            id: 6,
            label: this.squares[5] != 0 ? this.squares[5].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: 100,
            y: 0,
          },
          {
            id: 7,
            label: this.squares[6] != 0 ? this.squares[6].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: -100,
            y: 100,
          },
          {
            id: 8,
            label: this.squares[7] != 0 ? this.squares[7].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
            x: 0,
            y: 100,
          },
          {
            id: 9,
            label: this.squares[8] != 0 ? this.squares[8].toString() : " ",
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
      } else if (this.MODE === "SUJIKO62") {
        // create an array with nodes
        this.nodes = new vis.DataSet([
          {
            id: 1,
            label: this.squares[0] != 0 ? this.squares[0].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
          },
          {
            id: 2,
            label: this.squares[1] != 0 ? this.squares[1].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
          },
          {
            id: 3,
            label: this.squares[2] != 0 ? this.squares[2].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
          },
          {
            id: 4,
            label: this.squares[3] != 0 ? this.squares[3].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
          },
          {
            id: 5,
            label: this.squares[4] != 0 ? this.squares[4].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
          },
          {
            id: 6,
            label: this.squares[5] != 0 ? this.squares[5].toString() : " ",
            shape: "box",
            widthConstraint: 20,
            color: "#d8d2d2",
          },
          {
            id: 7,
            label: this.circles[0] != 0 ? this.circles[0].toString() : " ",
            shape: "circle",
            widthConstraint: 30,
          },
          {
            id: 8,
            label: this.circles[1] != 0 ? this.circles[1].toString() : " ",
            shape: "circle",
            widthConstraint: 30,
          },
        ]);

        // create an array with edges
        var pre_parsed_edges = [];
        for (let i = 0; i < this.sujiko62_edges.length; i++) {
          for (let j = 0; j < this.sujiko62_edges[i].length; j++) {
            if (this.sujiko62_edges[i][j] == 1) {
              pre_parsed_edges.push({ from: i + 7, to: j + 1 });
            }
          }
        }

        this.edges = new vis.DataSet(pre_parsed_edges);
      }

      // create a network
      var container = document.getElementById("graph");
      var data = {
        nodes: this.nodes,
        edges: this.edges,
      };
      var options = this.getNetWorkOptions();
      this.network = new vis.Network(container, data, options);

      if (this.MODE === "SUJIKO") {
        setTimeout(() => {
          this.network.moveTo({ scale: 2 });
        }, 0);
      }

      document.getElementById("graph").onkeydown = (event) => {
        if (/^[0-9]$/i.test(event.key)) {
          this.insertNumber(event.key.toString());
        }
      };
    },
    getNetWorkOptions() {
      var options;
      if (this.MODE === "SUJIKO") {
        options = {
          height: "600px",
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
            enabled: false,
          },
        };
      } else if (this.MODE === "SUJIKO62") {
        options = {
          height: "600px",
          nodes: {
            font: "20px arial black",
          },
          edges: {
            color: "#4b5563",
          },
          interaction: {
            navigationButtons: true,
          },
          manipulation: {
            enabled: this.contributing,
            addNode: false,
            deleteNode: false,
            editEdge: false,
            addEdge: (edgeData, callback) => {
              console.log(this.sujiko62_edges);
              console.log(edgeData);
              if (edgeData.from == 7 && edgeData.to != 7 && edgeData.to != 8) {
                this.sujiko62_edges[0][edgeData.to - 1] = 1;
                callback(edgeData);
              } else if (
                edgeData.to == 7 &&
                edgeData.from != 7 &&
                edgeData.from != 8
              ) {
                this.sujiko62_edges[0][edgeData.from - 1] = 1;
                callback(edgeData);
              } else if (
                edgeData.from == 8 &&
                edgeData.to != 8 &&
                edgeData.to != 7
              ) {
                this.sujiko62_edges[1][edgeData.to - 1] = 1;
                callback(edgeData);
              } else if (
                edgeData.to == 8 &&
                edgeData.from != 8 &&
                edgeData.from != 7
              ) {
                this.sujiko62_edges[1][edgeData.from - 1] = 1;
                callback(edgeData);
              }
            },
          },
        };
      } else {
        options = {
          height: "600px",
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
      }
      return options;
    },
    insertNumber(number) {
      var selectedNode = this.nodes.get(this.network.getSelectedNodes()[0]);
      if (
        selectedNode !== undefined &&
        selectedNode.label !== undefined &&
        (this.contributing || !this.fixed.includes(selectedNode.id))
      ) {
        var aux;
        if (this.MODE === "SUJIKO") {
          aux = 9;
        } else if (this.MODE === "SUJIKO62") {
          aux = 6;
        }
        if (selectedNode.id <= aux) {
          if (number != 0) {
            selectedNode.label = number.toString();
          } else {
            selectedNode.label = " ";
          }
        } else {
          if (selectedNode.label == " ") {
            if (number != 0) {
              selectedNode.label = number.toString();
            }
          } else if (selectedNode.label.length == 1) {
            selectedNode.label += number.toString();
          } else if (selectedNode.label.length == 2) {
            if (number != 0) {
              selectedNode.label = number.toString();
            } else {
              selectedNode.label = " ";
            }
          }
        }
        this.nodes.update(selectedNode);
      }
    },
    successfullContribution() {
      this.makeToast(
        "Successfull Contribution",
        "Thanks for contributing! An NFT has been minted to your address.",
        "success"
      );
      this.show_overlay = false;
    },
    invalidContribution() {
      this.makeToast(
        "Invalid Contribution",
        "Sorry we already have this sujiko or it has some error :(",
        "danger"
      );
      this.show_overlay = false;
    },
    wrongAnswer() {
      this.makeToast(
        "Wrong Answer",
        "Nice try, you are almost there!",
        "danger"
      );
      this.show_overlay = false;
    },
    correctAnswer() {
      this.makeToast("Correct Answer", "Hey you are good at this!", "success");
      this.show_overlay = false;
    },
    makeToast(title, text, variant = null) {
      this.$bvToast.toast(text, {
        toaster: "b-toaster-top-center",
        title: title,
        variant: variant,
        solid: true,
        appendToast: true,
      });
    },
  },
  mounted() {
    this.checkIfWalletIsConnected();
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



