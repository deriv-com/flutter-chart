import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  // By default, Docusaurus generates a sidebar from the docs folder structure
  tutorialSidebar: [
    {
      type: 'category',
      label: 'Getting Started',
      items: [
        'intro',
        'deriv_chart_widget_usage',
      ],
    },
    {
      type: 'category',
      label: 'Core Concepts',
      items: [
        'how_chart_lib_works',
      ],
    },
    {
      type: 'category',
      label: 'Features',
      items: [
        'drawing_tools',
      ],
    },
    {
      type: 'category',
      label: 'Contributing',
      items: [
        'contribution',
      ],
    },
  ],
};

export default sidebars;
