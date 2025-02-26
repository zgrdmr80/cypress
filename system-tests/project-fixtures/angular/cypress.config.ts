import { defineConfig } from 'cypress'

export default defineConfig({
  component: {
    experimentalSingleTabRunMode: true,
    videoCompression: false, // turn off video compression for CI
    devServer: {
      framework: 'angular',
      bundler: 'webpack',
      webpackConfig: {
        resolve: {
          alias: {
            '@angular/common/http': require.resolve('@angular/common/http'),
            '@angular/common/testing': require.resolve('@angular/common/testing'),
            '@angular/common': require.resolve('@angular/common'),
            '@angular/core/testing': require.resolve('@angular/core/testing'),
            '@angular/core': require.resolve('@angular/core'),
            '@angular/platform-browser/testing': require.resolve('@angular/platform-browser/testing'),
            '@angular/platform-browser': require.resolve('@angular/platform-browser'),
            '@angular/platform-browser-dynamic/testing': require.resolve('@angular/platform-browser-dynamic/testing'),
            '@angular/platform-browser-dynamic': require.resolve('@angular/platform-browser-dynamic'),
            'zone.js/testing': require.resolve('zone.js/dist/zone-testing'),
            'zone.js': require.resolve('zone.js'),
          },
        },
      },
    },
    specPattern: 'src/**/*.cy.ts',
  },
})
