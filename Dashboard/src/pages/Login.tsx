import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { Box, Button, TextField, Typography, Paper, Alert } from '@mui/material';
import apiClient from '../api/apiClient';
import { setCredentials } from '../redux/authSlice';

const validationSchema = Yup.object({
  phone: Yup.string().required('رقم الهاتف مطلوب'),
  password: Yup.string().required('كلمة المرور مطلوبة'),
});

const Login: React.FC = () => {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [error, setError] = useState<string | null>(null);

  const formik = useFormik({
    initialValues: {
      phone: '',
      password: '',
    },
    validationSchema: validationSchema,
    onSubmit: async (values) => {
      try {
        setError(null);
        const response = await apiClient.post('/auth/login/user', values);
        
        // Verify user is an admin or teacher before letting them in?
        // Actually, backend should technically enforce this, but we'll double check role.
        if (response.data.user.role !== 'admin' && response.data.user.role !== 'teacher') {
          setError('ليس لديك صلاحية الدخول');
          return;
        }

        dispatch(setCredentials({
          user: response.data.user,
          token: response.data.token,
        }));
        
        navigate('/');
      } catch (err: any) {
        setError(err.response?.data?.message || 'حدث خطأ في تسجيل الدخول');
      }
    },
  });

  return (
    <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', bgcolor: 'grey.200' }}>
      <Paper elevation={3} sx={{ p: 4, width: '100%', maxWidth: 400, borderRadius: 3 }}>
        <Typography variant="h5" color="primary" sx={{ mb: 3, fontWeight: 'bold', textAlign: 'center' }}>
          تسجيل الدخول - لوحة التحكم
        </Typography>
        
        {error && <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>}

        <form onSubmit={formik.handleSubmit}>
          <TextField
            fullWidth
            id="phone"
            name="phone"
            label="رقم الهاتف"
            variant="outlined"
            margin="normal"
            value={formik.values.phone}
            onChange={formik.handleChange}
            error={formik.touched.phone && Boolean(formik.errors.phone)}
            helperText={formik.touched.phone && formik.errors.phone}
            dir="ltr"
            slotProps={{ htmlInput: { style: { textAlign: 'right' } } }}
          />
          <TextField
            fullWidth
            id="password"
            name="password"
            label="كلمة المرور"
            type="password"
            variant="outlined"
            margin="normal"
            value={formik.values.password}
            onChange={formik.handleChange}
            error={formik.touched.password && Boolean(formik.errors.password)}
            helperText={formik.touched.password && formik.errors.password}
          />
          <Button
            color="primary"
            variant="contained"
            fullWidth
            type="submit"
            sx={{ mt: 3, mb: 2 }}
            disabled={formik.isSubmitting}
          >
            دخول
          </Button>
        </form>
      </Paper>
    </Box>
  );
};

export default Login;
