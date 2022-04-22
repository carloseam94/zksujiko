import { exportCallDataGroth16 } from "./zkproof.js";

export async function sujiko62Calldata(squares, circles, edges, solution) {
  const input = {
    squares: squares,
    circles: circles,
    edges: edges,
    solution: solution
  };
  let dataResult;
  try {
    dataResult = await exportCallDataGroth16(
      input,
      "/sujiko62.wasm",
      "/sujiko62_0001.zkey"
    );
  } catch (error) {
    console.log(error);
  }
  return dataResult;
}