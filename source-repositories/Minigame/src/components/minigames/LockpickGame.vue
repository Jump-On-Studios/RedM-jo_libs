<template>
  <main class="lockpick-game">
    <section
      v-ui-scaler="'center center'"
      class="lockpick-stage fade-in-bottom"
    >
      <div class="pins-counter">x{{ pinsRemaining }}</div>
      <img
        class="collar"
        src="/img/lockpick/collar.webp"
        alt=""
        draggable="false"
      />
      <div class="cylinder" :style="cylinderStyle"></div>
      <div class="driver" :style="cylinderStyle"></div>
      <div
        class="pin"
        :class="{ damaged: isDamaged, broken: isBroken }"
        :style="pinStyle"
      >
        <div class="pin-top"></div>
        <div class="pin-bottom"></div>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { useEscapeCancel } from "@/composables/useEscapeCancel";
import { sendToLua } from "@/helpers/luaHelper";
import { useLockpickStore } from "@/stores/lockpick";
import { useMinigamesStore } from "@/stores/minigames";

type MinigameStatus = "success" | "failed" | "canceled";

const minigameStore = useMinigamesStore();
const lockpickStore = useLockpickStore();

const minRot = -90;
const maxRot = 90;
const keyRepeatRate = 25;
const mouseSmoothing = 2;
const validKeys = new Set(["w", "a", "s", "d", "arrowleft", "arrowright"]);

const pinRot = ref(0);
const cylRot = ref(0);
const solveDeg = ref(getRandomSolveDeg());
const pinHealth = ref(getConfigNumber("pinHealth", 100));
const pinsRemaining = ref(Math.max(1, Math.floor(getConfigNumber("pins", 1))));
const lastMousePos = ref<number | null>(null);
const pinLastDamaged = ref(0);
const isPushing = ref(false);
const gameOver = ref(false);
const gamePaused = ref(false);
const isDamaged = ref(false);
const isBroken = ref(false);

let cylRotationInterval: number | undefined;
let resetTimeout: number | undefined;

const solvePadding = computed(() => getConfigNumber("solvePadding", 4));
const maxDistFromSolve = computed(() =>
  getConfigNumber("maxDistFromSolve", 45),
);
const pinDamage = computed(() => getConfigNumber("pinDamage", 20));
const pinDamageInterval = computed(() =>
  getConfigNumber("pinDamageInterval", 150),
);
const cylRotSpeed = computed(() => getConfigNumber("cylRotSpeed", 3));

const pinStyle = computed(() => ({
  transform: `rotateZ(${pinRot.value}deg)`,
}));

const cylinderStyle = computed(() => ({
  transform: `rotateZ(${cylRot.value}deg)`,
}));

