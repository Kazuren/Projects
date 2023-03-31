import { createMuiTheme } from '@material-ui/core/styles';

export const Theme = createMuiTheme({
  palette: {
    type: "dark",
    primary: {
      light: "#4299E1",
      main: "#2B6CB0",
      dark: "#2C5282",
    },
    secondary: {
      light: "#FBD38D",
      main: "#ED8936",
      dark: "#C05621",
    },
    background: {
      paper: "#1A202C",
      paperLight: "#2D3748"
    }
  },
});
//#2b343a