import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  direction: 'rtl',
  palette: {
    primary: {
      main: '#195980',
      contrastText: '#FFFFFF',
    },
    secondary: {
      main: '#97D5DD',
    },
    background: {
      default: '#FFFFFF',
      paper: '#FFFFFF',
    },
    grey: {
      200: '#DBDBE5', // Adding greyColor from Flutter theme
    },
  },
  typography: {
    fontFamily: 'Inter, sans-serif',
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          padding: '16px 24px',
          fontWeight: 'bold',
          textTransform: 'none',
        },
      },
    },
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          borderRadius: 12,
        },
      },
    },
  },
});

export default theme;
