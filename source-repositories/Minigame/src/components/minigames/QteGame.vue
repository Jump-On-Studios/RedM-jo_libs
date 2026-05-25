<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { sendToLua } from "@/helpers/luaHelper";
import { useMinigamesStore } from "@/stores/minigames";
import { useQteStore } from "@/stores/qte";

interface RangeConfig {
  min?: number;
  max?: number;
}

interface QteStep {
  key: string;
  targetStart: number;
  targetSize: number;
  targetEnd: number;
  duration: number;
}

const minigameStore = useMinigamesStore();
const qteStore = useQteStore();

const defaultKeys = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

const currentStep = ref<QteStep>(createStep());
const currentRound = ref(1);
const currentAngle = ref(0);
const isFinished = ref(false);
const isRoundWon = ref(false);

let animationFrame: number | undefined;
let roundTimeout: number | undefined;
let roundStartTime = 0;

const totalRounds = computed(() =>
  Math.max(1, Math.floor(getConfigNumber("count", 4))),
);

const circleStyle = computed(() => ({
  background: `conic-gradient(
    from 0deg,
    #31363d 0deg,
    #31363d ${currentStep.value.targetStart}deg,
    #2fbf71 ${currentStep.value.targetStart}deg,
    #2fbf71 ${currentStep.value.targetEnd}deg,
    #31363d ${currentStep.value.targetEnd}deg,
    #31363d 360deg
  )`,
}));

const indicatorStyle = computed(() => ({
  transform: `translateX(-50%) rotate(${currentAngle.value}deg)`,
}));

