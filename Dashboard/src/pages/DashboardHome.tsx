import React from 'react';
import { Box, Typography, Paper } from '@mui/material';

const DashboardHome: React.FC = () => {
  return (
    <Box>
      <Paper sx={{ p: 4, borderRadius: 2 }}>
        <Typography variant="h4" color="primary" gutterBottom>
          مرحباً بك في لوحة التحكم
        </Typography>
        <Typography variant="body1" color="textSecondary">
          يرجى اختيار قسم من القائمة الجانبية للبدء.
        </Typography>
      </Paper>
    </Box>
  );
};

export default DashboardHome;
