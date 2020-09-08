module.exports = {
  title: 'Ruby Jard',
  tagline: 'Just Another Ruby Debugger. Provide a rich Terminal UI that visualizes everything your need, navigates your program with pleasure, stops at matter places only, reduces manual and mental efforts. You can now focus on real debugging.',
  url: 'https://rubyjard.org/',
  baseUrl: '/',
  favicon: 'img/logo/favicon.png',
  organizationName: 'nguyenquangminh0711',
  projectName: 'ruby_jard',
  themeConfig: {
    image: 'img/thumbnail.jpg',
    navbar: {
      title: 'Ruby Jard',
      logo: {
        alt: 'Ruby Jard Logo',
        src: 'img/logo/logo-small.png',
      },
      items: [
        {
          to: 'docs/',
          activeBasePath: 'docs',
          label: 'Docs',
          position: 'right',
        },
        {
          href: 'https://github.com/nguyenquangminh0711/ruby_jard',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `Copyright © ${new Date().getFullYear()} Minh Nguyen - nguyenquangminh0711. Built with Docusaurus.`
    },
    prism: {
      defaultLanguage: 'ruby',
      additionalLanguages: ['ruby'],
    },
    gtag: {
      trackingID: 'UA-92088150-3'
    },
    colorMode: {
      defaultMode: 'light',
      disableSwitch: true
    }
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/nguyenquangminh0711/ruby_jard/edit/master/website/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
