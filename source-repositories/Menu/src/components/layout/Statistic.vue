<template>
  <div class="statistic">
    <div class="label" v-html="getLabel()"></div>
    <PriceDisplay
      v-if="props.stat.type == 'price'"
      class="stat-price"
      :price="props.stat.value"
      right
    />
    <div
      class="value"
      v-else-if="typeof props.stat.value != 'object'"
      v-html="getValue()"
    ></div>
    <div
      :class="['stat-bars', stat.class]"
      v-else-if="props.stat.type == 'bar'"
    >
      <div
        v-for="index in 10"
        :key="index"
        :class="[
          'stat-bar',
          { active: IsActive(index) },
          { possible: IsPossible(index) },
        ]"
      ></div>
    </div>
    <div
      :class="['stat-bars', props.stat.class]"
      v-else-if="props.stat.type == 'bar-style'"
    >
      <div
        v-for="(bar, index) in props.stat.value"
        :key="index"
        :class="['stat-bar', bar]"
      ></div>
    </div>
    <div
      :class="['weapon-bar', props.stat.class]"
      v-else-if="props.stat.type == 'weapon-bar'"
    >
      <div class="box background">
        <img :src="getMenuImage('weapon_stats_bar')" />
      </div>
      <div
        v-for="(bar, index) in weaponBars"
        :key="index"
        class="box amount"
        :style="bar"
      ></div>
    </div>
    <div class="stat-icons" v-if="props.stat.type == 'icon'">
      <div v-for="(icon, index) in props.stat.value" :key="index" class="icon">
        <img :style="getImageStyle(icon)" :src="getImage(icon)" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { useLangStore } from "../../stores/lang";
import PriceDisplay from "./PriceDisplay.vue";
const lang = useLangStore().lang;

const props = defineProps(["stat"]);

const weaponBars = computed(() => {
  const value = props.stat.value;
  let max;
  let bars;

  if (Array.isArray(value)) {
    max = Number(value[1]);
    bars = [{ value: value[0] }];
  } else if (value && typeof value == "object") {
    max = Number(value.max);
    bars = Array.isArray(value.bars) ? value.bars : [];
  } else {
    return [];
  }

  if (!Number.isFinite(max) || max <= 0) return [];

  let previousValue = 0;
  return bars.map((bar) => {
    const currentBar = bar && typeof bar == "object" ? bar : {};
    const rawValue = Number(currentBar.value);
    const currentValue = Number.isFinite(rawValue)
      ? Math.min(Math.max(rawValue, previousValue), max)
      : previousValue;
    const start = (previousValue / max) * 100;
    const end = (currentValue / max) * 100;
    const rawOpacity = Number(currentBar.opacity);
    const opacity =
      currentBar.opacity === undefined || !Number.isFinite(rawOpacity)
        ? 1
        : Math.min(Math.max(rawOpacity, 0), 1);
    const color =
      typeof currentBar.color == "string" && currentBar.color.trim().length > 0
        ? currentBar.color
        : "white";

    previousValue = currentValue;

    return {
      backgroundColor: color,
      opacity,
      clipPath: `inset(0 ${100 - end}% 0 ${start}%)`,
    };
  });
});

function getLabel() {
  if (props.stat.translateLabel == false) {
    return props.stat.label;
  } else {
    return lang(props.stat.label);
  }
}
function getValue() {
  if (props.stat.translateValue == false) {
    return props.stat.value;
  } else {
    return lang(props.stat.value);
  }
}
function getImage(image) {
  if (typeof image == "object")
    return `./assets/images/icons/${image.icon}.png`;
  return `./assets/images/icons/${image}.png`;
}
function getMenuImage(image) {
  if (typeof image == "object") return `./assets/images/menu/${image.icon}.png`;
  return `./assets/images/menu/${image}.png`;
}
function getImageStyle(icon) {
  if (typeof icon == "object") {
    return {
      opacity: icon.opacity,
    };
  }
}
function IsActive(value) {
  return value <= props.stat.value[0];
}
function IsPossible(value) {
  if (props.stat.value.length == 1) return false;
  return value > props.stat.value[0] && value <= props.stat.value[1];
}
</script>

<style scoped lang="scss"></style>
