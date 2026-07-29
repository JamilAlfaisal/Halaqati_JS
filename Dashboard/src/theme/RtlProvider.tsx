import React from 'react';
import { CacheProvider } from '@emotion/react';
import createCache from '@emotion/cache';
import rtlPlugin from 'stylis-plugin-rtl';
import { prefixer } from 'stylis';

const cacheRtl = createCache({
  key: 'muirtl',
  stylisPlugins: [prefixer, rtlPlugin],
});

interface RtlProviderProps {
  children: React.ReactNode;
}

const RtlProvider: React.FC<RtlProviderProps> = ({ children }) => {
  return <CacheProvider value={cacheRtl}>{children}</CacheProvider>;
};

export default RtlProvider;