function getConfigNumber(key: string, fallback: number) {
  const value = lockpickStore.config[key];
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function getRandomSolveDeg() {
  return Math.random() * 180 - 90;
}

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function convertRanges(
  value: number,
  oldMin: number,
  oldMax: number,
  newMin: number,
  newMax: number,
) {
  return ((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin) + newMin;
}

function clearCylinderInterval() {
  if (cylRotationInterval === undefined) return;

  window.clearInterval(cylRotationInterval);
  cylRotationInterval = undefined;
}

function clearResetTimeout() {
  if (resetTimeout === undefined) return;

  window.clearTimeout(resetTimeout);
  resetTimeout = undefined;
}

function onMouseMove(event: MouseEvent) {
  if (lastMousePos.value !== null && !gameOver.value && !gamePaused.value) {
    const pinRotChange = (event.clientX - lastMousePos.value) / mouseSmoothing;
    pinRot.value = clamp(pinRot.value + pinRotChange, minRot, maxRot);
  }

  lastMousePos.value = event.clientX;
}

function onMouseLeave() {
  lastMousePos.value = null;
}

function onKeyDown(event: KeyboardEvent) {
  if (!validKeys.has(event.key.toLowerCase())) return;
  event.preventDefault();

  if (isPushing.value || gameOver.value || gamePaused.value) return;
  pushCylinder();
}

function onKeyUp(event: KeyboardEvent) {
  if (!validKeys.has(event.key.toLowerCase())) return;
  event.preventDefault();

  if (gameOver.value) return;
  unpushCylinder();
}

function pushCylinder() {
  clearCylinderInterval();
  isPushing.value = true;

  let distFromSolve =
    Math.abs(pinRot.value - solveDeg.value) - solvePadding.value;
  distFromSolve = clamp(distFromSolve, 0, maxDistFromSolve.value);

  const cylinderRotationAllowance =
    convertRanges(distFromSolve, 0, maxDistFromSolve.value, 1, 0.02) * maxRot;

  cylRotationInterval = window.setInterval(() => {
    cylRot.value += cylRotSpeed.value;

    if (cylRot.value >= maxRot) {
      cylRot.value = maxRot;
      clearCylinderInterval();
      unlock();
      return;
    }

    if (cylRot.value >= cylinderRotationAllowance) {
      cylRot.value = cylinderRotationAllowance;
      damagePin();
    }
  }, keyRepeatRate);
}

function unpushCylinder() {
  isPushing.value = false;
  clearCylinderInterval();

  cylRotationInterval = window.setInterval(() => {
    cylRot.value = Math.max(cylRot.value - cylRotSpeed.value, 0);

    if (cylRot.value <= 0) {
      cylRot.value = 0;
      clearCylinderInterval();
    }
  }, keyRepeatRate);
}

function damagePin() {
  const now = Date.now();
  if (
    pinLastDamaged.value &&
    now - pinLastDamaged.value <= pinDamageInterval.value
  ) {
    return;
  }

  pinHealth.value -= pinDamage.value;
  pinLastDamaged.value = now;

  isDamaged.value = false;
  window.requestAnimationFrame(() => {
    isDamaged.value = true;
  });

  if (pinHealth.value <= 0) {
    breakPin();
  }
}

function breakPin() {
  if (gamePaused.value || gameOver.value) return;

  gamePaused.value = true;
  isPushing.value = false;
  isBroken.value = true;
  clearCylinderInterval();
  pinsRemaining.value -= 1;
  void sendToLua("jo_minigame:lockpick:pinBroken", {});

  resetTimeout = window.setTimeout(() => {
    if (pinsRemaining.value > 0) {
      resetPin();
      gamePaused.value = false;
      return;
    }

    finish("failed");
  }, 700);
}

function resetPin() {
  cylRot.value = 0;
  pinRot.value = 0;
  pinHealth.value = getConfigNumber("pinHealth", 100);
  lastMousePos.value = null;
  pinLastDamaged.value = 0;
  isDamaged.value = false;
  isBroken.value = false;
}

function unlock() {
  if (gameOver.value) return;
  finish("success");
}

async function finish(status: MinigameStatus) {
  if (gameOver.value) return;

  gameOver.value = true;
  gamePaused.value = true;
  isPushing.value = false;
  clearCylinderInterval();
  clearResetTimeout();

  await sendToLua("jo_minigame:finished", {
    game: "lockpick",
    status,
  });

  minigameStore.hide();
  lockpickStore.reset();
}

useEscapeCancel(() => finish("canceled"));

onMounted(() => {
  window.addEventListener("mousemove", onMouseMove);
  window.addEventListener("mouseleave", onMouseLeave);
  window.addEventListener("keydown", onKeyDown);
  window.addEventListener("keyup", onKeyUp);
});

onBeforeUnmount(() => {
  clearCylinderInterval();
  clearResetTimeout();
  window.removeEventListener("mousemove", onMouseMove);
  window.removeEventListener("mouseleave", onMouseLeave);
  window.removeEventListener("keydown", onKeyDown);
  window.removeEventListener("keyup", onKeyUp);
});
</script>

<style scoped>
.lockpick-game {
  position: fixed;
  inset: 0;
  z-index: 20;
  display: grid;
  place-items: center;
  overflow: hidden;
  cursor: none;
  user-select: none;
}

.lockpick-stage {
  position: relative;
  width: 287.5px;
  height: 287.5px;
  margin-top: 30px;
  overflow: visible;
}

.pins-counter {
  position: absolute;
  bottom: -38px;
  left: 50%;
  z-index: 5;
  min-width: 54px;
  height: 28px;
  display: grid;
  place-items: center;
  transform: translateX(-50%);
  object-fit: fill;
  color: rgb(255 255 255 / 94%);
  background: url("/img/ui/tile.webp");
  background-repeat: no-repeat;
  background-size: 100% 100%;
  font-family: "Crock", serif;
  font-size: 16px;
  font-weight: 400;
  line-height: 1;
  text-align: center;
}

.collar {
  position: relative;
  display: block;
  width: 287.5px;
  height: 287.5px;
  pointer-events: none;
}

.cylinder {
  position: absolute;
  top: 43px;
  left: 43px;
  width: 201px;
  height: 201px;
  background-image: url("/img/lockpick/cylinder.webp");
  background-position: center;
  background-size: cover;
  pointer-events: none;
}

.driver {
  position: absolute;
  top: 164px;
  left: 132px;
  width: 495px;
  height: 241.5px;
  background-image: url("/img/lockpick/driver.webp");
  background-position: center;
  background-size: cover;
  pointer-events: none;
  transform-origin: 3% -3%;
}

.pin {
  position: absolute;
  top: -282px;
  left: 136px;
  width: 20.5px;
  height: 421px;
  transform-origin: 50% 99%;
  pointer-events: none;
}

.pin.damaged {
  animation: pin-jiggle 150ms ease-in-out;
}

.pin-top,
.pin-bottom {
  position: absolute;
  left: 0;
  width: 20.5px;
  height: 210.5px;
  background-position: center;
  background-size: cover;
}

.pin-top {
  top: 0;
  background-image: url("/img/lockpick/pinTop.webp");
}

.pin-bottom {
  top: 210.5px;
  background-image: url("/img/lockpick/pinBott.webp");
}

.pin.broken .pin-top {
  animation: break-pin-top 700ms ease-in forwards;
}

.pin.broken .pin-bottom {
  animation: break-pin-bottom 700ms ease-in forwards;
}

@keyframes pin-jiggle {
  0%,
  100% {
    margin-left: 0;
  }

  35% {
    margin-left: -4px;
  }

  70% {
    margin-left: 3px;
  }
}

@keyframes break-pin-top {
  to {
    opacity: 0;
    transform: translate(-200px, -100px) rotate(-400deg);
  }
}

@keyframes break-pin-bottom {
  to {
    opacity: 0;
    transform: translate(200px, 100px) rotate(400deg);
  }
}
</style>
