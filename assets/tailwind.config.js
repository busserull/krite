// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/krite_web.ex",
    "../lib/krite_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        "main-bg": "#ffffff",

        "pri-50": "#E0FCFF",
        "pri-100": "#BEF8FD",
        "pri-200" : "#87EAF2",
        "pri-300" : "#54D1DB",
        "pri-400" : "#38BEC9",
        "pri-500" : "#2CB1BC",
        "pri-600" : "#14919B",
        "pri-700" : "#0E7C86",
        "pri-800" : "#0A6C74",
        "pri-900" : "#044E54",

        "nat-50": "#FAF9F7",
        "nat-100": "#E8E6E1",
        "nat-200": "#D3CEC4",
        "nat-300": "#B8B2A7",
        "nat-400": "#A39E93",
        "nat-500": "#857F72",
        "nat-600": "#625D52",
        "nat-700": "#504A40",
        "nat-800": "#423D33",
        "nat-900": "#27241D",

        "blue-50": "#DCEEFB",
        "blue-100": "#B6E0FE",
        "blue-200": "#84C5F4",
        "blue-300": "#62B0E8",
        "blue-400": "#4098D7",
        "blue-500": "#2680C2",
        "blue-600": "#186FAF",
        "blue-700": "#0F609B",
        "blue-800": "#0A558C",
        "blue-900": "#003E6B",

        "red-50": "#FFEEEE",
        "red-100": "#FACDCD",
        "red-200": "#F29B9B",
        "red-300": "#E66A6A",
        "red-400": "#D64545",
        "red-500": "#BA2525",
        "red-600": "#A61B1B",
        "red-700": "#911111",
        "red-800": "#780A0A",
        "red-900": "#610404",

        "yellow-50": "#FFFAEB",
        "yellow-100": "#FCEFC7",
        "yellow-200": "#F8E3A3",
        "yellow-300": "#F9DA8B",
        "yellow-400": "#F7D070",
        "yellow-500": "#E9B949",
        "yellow-600": "#C99A2E",
        "yellow-700": "#A27C1A",
        "yellow-800": "#7C5E10",
        "yellow-900": "#513C06",

        "teal-50": "#EFFCF6",
        "teal-100": "#C6F7E2",
        "teal-200": "#8EEDC7",
        "teal-300": "#65D6AD",
        "teal-400": "#3EBD93",
        "teal-500": "#27AB83",
        "teal-600": "#199473",
        "teal-700": "#147D64",
        "teal-800": "#0C6B58",
        "teal-900": "#014D40",
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    })
  ]
}
