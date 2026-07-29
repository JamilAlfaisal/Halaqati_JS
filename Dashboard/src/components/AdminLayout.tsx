import React from 'react';
import { Outlet, useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { Box, Drawer, AppBar, Toolbar, Typography, List, ListItem, ListItemIcon, ListItemText, Button } from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import ClassIcon from '@mui/icons-material/Class';
import ExitToAppIcon from '@mui/icons-material/ExitToApp';
import type { RootState } from '../redux/store';
import { logout } from '../redux/authSlice';

const drawerWidth = 240;

const AdminLayout: React.FC = () => {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const user = useSelector((state: RootState) => state.auth.user);

  const handleLogout = () => {
    dispatch(logout());
    navigate('/login');
  };

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
        <Toolbar>
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            لوحة تحكم حلقتي
          </Typography>
          <Typography variant="body1" sx={{ mr: 2 }}>
            {user?.name}
          </Typography>
          <Button color="inherit" onClick={handleLogout} startIcon={<ExitToAppIcon />}>
            تسجيل الخروج
          </Button>
        </Toolbar>
      </AppBar>
      <Drawer
        variant="permanent"
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: { width: drawerWidth, boxSizing: 'border-box' },
        }}
      >
        <Toolbar />
        <Box sx={{ overflow: 'auto' }}>
          <List>
            <ListItem component="button" onClick={() => navigate('/')}>
              <ListItemIcon><DashboardIcon color="primary" /></ListItemIcon>
              <ListItemText primary="الرئيسية" />
            </ListItem>
            <ListItem component="button" onClick={() => navigate('/classes')}>
              <ListItemIcon><ClassIcon color="primary" /></ListItemIcon>
              <ListItemText primary="إدارة الحلقات" />
            </ListItem>
            <ListItem component="button" onClick={() => navigate('/students')}>
              <ListItemIcon><PeopleIcon color="primary" /></ListItemIcon>
              <ListItemText primary="دليل الطلاب" />
            </ListItem>
            <ListItem component="button" onClick={() => navigate('/teachers')}>
              <ListItemIcon><PeopleIcon color="primary" /></ListItemIcon>
              <ListItemText primary="دليل المعلمين" />
            </ListItem>
            <ListItem component="button" onClick={() => navigate('/create-account')}>
              <ListItemIcon><PeopleIcon color="primary" /></ListItemIcon>
              <ListItemText primary="إنشاء حسابات" />
            </ListItem>
          </List>
        </Box>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />
        <Outlet />
      </Box>
    </Box>
  );
};

export default AdminLayout;
