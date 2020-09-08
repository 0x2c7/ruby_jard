import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './styles.module.css';
import Highlight, { defaultProps } from "prism-react-renderer";

function GithubButton() {
  return (
    <div className={clsx(styles.github, 'button--lg')}>
      <iframe src="https://ghbtns.com/github-btn.html?user=nguyenquangminh0711&amp;repo=ruby_jard&amp;type=star&amp;count=true&amp;size=large" scrolling="0" title="GitHub Stars" width="140" height="30" frameborder="0"></iframe>
    </div>
  )
}

function CodeHighlight({code, language}) {
  return (
    <Highlight {...defaultProps} code={code} language={language}>
      {({ className, style, tokens, getLineProps, getTokenProps }) => (
        <pre className={className} style={style}>
          {tokens.map((line, i) => (
            <div {...getLineProps({ line, key: i })}>
              {line.map((token, key) => (
                <span {...getTokenProps({ token, key })} />
              ))}
            </div>
          ))}
        </pre>
      )}
    </Highlight>
  )
}

function Home() {
  const context = useDocusaurusContext();
  const {siteConfig = {}} = context;
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description={siteConfig.tagline}>
      <header className={clsx('hero hero--primary', styles.heroBanner)}>
        <div className="container">
          <div class="row">
            <div class="col col--7">
              <img className={styles.heroMiniLogo} src={useBaseUrl('/img/logo/logo-full-mid-light.png')}/>
              <p className="hero__title">Just Another Ruby Debugger</p>
              <p className="hero__subtitle">Ruby Jard provides a rich Terminal UI that visualizes everything your need, navigates your program with pleasure, stops at matter places only, reduces manual and mental efforts. You can now focus on real debugging.</p>
              <div className={styles.buttons}>
                <Link
                  className={clsx(
                    'button button--secondary button--lg',
                    styles.getStarted,
                  )}
                  to={useBaseUrl('docs/')}>
                  Get Started
                </Link>
                <div className={clsx(styles.github, 'button--lg')}>
                  <GithubButton />
                </div>
              </div>
            </div>
            <div className={clsx("col col--5", styles.heroDemo)}>
              <a href="https://asciinema.org/a/350233" target="_blank"><img src="https://asciinema.org/a/350233.svg" /></a>
            </div>
          </div>
        </div>
      </header>
      <header className={clsx('hero hero--primary', styles.heroSubBanner)}>
        <div className="container">
          <div class="row">
            <div class="col col--4">
              <h3>
                MIT License
              </h3>
              <p>
                Ruby Jard is open-source, built for community, and under MIT license. All contributions are welcome.
              </p>
            </div>
            <div class="col col--4">
              <h3>
                Powered by Byebug and Pry
              </h3>
              <p>
                Ruby Jard's core is <a class="text--secondary" href="https://github.com/deivid-rodriguez/byebug">Byebug</a>, combine with <a class="text--secondary" href="https://github.com/pry/pry">Pry</a> REPL power. This brings battle-tested reliability, flexibility, and tons of cool features.
              </p>
            </div>
            <div class="col col--4">
              <h3>
                Pure Ruby and minimal dependencies
              </h3>
              <p>
                Jard is written in pure Ruby, with a slim set of dependencies, compatible with a wide range of systems.
              </p>
            </div>
          </div>
        </div>
      </header>
      <main>
        <section className={clsx('hero hero--light', styles.featureWrapperOdd)}>
          <div className="container">
            <div class="row">
              <div className={clsx('col col--6')}>
                <CodeHighlight
                  code={`gem 'ruby_jard'`}
                  language="ruby"
                />
                <CodeHighlight
                  code={`requrie 'ruby_jard'

def test_method
  jard # Debugger will stop here
  a = 1
  b = 2
end`}
                  language="ruby"
                />
              </div>
              <div className={clsx('col col--6')}>
                <h3>Easy to Use</h3>
                <p>
                  You just need to install the gem, put <code>jard</code> command before the place right before the place you want to stop, and run the program like normally. Jard spawns up a Terminal UI, runs right in your terminal emulator when your program stops at a break point.
                </p>
                <p>
                  The UI is friendly, intuitive, but still powerful enough. Jard's <a href={useBaseUrl('docs/')}>documents</a> come with plenty of references, guides, and videos to help you utilize all Jard features.
                </p>
              </div>
            </div>
          </div>
        </section>

        <section className={styles.featureWrapperEven}>
          <div className="container container--primary-dark">
            <div className={clsx('row', styles.feature)}>
              <div className={clsx('col col--6')}>
                <h3>Visualize everything you need</h3>
                <p>
                  Ruby Jard's visual interface lets you grab everything you need at first glance. No more constantly typing <code>list</code>, <code>where</code>, <code>puts @user</code> or <code>puts BORING_CONSTANT</code>, and then forgetting what you are doing.
                </p>
                <p>
                  Variable visualization helps you know exactly the shape of data and overview of data content, backtrace visualization helps you grab an overview of current program flow. And more.
                </p>
                <p>
                  You won't need to be worried about information overflow either. Jard is smart enough to display only relevant essential information.
                </p>
              </div>
              <div className={clsx('col col--6', styles.featureImage)}>
                <img src={useBaseUrl('img/home/demo-visualize.png')} alt="Visualize everything" />
                <img src={useBaseUrl('img/home/demo-visualize-2.png')} alt="Visualize everything" />
              </div>
            </div>
          </div>
        </section>

        <section className={styles.featureWrapperOdd}>
          <div className="container">
            <div className={clsx('row', styles.feature)}>
              <div className={clsx('col col--6', styles.featureImage)}>
                <img src={useBaseUrl('img/home/demo-navigate.png')} alt="Navigate with ease" />
              </div>
              <div className={clsx('col col--6')}>
                <h3>Navigate with pleasure</h3>
                <p>
                  Thank to backtrace visualization and source code display, you'll never get lost in the dump of backtrace again. By default, those interfaces are always available, and compact.
                </p>
                <p>
                  You now can freely go up, and down of the current stack trace. At each frame, you can view the source code, input parameters, relevant variables. This helps you create a minimap of your program execution in your mind.
                </p>
                <p>
                  Nonetheless, you can even continue the execution at a particular upper frame, get out of unwanted boring gem, or just skip a nested loop with ease.
                </p>
              </div>
            </div>
          </div>
        </section>

        <section className={styles.featureWrapperEven}>
          <div className="container">
            <div className={clsx('row', styles.feature)}>
              <div className={clsx('col col--6')}>
                <h3>Stop at matter places only</h3>
                <p>
                  How many times do you type <code>step</code>, and have idea why the debugger is leading you into a scary metaprogramming method deep in Rails?
                </p>
                <p>
                  What was the last time you are trying to debug a simple class, but have to type <code>next</code>, <code>next</code>, <code>next</code>, <code>next</code> to skip all the boring parts you don't care?
                </p>
                <p>
                  Good. Ruby Jard comes with a smart filter to let you choose the matter places only.
                  <ul>
                    <li>By default, Ruby Jard ignores everything outside of your project folder.</li>
                    <li>You can always change filter mode to go into gem, or even standard lib.</li>
                    <li>You can include/exclude a gem, a standard lib, a file, or even a folder.</li>
                  </ul>
                </p>
              </div>
              <div className={clsx('col col--6', styles.featureImage)}>
                <img src={useBaseUrl('img/home/demo-stop-matter.png')} alt="Stop at matter places" />
              </div>
            </div>
          </div>
        </section>

        <section className={styles.featureWrapperOdd}>
          <div className="container">
            <div className={clsx('row', styles.feature)}>
              <div className={clsx('col col--6', styles.featureImage)}>
                <img src={useBaseUrl('img/home/demo-repl.png')} alt="Powerful REPL" />
              </div>
              <div className={clsx('col col--6')}>
                <h3>Powerful REPL console</h3>
                <p>
                  Ruby Jard's REPL engine is powered by <a href="https://github.com/pry/pry">Pry</a>, a runtime developer console with powerful introspection capabilities. There are plenty of things you can do with the REPL console:
                  <ul>
                    <li>Ad-hoc code execution</li>
                    <li>Inspect nested variable, support syntax highlight</li>
                    <li>Source code browsing </li>
                    <li>Document browsing</li>
                    <li>Command shell integration</li>
                    <li>Navigation around state</li>
                    <li>Interfere and change current object state</li>
                  </ul>
                </p>
              </div>
            </div>
          </div>
        </section>

        <section className={styles.featureWrapperEven}>
          <div className="container">
            <div className={clsx('row', styles.feature)}>
              <div className={clsx('col col--6')}>
                <h3>Personalize your workflow</h3>
                <p>
                  Do you have a big 4K monitor? Or you are a tmux guy, who runs Ruby in tiny windows? Ruby Jard can auto-scale automatically to fit into different screen sizes.
                </p>
                <p>
                  You don't like the default theme? Sure, Ruby Jard comes with 6 color schemes, 4 dark, and 2 light ones. Did I mention you can create your own scheme?
                </p>
                <p>
                  Default key bindings don't click for you? You can redefine almost key binding.
                </p>
                <p>
                  You don't like the default layout? Too much information for you? You can define your own layout too!
                </p>
                <p>
                  Ruby Jard comes with flexible configurations in mind. Check out <a href={useBaseUrl('docs/configurations')}>the document page</a>.
                </p>
              </div>
              <div className={clsx('col col--6', styles.featureImage)}>
                <img src={useBaseUrl('img/home/demo-personalize-1.png')} alt="Peronnalize your workflow" />
                <img src={useBaseUrl('img/home/demo-personalize-2.png')} alt="Peronnalize your workflow" />
              </div>
            </div>
          </div>
        </section>
      </main>
      <header className={clsx('hero hero--primary', styles.heroBanner)}>
        <div className="container">
          <div class="row">
            <div class="col col--9">
              <p className="hero__title">
                Not what you are looking for now?
              </p>
              <p className="hero__subtitle">
                Ruby Jard is under active development. You'll be surprised when coming back later. You can always submit a feature request, and we'll welcome all contributions.
              </p>
              <div className={styles.buttons}>
                <Link
                  className={clsx(
                    'button button--secondary button--lg',
                    styles.getStarted,
                  )}
                  to={useBaseUrl('docs/')}>
                  Get Started
                </Link>
                <GithubButton/>
              </div>
            </div>
          </div>
        </div>
      </header>
    </Layout>
  );
}

export default Home;
