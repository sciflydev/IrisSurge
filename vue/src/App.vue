<template>
  <div class="grid grid-cols-12 container mx-auto px-4 flex gap-8" style="width: 1200px">
    <div class="flex col-span-12 grid grid-cols-12 gap-8">
      <div class="bg-neutral-800 rounded-lg p-4 col-span-12 gap-8">
        <h1 class="text-2xl font-sans font-bold" style="text-align: center">
          Iris flower clustering
        </h1>
      </div>
    </div>

    <div class="col-span-12 grid grid-cols-12 gap-8">
      <div class="col-span-10 grid grid-cols-2 gap-8">
        <div class="bg-neutral-800 rounded-lg p-4">
          <div class="relative w-full pb-[100%]">
            <div class="absolute inset-0">
              <h5 class="text-center">Species</h5>
              <ScatterChart
                v-if="data_clusters.value"
                :chartData="speciesChartData"
                :options="chartOptions"
              />
            </div>
          </div>
        </div>
        <div class="bg-neutral-800 rounded-lg p-4">
          <div class="relative w-full pb-[100%]">
            <div class="absolute inset-0">
              <h5 class="text-center">K-means clusters</h5>
              <ScatterChart
                v-if="data_clusters.value"
                :key="no_of_clusters.value"
                :chartData="kmeansChartData"
                :options="chartOptions"
              />
            </div>
          </div>
        </div>
      </div>

      <div class="col-span-2 flex flex-col gap-6 bg-neutral-800 rounded-lg p-4">
        <div>
          <label class="block mb-2 pb-2">Number of clusters</label>
          <div class="flex gap-4">
            <UBadge :label="no_of_clusters.value" class="w-8 center" />
            <USlider v-model.number="no_of_clusters.value" :min="2" :max="6" />
          </div>
        </div>

        <div>
          <label class="block mb-2 pb-2">Iterations</label>
          <div class="flex gap-4">
            <UBadge :label="no_of_iterations.value" class="w-8 center" />
            <USlider v-model.number="no_of_iterations.value" :min="5" :max="99" />
          </div>
        </div>

        <div>
          <label class="block mb-2 pb-2">X feature</label>
          <USelect v-model="selectedXFeature" :items="featureOptions" class="w-full" />
        </div>

        <div>
          <label class="block mb-2 pb-2">Y feature</label>
          <USelect v-model="selectedYFeature" :items="featureOptions" class="w-full" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ScatterChart } from 'vue-chart-3'
import { Chart, registerables } from 'chart.js'
import { computed, ref } from 'vue'
import { useSurge } from 'surgejs'

// Register Chart.js components
Chart.register(...registerables)

const { data_clusters, no_of_clusters, no_of_iterations, isLoading } = useSurge(
  ['data_clusters', 'no_of_clusters', 'no_of_iterations'],
  {
    port: process.env.NODE_ENV === 'production' ? '443' : '8080',
  },
) as any

const featureOptions = ref([
  { label: 'Sepal Length', value: 'SepalLength' },
  { label: 'Sepal Width', value: 'SepalWidth' },
  { label: 'Petal Length', value: 'PetalLength' },
  { label: 'Petal Width', value: 'PetalWidth' },
])

const selectedXFeature = ref('SepalLength')
const selectedYFeature = ref('SepalWidth')

const columns = [
  { key: 'sepalLength', label: 'Sepal Length' },
  { key: 'sepalWidth', label: 'Sepal Width' },
  { key: 'petalLength', label: 'Petal Length' },
  { key: 'petalWidth', label: 'Petal Width' },
  { key: 'cluster', label: 'Cluster' },
]

const SPECIES_COLORS = {
  setosa: 'rgba(54, 162, 235, 0.5)', // blue
  versicolor: 'rgba(255, 99, 132, 0.5)', // pink
  virginica: 'rgba(75, 192, 192, 0.5)', // teal
}

const speciesVectors = computed(() => ({
  setosa: {
    data: data_clusters.value?.Species.map((s, i) =>
      s === 'setosa'
        ? {
            x: data_clusters.value[selectedXFeature.value][i],
            y: data_clusters.value[selectedYFeature.value][i],
          }
        : null,
    ).filter(Boolean),
  },
  versicolor: {
    data: data_clusters.value?.Species.map((s, i) =>
      s === 'versicolor'
        ? {
            x: data_clusters.value[selectedXFeature.value][i],
            y: data_clusters.value[selectedYFeature.value][i],
          }
        : null,
    ).filter(Boolean),
  },
  virginica: {
    data: data_clusters.value?.Species.map((s, i) =>
      s === 'virginica'
        ? {
            x: data_clusters.value[selectedXFeature.value][i],
            y: data_clusters.value[selectedYFeature.value][i],
          }
        : null,
    ).filter(Boolean),
  },
}))

const kmeansVectors = computed(() =>
  Array.from({ length: no_of_clusters.value }, (_, k) =>
    data_clusters.value?.Cluster.map((c, i) =>
      c <= no_of_clusters.value && c === k + 1
        ? {
            x: data_clusters.value[selectedXFeature.value][i],
            y: data_clusters.value[selectedYFeature.value][i],
          }
        : null,
    ).filter(Boolean),
  ),
)

const speciesChartData = computed(() => ({
  datasets: [
    {
      label: 'setosa',
      data: speciesVectors.value.setosa.data,
      backgroundColor: SPECIES_COLORS.setosa,
    },
    {
      label: 'versicolor',
      data: speciesVectors.value.versicolor.data,
      backgroundColor: SPECIES_COLORS.versicolor,
    },
    {
      label: 'virginica',
      data: speciesVectors.value.virginica.data,
      backgroundColor: SPECIES_COLORS.virginica,
    },
  ],
}))

const kmeansChartData = computed(() => ({
  datasets: kmeansVectors.value.map((data, k) => ({
    label: (k + 1).toString(),
    data: data,
    backgroundColor:
      k < 3
        ? Object.values(SPECIES_COLORS)[k]
        : `hsla(${(k * 360) / no_of_clusters.value}, 70%, 60%, 0.5)`,
  })),
}))

const chartOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    x: {
      title: {
        display: true,
        text: selectedXFeature.value.replace(/([A-Z])/g, ' $1').trim(),
        color: 'white',
      },
      ticks: {
        color: 'white',
      },
      grid: {
        color: 'rgba(255, 255, 255, 0.1)',
      },
    },
    y: {
      title: {
        display: true,
        text: selectedYFeature.value.replace(/([A-Z])/g, ' $1').trim(),
        color: 'white',
      },
      ticks: {
        color: 'white',
      },
      grid: {
        color: 'rgba(255, 255, 255, 0.1)',
      },
    },
  },
  plugins: {
    legend: {
      labels: {
        color: 'white',
      },
    },
  },
}))
</script>

<style lang="css">
.truncate {
  margin: auto;
}
</style>
