<template>
  <div class="statistic">
    <div class="label" v-html="getLabel()"></div>
    <div class="value"  v-if="typeof props.stat.value != 'object'" v-html="getValue()">
    </div>
    <div :class="['stat-bars', stat.class]" v-else-if="props.stat.type == 'bar'">
      <div v-for="index in 10" :key="index" :class="['stat-bar',{'active':IsActive(index)},{'possible':IsPossible(index)}]" >
      </div>
    </div>
    <div :class="['stat-bars', props.stat.class]" v-else-if="props.stat.type == 'bar-style'">
      <div v-for="(bar,index) in props.stat.value" :key="index" :class="['stat-bar',bar]">
      </div>
    </div>
    <div :class="['weapon-bar', props.stat.class]" v-else-if="props.stat.type == 'weapon-bar'">
      <div class="box background">
        <img :src="getMenuImage('weapon_stats_bar')">
      </div>
      <div class="box amount" :style="{'clipPath': 'inset(0 '+ (100 - (props.stat.value[0]/props.stat.value[1])*100) + '% 0 0)'}">
        <img :src="getMenuImage('weapon_stats_bar')">
      </div>
    </div>
    <div class="stat-icons" v-if="props.stat.type == 'icon'">
      <div v-for="(icon,index) in props.stat.value" :key="index" class='icon'>
        <img :style=getImageStyle(icon) :src="getImage(icon)" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { useLangStore } from '../../stores/lang';
const lang = useLangStore().lang

const props = defineProps(['stat'])

function getLabel() {
  if (props.stat.translateLabel == false){
    return props.stat.label
  } else {
    return lang(props.stat.label)
  }
}
function getValue() {
  if (props.stat.translateValue == false){
    return props.stat.value
  } else {
    return lang(props.stat.value)
  }
}
function getImage(image) {
  if (typeof image == "object")
    return `./assets/images/icons/${image.icon}.png`
  return `./assets/images/icons/${image}.png`
}
function getMenuImage(image) {
  if (typeof image == "object")
    return `./assets/images/menu/${image.icon}.png`;
  return `./assets/images/menu/${image}.png`;
}
function getImageStyle(icon) {
  if (typeof icon == "object") {
    return {
      opacity: icon.opacity
    }
  }
}
function IsActive(value) {
  return (value <= props.stat.value[0])
}
function IsPossible(value) {
  if (props.stat.value.length == 1) return false
  return (value > props.stat.value[0] && value <= props.stat.value[1])
}
</script>
