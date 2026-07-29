import React, { useEffect } from 'react';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import RtlProvider from './theme/RtlProvider';
import theme from './theme/theme';
import AppRoutes from './routes/AppRoutes';
import { Provider as ReduxProvider } from 'react-redux';
import { store } from './redux/store';

const App: React.FC = () => {
  useEffect(() => {
    document.dir = 'rtl';
  }, []);

  return (
    <ReduxProvider store={store}>
      <RtlProvider>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          <AppRoutes />
        </ThemeProvider>
      </RtlProvider>
    </ReduxProvider>
  );
};

export default App;
