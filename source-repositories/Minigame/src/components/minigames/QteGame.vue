<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { useEscapeCancel } from "@/composables/useEscapeCancel";
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

type MinigameStatus = "success" | "failed" | "canceled";

const minigameStore = useMinigamesStore();
const qteStore = useQteStore();

const defaultKeys = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
const defaultQteIntroDelay = 300;
const defaultQteSuccessFeedbackDelay = 450;
const defaultQteFailureFeedbackDelay = 550;
const defaultQteRoundDelay = 100;
const entryAnimationClasses = [
  "slide-in-blurred-top",
  "slide-in-blurred-tr",
  "slide-in-blurred-right",
  "slide-in-blurred-br",
  "slide-in-blurred-bottom",
  "slide-in-blurred-bl",
  "slide-in-blurred-left",
  "slide-in-blurred-tl",
];

const currentStep = ref<QteStep>(createStep());
const currentRound = ref(1);
const currentAngle = ref(0);
const isFinished = ref(false);
const isRoundWon = ref(false);
const isIntroPlaying = ref(true);
const isFeedbackPlaying = ref(false);
const feedbackState = ref<"success" | "failure" | null>(null);
const feedbackKey = ref(0);
const entryAnimationClass = ref(randomItem(entryAnimationClasses));
const entryAnimationKey = ref(0);

let animationFrame: number | undefined;
let feedbackTimeout: number | undefined;
let introTimeout: number | undefined;
let roundTimeout: number | undefined;
let roundStartTime = 0;

const totalRounds = computed(() =>
  Math.max(1, Math.floor(getConfigNumber("count", 4))),
);
const introDelay = computed(() =>
  getConfigDelay("introDelay", defaultQteIntroDelay),
);
const successFeedbackDelay = computed(() =>
  getConfigDelay("successDelay", defaultQteSuccessFeedbackDelay),
);
const failureFeedbackDelay = computed(() =>
  getConfigDelay("failureDelay", defaultQteFailureFeedbackDelay),
);
const roundDelay = computed(() =>
  getConfigDelay("roundDelay", defaultQteRoundDelay),
);

const circleStyle = computed(() => ({
  maskImage: `conic-gradient(
    from 0deg,
    transparent 0deg,
    transparent ${currentStep.value.targetStart}deg,
    #000 ${currentStep.value.targetStart}deg,
    #000 ${currentStep.value.targetEnd}deg,
    transparent ${currentStep.value.targetEnd}deg,
    transparent 360deg
  )`,
  WebkitMaskImage: `conic-gradient(
    from 0deg,
    transparent 0deg,
    transparent ${currentStep.value.targetStart}deg,
    #000 ${currentStep.value.targetStart}deg,
    #000 ${currentStep.value.targetEnd}deg,
    transparent ${currentStep.value.targetEnd}deg,
    transparent 360deg
  )`,
}));

const indicatorStyle = computed(() => ({
  transform: `translateX(-50%) rotate(${currentAngle.value}deg)`,
}));