function getConfigNumber(key: string, fallback: number) {
  const value = qteStore.config[key];
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function getRangeConfig(key: string, fallback: Required<RangeConfig>) {
  const value = qteStore.config[key];
  if (!value || typeof value !== "object") return fallback;

  const range = value as RangeConfig;
  const min =
    typeof range.min === "number" && Number.isFinite(range.min)
      ? range.min
      : fallback.min;
  const max =
    typeof range.max === "number" && Number.isFinite(range.max)
      ? range.max
      : fallback.max;

  return {
    min: Math.min(min, max),
    max: Math.max(min, max),
  };
}

function getKeys() {
  const keys = qteStore.config.keys;
  if (!Array.isArray(keys)) return defaultKeys;

  const validKeys = keys
    .filter((key) => typeof key === "string" && key.trim().length > 0)
    .map((key) => key.trim().toUpperCase());

  return validKeys.length > 0 ? validKeys : defaultKeys;
}

function randomNumber(min: number, max: number) {
  return Math.random() * (max - min) + min;
}

function randomItem<T>(items: T[]) {
  return items[Math.floor(Math.random() * items.length)];
}

function createStep(): QteStep {
  const targetStartRange = getRangeConfig("targetStart", { min: 60, max: 140 });
  const targetSizeRange = getRangeConfig("targetSize", { min: 35, max: 60 });
  const durationRange = getRangeConfig("duration", { min: 1200, max: 1600 });

  const targetStart = Math.min(
    Math.max(randomNumber(targetStartRange.min, targetStartRange.max), 0),
    359,
  );
  const maxTargetSize = Math.max(1, 360 - targetStart);
  const targetSize = Math.min(
    Math.max(randomNumber(targetSizeRange.min, targetSizeRange.max), 1),
    maxTargetSize,
  );

  return {
    key: randomItem(getKeys()),
    targetStart,
    targetSize,
    targetEnd: targetStart + targetSize,
    duration: Math.max(100, randomNumber(durationRange.min, durationRange.max)),
  };
}

function startRound() {
  currentAngle.value = 0;
  isRoundWon.value = false;
  currentStep.value = createStep();
  roundStartTime = performance.now();
  animationFrame = window.requestAnimationFrame(updateAngle);
}

function updateAngle(time: number) {
  if (isFinished.value || isRoundWon.value) return;

  const elapsed = time - roundStartTime;
  currentAngle.value = Math.min(
    (elapsed / currentStep.value.duration) * 360,
    360,
  );

  if (currentAngle.value > currentStep.value.targetEnd) {
    finish(false);
    return;
  }

  animationFrame = window.requestAnimationFrame(updateAngle);
}

function onKeyDown(event: KeyboardEvent) {
  if (isFinished.value || isRoundWon.value) return;

  const pressedKey = event.key.toUpperCase();
  if (pressedKey.length !== 1) return;

  event.preventDefault();

  if (pressedKey !== currentStep.value.key) {
    finish(false);
    return;
  }

  const success =
    currentAngle.value >= currentStep.value.targetStart &&
    currentAngle.value <= currentStep.value.targetEnd;

  if (!success) {
    finish(false);
    return;
  }

  completeRound();
}

function completeRound() {
  isRoundWon.value = true;
  clearAnimation();

  if (currentRound.value >= totalRounds.value) {
    finish(true);
    return;
  }

  roundTimeout = window.setTimeout(() => {
    currentRound.value += 1;
    startRound();
  }, 250);
}

function clearAnimation() {
  if (animationFrame === undefined) return;

  window.cancelAnimationFrame(animationFrame);
  animationFrame = undefined;
}

function clearRoundTimeout() {
  if (roundTimeout === undefined) return;

  window.clearTimeout(roundTimeout);
  roundTimeout = undefined;
}

async function finish(success: boolean) {
  if (isFinished.value) return;

  isFinished.value = true;
  clearAnimation();
  clearRoundTimeout();

  await sendToLua("jo_minigame:finished", {
    game: "qte",
    success,
  });

  minigameStore.hide();
  qteStore.reset();
}

onMounted(() => {
  window.addEventListener("keydown", onKeyDown);
  startRound();
});

onBeforeUnmount(() => {
  clearAnimation();
  clearRoundTimeout();
  window.removeEventListener("keydown", onKeyDown);
});
</script>

<template>
  <main class="qte-game">
    <section v-ui-scaler="'center center'" class="qte-panel">
      <div class="round-counter">{{ currentRound }} / {{ totalRounds }}</div>
      <div class="qte-circle">
        <div class="track" :style="circleStyle"></div>
        <div class="inner-circle">
          <span>{{ currentStep.key }}</span>
        </div>
        <div class="indicator" :style="indicatorStyle"></div>
      </div>
    </section>
  </main>
</template>

<style scoped>
@font-face {
  font-family: "Crock";
  src: url("/fonts/crock.ttf") format("truetype");
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}

.qte-game {
  position: fixed;
  inset: 0;
  z-index: 20;
  display: grid;
  place-items: center;
  color: #f7f3ea;
  background: rgb(12 13 15 / 66%);
  font-family:
    Inter,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
}

.qte-panel {
  display: grid;
  gap: 18px;
  place-items: center;
}

.round-counter {
  min-width: 72px;
  padding: 6px 10px;
  border-radius: 6px;
  color: #f7f3ea;
  background: rgb(0 0 0 / 55%);
  font-size: 18px;
  font-weight: 700;
  text-align: center;
}

.qte-circle {
  position: relative;
  width: 220px;
  height: 220px;
  border: 3px solid rgb(255 255 255 / 20%);
  border-radius: 50%;
  background: #31363d;
  box-shadow: 0 16px 42px rgb(0 0 0 / 35%);
}

.track {
  position: absolute;
  inset: 0px;
  z-index: 1;
  border-radius: 50%;
  overflow: hidden;
}

.inner-circle {
  position: absolute;
  inset: 58px;
  z-index: 4;
  display: grid;
  place-items: center;
  border-radius: 50%;
  color: #101418;
  background: url("/img/qte/white_circle.png") center / cover no-repeat;
  font-family: "Crock", serif;
  font-size: 54px;
  font-weight: bold;
}

.indicator {
  position: absolute;
  top: -28px;
  left: 50%;
  z-index: 3;
  width: 5px;
  height: 138px;
  border-radius: 999px;
  background: #f5f5f5;
  box-shadow: 0 0 12px rgb(255 255 255 / 70%);
  transform-origin: 50% 138px;
}
</style>
