<template>
  <div>
    <script src="snarkjs.min.js"></script>
    <div id="graph" class="flex item-center justify-center h-full"></div>
  </div>
</template>
<script>
import { sujikoCalldata } from "../zkutils/snarkjs_sujiko.js";
const vis = require("vis-network/dist/vis-network.js");
export default {
  data() {
    return {
      network: null,
      circuit_wasm: null,
      circuit_key: null
    };
  },
  methods: {
    async loadCircuit() {
      this.circuit_wasm = await fetch("/circuit.wasm");
      this.circuit_key = await fetch("/circuit_0001.zkey");
    },
    createNetwork() {
      // create an array with nodes
      var nodes = new vis.DataSet([
        {
          id: 1,
          label: "1",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: -100,
          y: -100,
        },
        {
          id: 2,
          label: "2",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 0,
          y: -100,
        },
        {
          id: 3,
          label: "3",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 100,
          y: -100,
        },
        {
          id: 4,
          label: "4",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: -100,
          y: 0,
        },
        {
          id: 5,
          label: "5",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 0,
          y: 0,
        },
        {
          id: 6,
          label: "6",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 100,
          y: 0,
        },
        {
          id: 7,
          label: "7",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: -100,
          y: 100,
        },
        {
          id: 8,
          label: "8",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 0,
          y: 100,
        },
        {
          id: 9,
          label: "9",
          shape: "box",
          widthConstraint: 20,
          color: "#d8d2d2",
          x: 100,
          y: 100,
        },
        {
          id: 10,
          label: "10",
          shape: "circle",
          widthConstraint: 30,
          x: -50,
          y: -50,
        },
        {
          id: 11,
          label: "11",
          shape: "circle",
          widthConstraint: 30,
          x: 50,
          y: -50,
        },
        {
          id: 12,
          label: "12",
          shape: "circle",
          widthConstraint: 30,
          x: -50,
          y: 50,
        },
        {
          id: 13,
          label: "13",
          shape: "circle",
          widthConstraint: 30,
          x: 50,
          y: 50,
        },
      ]);

      // create an array with edges
      var edges = new vis.DataSet([
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
        nodes: nodes,
        edges: edges,
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
          // zoomView: false,
          // dragView: false,
        },
      };
      this.network = new vis.Network(container, data, options);

      setTimeout(() => {
        this.network.moveTo({scale: 2});
      }, 0);

      // network.on("click", function (params) {
      //   var nodeID = this.getNodeAt(params.pointer.DOM)
      //   if(nodeID !== undefined) {
      //     var clickedNode = nodes.get(nodeID);
      //     clickedNode.color = {
      //       border: '#ef4444',
      //       background: '#ef4444',
      //       highlight: {
      //         border: '#ef4444',
      //         background: '#ef4444'
      //       }
      //     }
      //     nodes.update(clickedNode);
      //   }
      // });
    },
  },
  mounted() {
    this.loadCircuit();
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