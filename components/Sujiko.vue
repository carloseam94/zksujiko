<template>
  <div>
    <script src="snarkjs.min.js"></script>
    <div id="graph" class="flex item-center justify-center h-full"></div>
    <button class="btn btn-primary" @click="verify">Verify</button>
  </div>
</template>
<script>
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
    };
  },
  methods: {
    async loadCircuit() {
      this.circuit_wasm = await fetch("/circuit.wasm");
      this.circuit_key = await fetch("/circuit_0001.zkey");
    },
    verify() {
      let solution = this.getBoard();
      console.log(this.board);
      console.log(solution);
      console.log(this.fixed);
      console.log(this.circles);
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
    loadNewBoard() {
      this.board = [0, 0, 0, 0, 0, 0, 8, 0, 7];
      this.circles = [10, 21, 18, 20];
      this.board.map((x, index) => {
        if (x != 0) this.fixed.push(index + 1);
      });
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
    this.loadCircuit();
    this.loadNewBoard();
    this.createNetwork();
  },
};
</script>
<style>
#graph > .vis-network {
  border: 1px dashed black;
  outline: none;
}
</style>