import React from 'react';
import clsx from 'clsx';

export const GithubButton = ({size = 'large', width = 140, height = 30, inline = false}) => {
  var styles = {};
  if (inline) {
    styles = {
      display: 'inline-block'
    }
  } else {
    styles = {
      marginLeft: 15,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }
  return (
    <div
      className={clsx('button--lg')}
      style={styles}
    >
      <iframe src={`https://ghbtns.com/github-btn.html?user=nguyenquangminh0711&repo=ruby_jard&type=star&count=true&size=${size}`} scrolling="0" title="GitHub Stars" width={width} height={height} frameBorder="0"></iframe>
    </div>
  )
}