function getConfigNumber(key: string, fallback: number) {
  const value = qteStore.config[key];
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function getConfigDelay(key: string, fallback: number) {
  return Math.max(0, Math.floor(getConfigNumber(key, fallback)));
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
  const targetStartRange = getRangeConfig("targetStart", { min: 100, max: 300 });
  const targetSizeRange = getRangeConfig("targetSize", { min: 50, max: 60 });
  const durationRange = getRangeConfig("duration", { min: 2000, max: 3000 });

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

function playRoundIntro(shouldCreateStep = true) {
  clearAnimation();
  clearIntroTimeout();
  clearFeedbackTimeout();

  currentAngle.value = 0;
  isRoundWon.value = false;
  isFeedbackPlaying.value = false;
  feedbackState.value = null;
  if (shouldCreateStep) currentStep.value = createStep();
  isIntroPlaying.value = true;
  entryAnimationClass.value = randomItem(entryAnimationClasses);
  entryAnimationKey.value += 1;

  introTimeout = window.setTimeout(() => {
    introTimeout = undefined;
    isIntroPlaying.value = false;
    startRound();
  }, introDelay.value);
}

function startRound() {
  roundStartTime = performance.now();
  animationFrame = window.requestAnimationFrame(updateAngle);
}

function updateAngle(time: number) {
  if (isFinished.value || isRoundWon.value || isFeedbackPlaying.value) return;

  const elapsed = time - roundStartTime;
  currentAngle.value = Math.min(
    (elapsed / currentStep.value.duration) * 360,
    360,
  );

  if (currentAngle.value > currentStep.value.targetEnd) {
    failRound();
    return;
  }

  animationFrame = window.requestAnimationFrame(updateAngle);
}

function onKeyDown(event: KeyboardEvent) {
  if (
    isFinished.value ||
    isRoundWon.value ||
    isIntroPlaying.value ||
    isFeedbackPlaying.value
  ) {
    return;
  }

  const pressedKey = event.key.toUpperCase();
  if (pressedKey.length !== 1) return;

  event.preventDefault();

  if (pressedKey !== currentStep.value.key) {
    failRound();
    return;
  }

  const success =
    currentAngle.value >= currentStep.value.targetStart &&
    currentAngle.value <= currentStep.value.targetEnd;

  if (!success) {
    failRound();
    return;
  }

  completeRound();
}

function completeRound() {
  isRoundWon.value = true;
  clearAnimation();
  playFeedback("success", () => {
    if (currentRound.value >= totalRounds.value) {
      finish("success");
      return;
    }

    roundTimeout = window.setTimeout(() => {
      roundTimeout = undefined;
      currentRound.value += 1;
      playRoundIntro();
    }, roundDelay.value);
  });
}

function failRound() {
  clearAnimation();
  playFeedback("failure", () => finish("failed"));
}

function playFeedback(state: "success" | "failure", onComplete: () => void) {
  clearFeedbackTimeout();

  isFeedbackPlaying.value = true;
  feedbackState.value = state;
  feedbackKey.value += 1;

  feedbackTimeout = window.setTimeout(() => {
    feedbackTimeout = undefined;
    isFeedbackPlaying.value = false;
    feedbackState.value = null;
    onComplete();
  }, state === "success" ? successFeedbackDelay.value : failureFeedbackDelay.value);
}

function clearAnimation() {
  if (animationFrame === undefined) return;

  window.cancelAnimationFrame(animationFrame);
  animationFrame = undefined;
}

function clearIntroTimeout() {
  if (introTimeout === undefined) return;

  window.clearTimeout(introTimeout);
  introTimeout = undefined;
}

function clearFeedbackTimeout() {
  if (feedbackTimeout === undefined) return;

  window.clearTimeout(feedbackTimeout);
  feedbackTimeout = undefined;
}

function clearRoundTimeout() {
  if (roundTimeout === undefined) return;

  window.clearTimeout(roundTimeout);
  roundTimeout = undefined;
}

async function finish(status: MinigameStatus) {
  if (isFinished.value) return;

  isFinished.value = true;
  clearAnimation();
  clearIntroTimeout();
  clearFeedbackTimeout();
  clearRoundTimeout();

  await sendToLua("jo_minigame:finished", {
    game: "qte",
    status,
  });

  minigameStore.hide();
  qteStore.reset();
}

useEscapeCancel(() => finish("canceled"));

onMounted(() => {
  window.addEventListener("keydown", onKeyDown);
  playRoundIntro(false);
});

onBeforeUnmount(() => {
  clearAnimation();
  clearIntroTimeout();
  clearFeedbackTimeout();
  clearRoundTimeout();
  window.removeEventListener("keydown", onKeyDown);
});
</script>

<template>
  <main class="qte-game">
    <section v-ui-scaler="'center center'" class="qte-panel">
      <div class="round-counter">{{ currentRound }} / {{ totalRounds }}</div>
      <div
        :key="entryAnimationKey"
        class="qte-entry"
        :class="entryAnimationClass"
      >
        <div
          class="qte-circle"
          :class="{
            'qte-feedback-success': feedbackState === 'success',
            'qte-feedback-failure': feedbackState === 'failure',
          }"
        >
          <div
            v-if="feedbackState"
            :key="feedbackKey"
            class="feedback-halo"
            :class="`feedback-halo-${feedbackState}`"
          ></div>
          <div
            v-if="feedbackState"
            :key="`${feedbackKey}-ripple`"
            class="feedback-ripple"
            :class="`feedback-ripple-${feedbackState}`"
          ></div>
          <div class="track" :style="circleStyle"></div>
          <div class="inner-circle">
            <span>{{ currentStep.key }}</span>
          </div>
          <div class="indicator" :style="indicatorStyle"></div>
        </div>
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
  background: url("/img/qte/black_circle.png") center / cover no-repeat;
  box-shadow: 0 16px 42px rgb(0 0 0 / 35%);
}

.qte-entry {
  position: relative;
}

.track {
  position: absolute;
  inset: 0px;
  z-index: 1;
  border-radius: 50%;
  background: transparent;
  overflow: hidden;
}

.track::before {
  position: absolute;
  inset: 0;
  content: "";
  background: repeating-linear-gradient(
    45deg,
    rgb(255 255 255 / 76%) 0 2px,
    transparent 3px 6px
  );
  background-color: transparent;
  mask-image: radial-gradient(
    circle,
    transparent 0 32%,
    rgb(0 0 0 / 28%) 36%,
    #000 44% 100%
  );
  -webkit-mask-image: radial-gradient(
    circle,
    transparent 0 32%,
    rgb(0 0 0 / 28%) 36%,
    #000 44% 100%
  );
  overflow: hidden;
}

.inner-circle {
  position: absolute;
  inset: 56px;
  z-index: 4;
  display: grid;
  place-items: center;
  border-radius: 50%;
  color: #222;
  background: url("/img/qte/white_circle.png") center / cover no-repeat;
  font-family: "Crock", serif;
  font-size: 54px;
  font-weight: 400;
}

.feedback-halo,
.feedback-ripple {
  position: absolute;
  inset: 0;
  z-index: 5;
  border-radius: 50%;
  pointer-events: none;
}

.feedback-ripple {
  inset: 56px;
  z-index: 6;
}

.indicator {
  position: absolute;
  top: -28px;
  left: 50%;
  z-index: 3;
  width: 4px;
  height: 138px;
  border-radius: 999px;
  background: rgb(255 255 255 / 92%);
  box-shadow: 0 0 7px rgb(255 255 255 / 45%);
  transform-origin: 50% 138px;
}
</style>
