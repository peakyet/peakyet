// smoke_dom.mjs — runs the page's inline <script> under a minimal DOM stub in
// Node and fires every control, to catch reference/type errors in the UI glue.
// (The pure math inside the same script is separately verified against the
// Python implementation by test_demo.mjs.)
import { readFileSync } from "node:fs";

const html = readFileSync(new URL("../francis-qr-step.html", import.meta.url), "utf8");

// --- extract the last inline <script> (the app IIFE) ---
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
if (scripts.length === 0) throw new Error("no inline script found");
const code = scripts[scripts.length - 1][1];

// --- minimal DOM stub ---
function makeEl(tag) {
  return {
    tag, id: "", className: "", textContent: "", innerHTML: "", title: "",
    children: [], _handlers: {},
    appendChild(c) { this.children.push(c); return c; },
    replaceWith() { /* no-op: ids stay attached to the stub object */ },
    addEventListener(t, fn) { (this._handlers[t] = this._handlers[t] || []).push(fn); },
    setAttribute() {},
    classList: { toggle() {}, contains() { return false; } },
    getBoundingClientRect() { return { top: 0, height: 0 }; },
    querySelector() { return null; },
    fire(t, ev) { (this._handlers[t] || []).forEach(fn => fn(ev || {})); },
  };
}
const els = {};
const documentStub = {
  getElementById(id) { if (!els[id]) els[id] = makeEl("div"); return els[id]; },
  createElement(tag) { return makeEl(tag); },
  querySelector() { return null; },
  querySelectorAll() { return []; },
  body: makeEl("body"),
};
const windowStub = { addEventListener() {}, innerHeight: 800 };

// --- run the page script ---
const fn = new Function("document", "window", code);
try {
  fn(documentStub, windowStub);
  console.log("script evaluated without errors");
} catch (e) {
  console.error("EVAL ERROR:", e.message);
  process.exit(1);
}

// --- exercise every control ---
function click(id) { els[id].fire("click"); }
function setVal(id, v) { els[id].value = v; }

try {
  click("b-shifts");            // plans the step -> renderDemo (stage 0)
  click("b-g1");                // first reflector
  click("b-chase");             // one chase step
  click("b-chaseall");          // finish the chase
  click("b-compare");           // run explicit comparison
  const status = els["demo-status"].innerHTML;
  const m = status.match(/(\d\.\d+e-1[45])/);
  if (!m) {
    console.error("compare residual not found in demo-status:", status);
    process.exit(1);
  }
  console.log("compare residual reported as", m[1], "(expected ~3.2e-15 .. 6.2e-15)");
  click("b-iterate");           // 12 iterations -> renderIterTable
  click("b-reset");             // back to the initial matrix
  els["refl-angle"].fire("input", { target: { value: "-40" } });
  els["refl-sign"].fire("change", { target: { value: "naive" } });
  els["refl-sign"].fire("change", { target: { value: "lapack" } });
  console.log("all controls fired without errors");
} catch (e) {
  console.error("CONTROL ERROR:", e.stack || e.message);
  process.exit(1);
}

console.log("SMOKE TEST PASSED");
