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
          <div class="progress-indicator" :style="progressIndicatorStyle"></div>
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
  targetStartAngle: number;
  targetArcSize: number;
  targetEnd: number;
  rotationDuration: number;
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
  "flip-in-hor-bottom",
  "flip-in-hor-top",
  "flip-in-ver-right",
  "flip-in-ver-left",
  "flip-in-diag-1-tr",
  "flip-in-diag-1-bl",
  "flip-in-diag-2-br",
  "flip-in-diag-2-tl",
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
  Math.max(1, Math.floor(getConfigNumber("roundCount", 4))),
);
const rotationCount = computed(() =>
  Math.max(1, Math.floor(getConfigNumber("rotationCount", 1))),
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
    transparent ${currentStep.value.targetStartAngle}deg,
    #000 ${currentStep.value.targetStartAngle}deg,
    #000 ${currentStep.value.targetEnd}deg,
    transparent ${currentStep.value.targetEnd}deg,
    transparent 360deg
  )`,
  WebkitMaskImage: `conic-gradient(
    from 0deg,
    transparent 0deg,
    transparent ${currentStep.value.targetStartAngle}deg,
    #000 ${currentStep.value.targetStartAngle}deg,
    #000 ${currentStep.value.targetEnd}deg,
    transparent ${currentStep.value.targetEnd}deg,
    transparent 360deg
  )`,
}));

const indicatorStyle = computed(() => ({
  transform: `translateX(-50%) rotate(${currentAngle.value % 360}deg)`,
}));

const failureAngle = computed(
  () => (rotationCount.value - 1) * 360 + currentStep.value.targetEnd,
);

const progressIndicatorStyle = computed(() => {
  const progress = Math.min(
    Math.max(currentAngle.value / failureAngle.value, 0),
    1,
  );
  const progressAngle = progress * 360;

  return {
    background: `conic-gradient(
      from 0deg,
      rgb(255 255 255) 0deg,
      rgb(255 255 255) ${progressAngle}deg,
      transparent ${progressAngle}deg,
      transparent 360deg
    )`,
  };
});

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

function getAllowedKeys() {
  const allowedKeys = qteStore.config.allowedKeys;
  if (!Array.isArray(allowedKeys)) return defaultKeys;

  const validKeys = allowedKeys
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
  const targetStartRange = getRangeConfig("targetStartAngle", {
    min: 100,
    max: 300,
  });
  const targetArcSizeRange = getRangeConfig("targetArcSize", {
    min: 50,
    max: 60,
  });
  const rotationDurationRange = getRangeConfig("rotationDuration", {
    min: 2000,
    max: 3000,
  });

  const targetStartAngle = Math.min(
    Math.max(randomNumber(targetStartRange.min, targetStartRange.max), 0),
    359,
  );
  const maxTargetArcSize = Math.max(1, 360 - targetStartAngle);
  const targetArcSize = Math.min(
    Math.max(randomNumber(targetArcSizeRange.min, targetArcSizeRange.max), 1),
    maxTargetArcSize,
  );

  return {
    key: randomItem(getAllowedKeys()),
    targetStartAngle,
    targetArcSize,
    targetEnd: targetStartAngle + targetArcSize,
    rotationDuration: Math.max(
      100,
      randomNumber(rotationDurationRange.min, rotationDurationRange.max),
    ),
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
  currentAngle.value = (elapsed / currentStep.value.rotationDuration) * 360;

  if (currentAngle.value > failureAngle.value) {
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

  const rotationAngle = currentAngle.value % 360;
  const success =
    rotationAngle >= currentStep.value.targetStartAngle &&
    rotationAngle <= currentStep.value.targetEnd;

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

  feedbackTimeout = window.setTimeout(
    () => {
      feedbackTimeout = undefined;
      isFeedbackPlaying.value = false;
      feedbackState.value = null;
      onComplete();
    },
    state === "success"
      ? successFeedbackDelay.value
      : failureFeedbackDelay.value,
  );
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
  /* background: rgb(12 13 15 / 66%); */
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

.qte-circle .progress-indicator {
  position: absolute;
  inset: -3px;
  z-index: 2;
  border-radius: 50%;
  filter: drop-shadow(0 0 7px rgb(255 255 255 / 45%));
  mask-image: radial-gradient(
    farthest-side,
    transparent calc(100% - 3px),
    #000 calc(100% - 2px)
  );
  -webkit-mask-image: radial-gradient(
    farthest-side,
    transparent calc(100% - 3px),
    #000 calc(100% - 2px)
  );
  pointer-events: none;
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
