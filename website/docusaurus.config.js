module.exports = {
  title: 'Ruby Jard',
  tagline: 'Just Another Ruby Debugger, aims to provide a better experience while debugging Ruby',
  url: 'https://rubyjard.org/',
  baseUrl: '/',
  favicon: 'img/favicon.ico',
  organizationName: 'nguyenquangminh0711',
  projectName: 'ruby_jard',
  themeConfig: {
    navbar: {
      title: 'Ruby Jard',
      logo: {
        alt: 'Ruby Jard Logo',
        src: 'img/logo.png',
      },
      items: [
        {
          to: 'docs/',
          activeBasePath: 'docs',
          label: 'Docs',
          position: 'left',
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
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Getting Started',
              to: 'docs/',
            }
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/nguyenquangminh0711/ruby_jard',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Minh Nguyen - nguyenquangminh0711. Built with Docusaurus.`,
    },
    prism: {
      theme: require('prism-react-renderer/themes/github'),
      defaultLanguage: 'ruby'
    },
    gtag: {
      trackingID: 'UA-92088150-3'
    },
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
