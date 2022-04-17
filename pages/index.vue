<template>
<main>
  <Header/>
  <Sujiko/>
  <Footer/>
</main>
</template>

<script>
import Vue from "vue";
import { BootstrapVue, IconsPlugin } from 'bootstrap-vue';
Vue.use(BootstrapVue);
Vue.use(IconsPlugin);
export default {
  name: 'IndexPage'
}
</script>
