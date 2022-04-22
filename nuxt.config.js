export default {
  // Target: https://go.nuxtjs.dev/config-target
  target: 'static',

  // Global page headers: https://go.nuxtjs.dev/config-head
  head: {
    title: 'zksujiko',
    htmlAttrs: {
      lang: 'en'
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
      { name: 'format-detection', content: 'telephone=no' },
      // Twitter
      {
        hid: "twitter:card",
        name: "twitter:card",
        content: "summary_large_image",
      },
      {
        hid: "twitter:url",
        name: "twitter:url",
        content: "https://zksujiko.netlify.app/",
      },
      {
        hid: "twitter:title",
        name: "twitter:title",
        content: "Zero Knowledge Sujikos",
      },
      {
        hid: "twitter:description",
        name: "twitter:description",
        content: "Solve and contribute with these fascinating puzzles",
      },
      {
        hid: "twitter:image",
        name: "twitter:image",
        content: "https://zksujiko.netlify.app/demo.png",
      },

      // facebook
      {
        hid: "og:site_name",
        property: "og:site_name",
        content: "zksujiko",
      },
      { hid: "og:type", property: "og:type", content: "website" },
      {
        hid: "og:url",
        property: "og:url",
        content: "https://zksujiko.netlify.app/",
      },
      {
        hid: "og:title",
        property: "og:title",
        content: "Zero Knowledge Sujikos",
      },
      {
        hid: "og:description",
        property: "og:description",
        content: "Solve and contribute with these fascinating puzzles",
      },
      {
        hid: "og:image",
        property: "og:image",
        content: "https://zksujiko.netlify.app/demo.png",
      },
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
    ]
  },

  // Global CSS: https://go.nuxtjs.dev/config-css
  css: [
    '@/node_modules/vis-network/styles/vis-network.css',
    '@/node_modules/bootstrap/dist/css/bootstrap.css',
    '@/node_modules/bootstrap-vue/dist/bootstrap-vue.css'
  ],

  // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
  plugins: [
  ],

  // Auto import components: https://go.nuxtjs.dev/config-components
  components: true,

  // Modules for dev and build (recommended): https://go.nuxtjs.dev/config-modules
  buildModules: [
    '@nuxtjs/pwa',
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: [
    // https://go.nuxtjs.dev/bootstrap
    'bootstrap-vue/nuxt',
  ],

  pwa: {
    manifest: {
      lang: "en",
      name: "ZK Sujiko",
      short_name: "zksujiko",
      description: "Solve and contribute with these fascinating puzzles",
      theme_color: "##007bff",
    },
    icon: {
      fileName: "https://zksujiko.netlify.app/demo.png",
    },
  },

  // Build Configuration: https://go.nuxtjs.dev/config-build
  build: {
    babel: {
      presets({ envName }) {
        const envTargets = {
          client: { browsers: ["last 2 Edge versions",
          "last 2 Opera versions",
          "last 2 Safari versions",
          "last 2 Chrome versions",
          "last 2 Firefox versions"] },
          server: { node: "current" },
        }
        return [
          [
            "@nuxt/babel-preset-app",
            {
              targets: envTargets[envName]
            }
          ]
        ]
      }
    }
  },

}
