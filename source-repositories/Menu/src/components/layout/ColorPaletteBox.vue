<template>
    <div :class="['color-custom color-' + numberColor, props.color.style]" :key="keyUpdate" ref="boxParent">
        <template v-if="tint.palette == 'rgb'">
            <div v-for="index in numberColor" :key="index" :class="'tint tint' + (index - 1)" :style="getStyleTint(index - 1)"></div>
            <div class="border"></div>
        </template>
        <template v-else>
            <div v-for="index in numberColor" :key="index" :class="'tint tint' + (index - 1)" :style="getStyleTint(index - 1)"></div>
            <div class="border"></div>
        </template>
    </div>
</template>

<script setup>
import { computed, inject, onMounted, ref, watch } from 'vue';
const API = inject('API')
const props = defineProps(['color'])
const tint = computed(() => {
    if (props.color.rgb) {
        let rgb = props.color.rgb
        if (typeof rgb == 'string')
            return {
                palette: 'rgb',
                tints: rgb.split(',')
            }
        return {
            palette: 'rgb',
            tints: rgb
        }
    }
    if (props.color.tints) {
        return {
            palette: props.color.palette,
            tints: props.color.tints
        }
    }
    const tints = [props.color.tint0]
    if (Number.isInteger(props.color.tint1))
        tints.push(props.color.tint1)
    if (Number.isInteger(props.color.tint2))
        tints.push(props.color.tint2)
    return {
        palette: props.color.palette,
        tints: tints
    }
})

const numberColor = computed(() => { return tint.value.tints.length })
const url = computed(() => { return props.color.palette && `./assets/images/menu/${API.getPalette(props.color.palette)}.png` })

const max = ref(1)
function calculMax() {
    if (!url.value)
        return
    const img = new Image();
    img.src = url.value;
    img.onload = function () {
        max.value = img.naturalWidth - 1; // Largeur originale de l'image
    };
}

onMounted(() => {
    calculMax()
})
watch(url, () => {
    calculMax()
})

const keyUpdate = computed(() => {
    let key = ""
    if (tint.value.palette)
        key += tint.value.palette
    if (tint.value.tints)
        key += tint.value.tints.reduce((a, b) => a + b, 0)

    return key
})

function getStyleTint(index) {
    if (tint.value.palette == 'rgb')
        return {
            'background-color': tint.value.tints[index]
        }

    let value = tint.value.tints[index]

    let percent = Math.min((value / max.value) * 100, 100)
    return {
        backgroundImage: "url(" + url.value + ")",
        backgroundPosition: percent + "% 0px"
    }
}
</script>

<style lang="scss" scoped>
.color-custom {
    width: 3vh;
    height: 3vh;
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;

    .tint,
    .border {
        position: absolute;
        aspect-ratio: 1 / 1;
        background-size: cover;
        background-repeat: no-repeat;
    }

    &.color-1,
    &.color-3 {
        .tint0 {
            width: 100%;
        }

        .tint1 {
            width: 66%;
        }

        .tint2 {
            width: 33%;
        }
    }

    &.color-2 {
        .tint {
            width: 100%;
        }

        .tint1 {
            -webkit-mask-image: linear-gradient(-45deg, white 50%, transparent 50%);
        }
    }

    .border {
        width: 100%;
        background-image: url('/assets/images/tints/swatch_box.png');
        background-position: center;
    }

    &.vertical-lines {
        display: flex;
        flex-direction: column;

        .tint {
            width: 100%;
            flex: 1;
            -webkit-mask-size: 100%;
        }

        &.color-2 {
            .tint1 {
                -webkit-mask-image: linear-gradient(transparent 50%, white 50%);
            }
        }

        &.color-3 {
            .tint1 {
                -webkit-mask-image: linear-gradient(transparent 33%, white 33%, white 66%, transparent 66%);
            }

            .tint2 {
                -webkit-mask-image: linear-gradient(transparent 66%, white 66%);
            }
        }
    }
}

.sprites .color-custom .border {
    display: none;
}
</style>